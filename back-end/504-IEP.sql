-- Students with 504 files that don't have them marked 
SELECT p.personid, p.firstname, p.lastname, sgy.studentgradeyear, cf.FileDesc FROM person p 
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
    WHERE sp.statusid in (0, 1 )
    	AND sp.is_deleted=0
    	AND sp.Has504 = 0
    GROUP BY sp.personid) AS sgy ON sgy.personid = p.personid  
ORDER BY `studentgradeyear`  DESC

