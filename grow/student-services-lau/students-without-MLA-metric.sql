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


-- All current LAU enrollments
DROP TEMPORARY TABLE IF EXISTS mla_all; 
CREATE TEMPORARY TABLE IF NOT EXISTS mla_all 
SELECT DISTINCT  e.programid AS 'prid', e.personid AS 'pid', s.semesterid as 'sid'
     FROM enrollment e 				   
     JOIN section s USING (sectionid)
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID
WHERE s.semesterid IN(_FallSemesterID, _WinterSemesterID) AND e.credithours > 0 AND e.statusid = 1  AND tpp.TPPayerID = 12612 
ORDER BY pid;
        
					   
DROP TEMPORARY TABLE IF EXISTS mla_both; -- Students currently enrolled in math and/or language arts classes
CREATE TEMPORARY TABLE IF NOT EXISTS mla_both					   
SELECT DISTINCT  ma.prid AS 'prid', ma.pid AS 'pid', ma.sid as 'sid' 
     FROM mla_all ma 
WHERE ma.prid in(2,5,18,20)
ORDER BY pid;

					   
DROP TEMPORARY TABLE IF EXISTS mla_no_math; -- Students not enrolled in any math class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_math				   
SELECT distinct  ma.prid AS 'prid', ma.pid AS 'pid' , ma.sid as 'sid'
     FROM mla_all ma 
WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(2,18))
ORDER BY pid;
							   
							   
DROP TEMPORARY TABLE IF EXISTS mla_no_la; -- Studens not enrolled in any Language Arts class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_la						   
SELECT DISTINCT  ma.prid AS 'prid', ma.pid AS 'pid', ma.sid as 'sid'
     FROM mla_all ma 
WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(5,20))
ORDER BY pid;

DROP TEMPORARY TABLE IF EXISTS mla_neither; -- students enrolled in NEITHER math nor language arts 
CREATE TEMPORARY TABLE IF NOT EXISTS mla_neither
SELECT DISTINCT ma.pid AS 'pid', ma.sid as 'sid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both) 
ORDER BY pid;
							       
    

DROP TEMPORARY TABLE IF EXISTS math_final; -- Students ONLY missing math
CREATE TEMPORARY TABLE IF NOT EXISTS math_final
SELECT DISTINCT pid, sid as 'sid'
     FROM mla_no_math 
WHERE pid NOT IN(SELECT pid FROM mla_neither) 
ORDER BY pid;
    
    
DROP TEMPORARY TABLE IF EXISTS la_final; -- students ONLY missing language arts
CREATE TEMPORARY TABLE IF NOT EXISTS la_final
SELECT DISTINCT  pid, sid as 'sid'
     FROM mla_no_la 
     WHERE pid NOT IN(SELECT pid FROM mla_neither) 
ORDER BY pid;


DROP TEMPORARY TABLE IF EXISTS final; -- combination of students ONLY missing math, ONLY missing language arts, and missing NEITHER (no overlap)
CREATE TEMPORARY TABLE IF NOT EXISTS final
SELECT *, 'Language Arts' AS 'Missing' 
     FROM la_final
GROUP BY sid, la_final.pid

UNION

SELECT *, 'Math' AS 'Missing'
     FROM math_final							   
GROUP BY sid, math_final.pid

UNION

SELECT *, 'Math and Language Arts' AS 'Missing' 
     FROM mla_neither 
GROUP BY sid, mla_neither.pid;

	
-- Final output for the metric 
SELECT DISTINCT f.pid, concat(p.lastname, ', ', p.firstname) as 'Name',  sgy.StudentGradeYear as 'Grade',f.missing as 'MissingEnrollments', IF(sid = _FallSemesterID, _FallSemesterAbbrv, _WinterSemesterAbbrv) as 'Sem'
FROM final f
JOIN person p on p.personid = f.pid
LEFT JOIN ( -- 504/IEP info 
        SELECT pf.personid, COUNT(pf.person_fileid) AS 'FileCount'
             FROM person_file pf
	     JOIN file f ON f.fileid = pf.fileid AND f.deleted = 0
        WHERE pf.is_confidential=1
        GROUP BY pf.personid) AS cf ON cf.personid=p.personid
LEFT JOIN ( -- Get student grade
    SELECT sp.personid, MAX(sy.year_id) AS 'StudentGradeYear'
         FROM student_program sp
         JOIN program pr ON pr.programid=sp.programid
         JOIN institution_year_semester iys ON iys.semester_id IN(_FallSemesterID, _WinterSemesterID)
         JOIN institution_year iy ON iy.id = iys.institution_year_id AND iy.institution_id=pr.institutionid
         JOIN student_year sy ON sp.studentprogramid = sy.student_program_id AND sy.institution_year_id = iy.id AND sy.is_deleted = 0
    WHERE sp.statusid = 1 AND sp.is_deleted=0
    GROUP BY sp.personid) AS sgy ON sgy.personid = p.personid
WHERE cf.FileCount IS NULL -- resulting list is students WITHOU 504/IEPs
ORDER BY sem, p.lastname;

END
