DELIMITER $$
DROP PROCEDURE IF EXISTS sp_grad_plan$$
CREATE PROCEDURE sp_grad_plan()

BEGIN

DROP TEMPORARY TABLE IF EXISTS gpIDs;

CREATE TEMPORARY TABLE IF NOT EXISTS gpIDs AS

SELECT DISTINCT p.personid, concat(p.firstname, ' ', p.lastname) AS 'name', sgy.StudentGradeYear, sp.studentprogramid, sp.programid, sp.statusid, sp.AnticipatedGradSemesterID, gp.GradPlanID

FROM person p
JOIN student_program sp ON sp.personid=p.personid AND sp.statusid=1 AND sp.is_deleted=0 
LEFT JOIN gradplanperson gp ON gp.StudentProgramID = sp.studentprogramid


LEFT JOIN (
  SELECT sp.personid, MAX(sy.year_id) AS 'StudentGradeYear'
    FROM student_program sp
    JOIN program pr ON pr.programid=sp.programid
    JOIN institution_year_semester iys ON iys.semester_id >=44
    JOIN institution_year iy ON iy.id = iys.institution_year_id AND iy.institution_id=pr.institutionid
    JOIN student_year sy ON sp.studentprogramid = sy.student_program_id AND sy.institution_year_id = iy.id AND sy.is_deleted = 0
  WHERE sp.statusid IN (0,1) AND sp.is_deleted=0
  GROUP BY sp.personid) AS sgy ON sgy.personid = p.personid

WHERE (sgy.studentGradeYear between 8 and 12) and gp.GradPlanID is null;



INSERT INTO gradplanperson(`studentprogramid`, `gradplanid`, `createdbyid`,`createddate`)
SELECT studentprogramid, 1, 22365, NOW()
FROM gpids
WHERE programid = 21;


INSERT INTO gradplanperson(`studentprogramid`, `gradplanid`, `createdbyid`,`createddate`)
SELECT studentprogramid, 1, 22365, NOW()
FROM gpids
WHERE !(programid=21 and gradplanid=1);


INSERT INTO gradplanpersonhistory(`gradplanpersonid`, `date`, `personid`)
SELECT gp.gradplanpersonid, NOW(),22365
  FROM gpids
  JOIN gradplanperson gp using (studentprogramid);

END $$
DELIMITER ;

CALL sp_grad_plan();
