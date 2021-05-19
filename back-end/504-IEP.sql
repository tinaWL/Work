DELIMITER $$
DROP PROCEDURE IF EXISTS sp_retro_504_iep$$
CREATE PROCEDURE sp_retro_504_iep()

BEGIN

-- All current students with a 504
DROP TEMPORARY TABLE IF EXISTS _504;
CREATE TEMPORARY TABLE IF NOT EXISTS _504
SELECT p.personid, p.firstname, p.lastname, sgy.studentgradeyear, cf.FileDesc 
FROM person p 
JOIN ( -- 504 info
	SELECT pf.personid, pf.description AS 'FileDesc'
    	FROM person_file pf
	    JOIN file f ON f.fileid = pf.fileid AND f.deleted = 0
    WHERE pf.is_confidential=1 
    	AND pf.description LIKE "%504%"
    	AND pf.personid NOT IN(12865,13931,18686) -- 504 Terminated
    GROUP BY pf.personid) AS cf ON cf.personid=p.personid
JOIN ( -- Grade year
    SELECT sp.personid, MAX(sy.year_id) AS 'StudentGradeYear'
    	FROM student_program sp
    	JOIN program pr ON pr.programid=sp.programid
        JOIN institution_year_semester iys ON iys.semester_id = 46
        JOIN institution_year iy ON iy.id = iys.institution_year_id AND iy.institution_id=pr.institutionid
        JOIN student_year sy ON sp.studentprogramid = sy.student_program_id AND sy.institution_year_id = iy.id AND sy.is_deleted = 0
    WHERE sp.statusid in (0, 1)
    	AND sp.is_deleted=0
    	AND sp.Has504 = 0
    GROUP BY sp.personid) AS sgy ON sgy.personid = p.personid;
    
    
DROP TEMPORARY TABLE IF EXISTS _IEP;
CREATE TEMPORARY TABLE IF NOT EXISTS _IEP
SELECT p.personid, p.firstname, p.lastname, sgy.studentgradeyear, cf.FileDesc 
FROM person p 
JOIN ( -- 504 info
	SELECT pf.personid, pf.description AS 'FileDesc'
    	FROM person_file pf
	    JOIN file f ON f.fileid = pf.fileid AND f.deleted = 0
    WHERE pf.is_confidential=1 
    	AND pf.description LIKE "%IEP%"
    	AND pf.personid NOT IN(15402,11293) -- 504 Terminated
    GROUP BY pf.personid) AS cf ON cf.personid=p.personid
JOIN ( -- Grade year
    SELECT sp.personid, MAX(sy.year_id) AS 'StudentGradeYear'
    	FROM student_program sp
    	JOIN program pr ON pr.programid=sp.programid
        JOIN institution_year_semester iys ON iys.semester_id = 46
        JOIN institution_year iy ON iy.id = iys.institution_year_id AND iy.institution_id=pr.institutionid
        JOIN student_year sy ON sp.studentprogramid = sy.student_program_id AND sy.institution_year_id = iy.id AND sy.is_deleted = 0
    WHERE sp.statusid in (0, 1 )
    	AND sp.is_deleted=0
    	AND sp.HasIEP = 0
    GROUP BY sp.personid) AS sgy ON sgy.personid = p.personid;
    
    
    
UPDATE student_program sp
JOIN _504 on _504.personid = sp.personid
SET sp.Has504 = 1, sp.changedate = NOW()
WHERE sp.programid = 21;

INSERT INTO student_program_history(`student_program_id`, `date`, `userid`, `student_program_field`, new_value)
SELECT DISTINCT(sp.programid), NOW(), '22365', 'Has504', '1'
	FROM _504
    JOIN student_program sp ON _504.personid = sp.personid
    WHERE sp.programid = 21;
    
    
UPDATE student_program sp
JOIN _IEP on _IEP.personid = sp.personid
SET sp.HasIEP = 1, sp.changedate = NOW()
WHERE sp.programid=21;

INSERT INTO student_program_history(`student_program_id`, `date`, `userid`, `student_program_field`, new_value)
SELECT DISTINCT(sp.programid), NOW(), '22365', 'HasIEP', '1'
	FROM _IEP
    JOIN student_program sp ON _IEP.personid = sp.personid
    WHERE sp.programid = 21;

    

END$$
DELIMITER ;
CALL sp_retro_504_iep();
