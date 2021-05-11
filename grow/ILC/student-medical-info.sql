DELIMITER $$
DROP PROCEDURE IF EXISTS sp_ilc_emergency_contact$$
CREATE PROCEDURE sp_ilc_emergency_contact()

BEGIN
/*
* Semester - aware logic
* Displays ILC emergency contact info for students enrolled in current semester 
*/
DECLARE _DispSemesterID           INT;  -- Skips summer 
DECLARE _CurrentSemesterID          INT;
DECLARE _CurrentSemesterName VARCHAR(3);

-- get current SemesterID, or next SemesterID when between semesters
SET _CurrentSemesterID   = (SELECT MAX(semesterid) FROM semester 
                            WHERE NOW() BETWEEN DATE_SUB(begindate, INTERVAL 30 DAY) -- don't switch 'target' semesters until the current semester is well underway. 
                            AND DATE_ADD(enddate, INTERVAL 30 DAY));                 -- handle 'between semesters' scenarios

SET _CurrentSemesterName = (SELECT LEFT(semestername, 1) FROM semester WHERE semesterid = _CurrentSemesterID);

SET _DispSemesterID = IF(_CurrentSemesterName = 'S', _CurrentSemesterID+1, _CurrentSemesterID); -- Skip summer

SELECT DISTINCT(p.personid), CONCAT(p.lastname, ', ', p.firstname) AS 'Student', sgy.StudentGradeYear AS 'Grade', 
    CASE 
        WHEN l.scheduledesc LIKE "%Logan%" THEN "Logan" 
        WHEN l.scheduledesc LIKE "%Pleasant Grove%" THEN "Pleasant Grove" 
        WHEN l.scheduledesc LIKE "%Ogden%" THEN "Ogden" 
        WHEN l.scheduledesc LIKE "%Bountiful%" THEN "Bountiful" 
        ELSE "Unknown" END AS "ILC Location",

    IF(IFNULL(cc.eCount, 0) > 0, 'Y', 'N') AS 'Core Student',
    IF(IFNULL(ec.eCount, 0) > 0, 'Y', 'N') AS 'Elective Student', p.phone AS 'Phone Number', si.emergency_contact AS 'Emergency Contact', si.medical as 'Medical Info'
    
FROM person p
JOIN student_info si ON si.personid=p.personid
JOIN enrollment e ON e.personid=p.personid
JOIN section s USING (sectionid)
JOIN semester m USING (`semesterid`)
JOIN class c ON c.classid=s.classid 
JOIN `schedule` l ON l.sectionid=s.sectionid 
LEFT JOIN (
    SELECT sp.personid, MAX(sy.year_id) AS 'StudentGradeYear'
    FROM student_program sp 
    JOIN program pr ON pr.programid=sp.programid
    JOIN institution_year_semester iys ON iys.semester_id = _DispSemesterID
    JOIN institution_year iy ON iy.id = iys.institution_year_id AND iy.institution_id=pr.institutionid
    JOIN student_year sy ON sp.studentprogramid = sy.student_program_id AND sy.institution_year_id = iy.id AND sy.is_deleted = 0
    WHERE sp.statusid IN (0,1) AND sp.is_deleted=0
    GROUP BY sp.personid) AS sgy ON sgy.personid = e.personid
LEFT JOIN (
    SELECT e.personid, COUNT(e.enrollmentid) AS 'eCount'
    FROM enrollment e 
    JOIN section s USING (sectionid)
    JOIN semester m USING (semesterid)
    WHERE  NOW() BETWEEN DATE_SUB(m.begindate, INTERVAL 7 DAY) AND DATE_ADD(m.enddate, INTERVAL 10 DAY) AND e.statusid=1 AND s.classid BETWEEN 200 AND 206
    GROUP BY e.personid) AS cc ON cc.personid=p.personid
LEFT JOIN (
    SELECT e.personid, COUNT(e.enrollmentid) AS 'eCount'
    FROM enrollment e 
    JOIN section s USING (sectionid)
    JOIN semester m USING (semesterid)
    WHERE NOW() BETWEEN DATE_SUB(m.begindate, INTERVAL 7 DAY) AND DATE_ADD(m.enddate, INTERVAL 10 DAY) AND e.statusid=1 AND s.classid BETWEEN 214 AND 215
    GROUP BY e.personid) AS ec ON ec.personid=p.personid
WHERE NOW() BETWEEN DATE_SUB(m.begindate, INTERVAL 7 DAY) AND DATE_ADD(m.enddate, INTERVAL 10 DAY) AND e.statusid=1 AND (s.classid BETWEEN 200 AND 206 OR s.classid IN (214,215))
ORDER BY 3,1;

END $$
DELIMITER ;

CALL sp_ilc_emergency_contact();
