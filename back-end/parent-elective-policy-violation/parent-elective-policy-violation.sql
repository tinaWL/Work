DELIMITER $$
DROP PROCEDURE IF EXISTS pepve$$
CREATE PROCEDURE pepve()

BEGIN


/*
* Semester / AY-aware logic
* F/W SemesterIDs and abbreviations for current AY are available as variables 
* Switches to upcoming AY (F/W) on Summer semester
*/
DECLARE _FallSemesterID           INT;  
DECLARE _WinterSemesterID           INT;  
DECLARE _CurrentSemesterID          INT;  
DECLARE _CurrentSemesterName VARCHAR(3);  
DECLARE _WinterSemesterAbbrv VARCHAR(3);
DECLARE _FallSemesterAbbrv VARCHAR(3);
DECLARE _SemName VARCHAR(3);

-- get current SemesterID, or next SemesterID when between semesters
SET _CurrentSemesterID   = (SELECT MAX(semesterid) FROM semester 
                            WHERE NOW() BETWEEN DATE_SUB(begindate, INTERVAL 30 DAY) -- don't switch 'target' semesters until the current semester is well underway. 
                            AND DATE_ADD(enddate, INTERVAL 30 DAY));                 -- handle 'between semesters' scenarios

SET _CurrentSemesterName = (SELECT LEFT(semestername, 1) FROM semester WHERE semesterid = _CurrentSemesterID);

SET _FallSemesterID =
	CASE
    	WHEN _CurrentSemesterName = 'S' THEN _CurrentSemesterID + 1
        WHEN _CurrentSemesterName = 'F' THEN _CurrentSemesterID
        ELSE _CurrentSemesterID - 1 -- don't update until the next AY
        END;
        
SET _WinterSemesterID =
	CASE
    	WHEN _CurrentSemesterName = 'S' THEN _CurrentSemesterID + 2
        WHEN _CurrentSemesterName = 'F' THEN _CurrentSemesterID + 1
        ELSE _CurrentSemesterID
        END;
    	
SET _WinterSemesterAbbrv = (SELECT CONCAT(RIGHT(semestername, 2), LEFT(semestername, 1)) FROM semester WHERE semesterid = _WinterSemesterID);
SET _FallSemesterAbbrv = (SELECT CONCAT(RIGHT(semestername, 2), LEFT(semestername, 1)) FROM semester WHERE semesterid = _FallSemesterID);
-- for testing purposes only, to verify variables are calculated correctly at different times of the year. Uncomment next row and comment out the entire SELECT beneath it.
-- SELECT _CurrentSemesterID, _CurrentSemesterName, _WinterSemesterID, _FallSemesterID, _WinterSemesterAbbrv, _FallSemesterAbbrv;


/*
* All LAU students enrolled in ILC elective blocks, OA, Debate, and LAU Funded LEMI
*
* CLASS IDS:
* 203 - 9th Grade Block
* 204 - 10th Grade Block
* 205 - 11th Grade Block
* 206 - 12th Grade Block
* 251 - Debate I
* 439 - Debate II
* 711 - OA
* 784 - MS Debate
* 868 - LAU Funded LEMI
*/
DROP TEMPORARY TABLE IF EXISTS _all; -- ALL LAU students enrolled in ILC elective blocks, OA, Debate, or LAU Funded courses
CREATE TEMPORARY TABLE IF NOT EXISTS _all
SELECT  e.personid AS 'id', p.lastname AS 'lname', p.firstname AS 'fname', s.classid AS 'classid',
(SELECT CASE
	    WHEN s.classid IN(203,204,205,206) THEN 'ILC Block'
	    WHEN s.classid = 251 THEN 'Debate I'
	    WHEN s.classid = 439 THEN 'Debate II'
	    WHEN s.classid = 711 THEN 'OA'
	    WHEN s.classid = 784 THEN 'MS Debate'
	    WHEN s.classid = 868 THEN 'LEMI'
	    ELSE '????????' -- testing
        END) AS 'class', m.semesterid as 'sid'
	FROM person p    
	JOIN enrollment e USING (personid)        
	JOIN section s USING (sectionid)
	Join schedule h on h.sectionid = s.sectionid
	JOIN semester m USING (semesterid)
	JOIN enrollmenttostudentdebit esd USING (enrollmentid)    
	JOIN studentdebit sd USING (studentdebitid)    
	JOIN thirdpartypayerengagement tppe USING (tppengagementid)
WHERE s.classid in(251,439,711,784,868,203,204,205,206) AND e.statusid =1 AND s.semesterid in(_FallSemesterID, _WinterSemesterID) and tppe.TPPayerID = 12612

UNION

/*
* LAU Students enrolled in any "LAU Funded..." courses
* Section IDs 36515,36517,3651 are all WL IS Electives
*/
SELECT e.personid AS 'id', p.lastname AS 'lname', p.firstname AS 'fname',  s.classid AS 'classid', dee.scheduledesc AS 'class', m.semesterid AS 'sid'
	FROM enrollment e
	JOIN person p on p.personid = e.personid
	JOIN section s USING (sectionid)
	JOIN semester m ON m.semesterid=s.semesterid
	JOIN `schedule` dee ON dee.sectionid=s.sectionid 
	JOIN class c ON c.classid=s.classid
	JOIN enrollmenttostudentdebit esd USING (enrollmentid)    
	JOIN studentdebit sd USING (studentdebitid)    
	JOIN thirdpartypayerengagement tppe USING (tppengagementid)
WHERE dee.scheduledesc LIKE "%LAU Funded%" AND e.statusid = 1 AND m.semesterid IN(_FallSemesterID,_WinterSemesterID) AND s.sectionid NOT IN(36515,36517,36519) AND tppe.TPPayerID = 12612;


/*
* A table of the 'weights' of the classes
* ILC blocks count as 2
* Everything else counts as 1
*/
DROP TEMPORARY TABLE IF EXISTS _v_all; 
CREATE TEMPORARY TABLE IF NOT EXISTS _v_all
SELECT id AS 'id', lname AS 'lname', fname AS 'fname', class AS 'class' ,  IF(class='ILC BLOCK',2,1) AS 'v', sid AS 'sid'
	FROM _all
 GROUP BY id, class, sid
ORDER BY id;



/*
* RESULT 
* All students who are taking more than 3 out 
* of the 5 permitted electives in a given semester
*/
DROP TEMPORARY TABLE IF EXISTS res;
CREATE TEMPORARY TABLE IF NOT EXISTS res
SELECT id as 'id', lname as 'lname', fname as 'fname' ,class as 'class', SUM(v), sid as 'sid', IF(sid = _FallSemesterID, _FallSemesterAbbrv, _WinterSemesterAbbrv) AS 'SemAbbrv'
	FROM _v_all v
GROUP BY id,sid
HAVING SUM(v) > 3
ORDER BY sid, id;

/*
* Gathering parent IDs / semeter abbrv. info in one place
* to be sure it will be the same across both cases
*/
DROP TEMPORARY TABLE IF EXISTS info;
CREATE TEMPORARY TABLE IF NOT EXISTS info
SELECT pr.firstpersonid as 'pid', 'InfusionSoft_Email', 1111 as 'eid', r.fname as 'fname', r.semabbrv as 'sem', NOW(), r.id as 'rid', r.sid as 'sid'
	FROM res r 
    LEFT JOIN person_relation pr ON pr.secondpersonid = r.id AND pr.deleted IS NULL
GROUP BY r.id, r.sid
ORDER BY r.semabbrv;


/*
* First email attempt
*/
INSERT INTO externalactivity (`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`,`CustomField02`, `CreatedDate`)
SELECT i.pid, 'InfusionSoft_Email', 13318, i.fname, i.sem, NOW()
	FROM info i
    LEFT JOIN externalactivity ea ON ea.recipientpersonid = i.pid AND ea.ExternalID = 13318
    WHERE ea.ExternalActivityID IS null
    GROUP BY i.rid, i.sid;


/*
* Setup for the second email attempt - to be sent 1 week after the first 
* Kept getting a 'command out of sync' error when trying to use WHERE ... IS NULL
* this is my workaround. If anyone finds a better way, feel free to change
*/
DROP TEMPORARY TABLE IF EXISTS _t;
CREATE TEMPORARY TABLE IF NOT EXISTS _t
SELECT i.pid as 'pid', 'InfusionSoft_Email', 13320, i.fname as 'fname', i.sem as 'sem', NOW(), ea.CreatedDate AS 'cd', i.rid AS 'rid', i.sid AS 'sid'
	FROM info i
    LEFT JOIN externalactivity ea ON ea.recipientpersonid = i.pid AND ea.ExternalID = 13318 AND date(ea.CreatedDate) = date_sub(curdate(), INTERVAL 7 day) 
    WHERE ea.CreatedDate IS NOT NULL
    GROUP BY i.rid, i.sid;
    

/*
* Second email attempt!
*/
INSERT INTO externalactivity (`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`,`CustomField02`, `CreatedDate`)    
SELECT t.pid, 'InfusionSoft_Email', 13320, t.fname, t.sem, NOW()
	FROM _t t
    LEFT JOIN externalactivity ea ON ea.recipientpersonid = t.pid AND ea.ExternalID = 13320
    WHERE ea.ExternalActivityID IS NULL
    GROUP BY t.rid, t.sid;



END$$
DELIMITER ;
CALL pepve();
