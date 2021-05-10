DELIMITER $$
DROP PROCEDURE IF EXISTS sp_no_math_la$$
CREATE PROCEDURE sp_no_math_la()

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

DROP TEMPORARY TABLE IF EXISTS mla_all;
CREATE TEMPORARY TABLE IF NOT EXISTS mla_all 

SELECT DISTINCT  e.programid AS 'prid', e.personid AS 'pid', s.semesterid AS 'sid'
    FROM enrollment e 
    JOIN section s USING (sectionid)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID

WHERE s.semesterid >= _FallSemesterID AND e.credithours > 0 AND e.statusid = 1  AND tpp.TPPayerID = 12612 
order by pid;
        

DROP TEMPORARY TABLE IF EXISTS mla_both; -- all students currently enrolled in math and/or language arts classes
CREATE TEMPORARY TABLE IF NOT EXISTS mla_both
SELECT DISTINCT  ma.prid AS 'prid', ma.pid AS 'pid', ma.sid AS 'sid'
    FROM mla_all ma 
    WHERE ma.prid in(2,5,18,20)
ORDER BY pid;


DROP TEMPORARY TABLE IF EXISTS mla_no_math; -- students not enrolled in any math class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_math
SELECT distinct  ma.prid AS 'prid', ma.pid AS 'pid', ma.sid AS 'sid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(2,18))
ORDER BY pid;

DROP TEMPORARY TABLE IF EXISTS mla_no_la; -- students not enrolled in any language arts class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_la
SELECT distinct  ma.prid AS 'prid', ma.pid AS 'pid', ma.sid AS 'sid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(5,20))
order by pid;

DROP TEMPORARY TABLE IF EXISTS mla_neither; -- students enrolled in NEITHER math nor language arts 
CREATE TEMPORARY TABLE IF NOT EXISTS mla_neither
SELECT DISTINCT ma.pid AS 'pid', ma.sid AS 'sid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both) 
ORDER BY pid;
    

DROP TEMPORARY TABLE IF EXISTS math_final; -- students ONLY missing math
CREATE TEMPORARY TABLE IF NOT EXISTS math_final
SELECT DISTINCT pid, sid AS 'sid'
    FROM mla_no_math 
    WHERE pid NOT IN(SELECT pid FROM mla_neither) 
    order by pid;
    
    
DROP TEMPORARY TABLE IF EXISTS la_final; -- students ONLY missing language arts
CREATE TEMPORARY TABLE IF NOT EXISTS la_final
SELECT DISTINCT  pid, sid AS 'sid'
    FROM mla_no_la 
    WHERE pid NOT IN(SELECT pid FROM mla_neither) 
ORDER BY pid;


DROP TEMPORARY TABLE IF EXISTS final; -- combination of students ONLY missing math, ONLY missing language arts, and missing NEITHER (no overlap)
CREATE TEMPORARY TABLE IF NOT EXISTS final
SELECT *, 'Language Arts' AS 'Missing' FROM la_final
GROUP BY sid,la_final.pid

UNION

SELECT *, 'Math' AS 'Missing' FROM math_final
group by sid,math_final.pid

UNION

SELECT *, 'Math or Language Arts' AS 'Missing' FROM mla_neither 
GROUP BY sid,mla_neither.pid;

DROP TEMPORARY TABLE IF EXISTS setup; -- combination of students ONLY missing math, ONLY missing language arts, and missing NEITHER (no overlap)
CREATE TEMPORARY TABLE IF NOT EXISTS setup	
SELECT DISTINCT pr.firstpersonid AS 'pid', p.firstname as 'fname', CONCAT(f.missing, ' for ',IF(sid = _FallSemesterID, _FallSemesterAbbrv, _WinterSemesterAbbrv)) AS 'SA'
FROM final f
JOIN person p on p.personid = f.pid
LEFT JOIN person_relation pr ON pr.secondpersonid = f.pid AND pr.deleted IS NULL
LEFT JOIN externalactivity ea on ea.RecipientPersonID = pr.firstpersonid
LEFT JOIN ( -- 504/IEP info
        SELECT pf.personid, COUNT(pf.person_fileid) AS 'FileCount'
        FROM person_file pf 
        WHERE pf.is_confidential=1
        GROUP BY pf.personid) AS cf ON cf.personid=p.personid
WHERE cf.FileCount IS NULL 
order by sid;


INSERT INTO externalactivity(`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`, `CustomField02`,`CreatedDate`) 
SELECT DISTINCT s.pid, 'InfusionSoft_Email', 13312, s.fname, s.sa, NOW()
FROM setup s
LEFT JOIN externalactivity ea ON ea.RecipientPersonID = s.pid AND ea.ExternalID = 13312
WHERE ea.ExternalActivityID IS NULL;

END $$
DELIMITER ;

CALL sp_no_math_la();
