UPDATE student_program sp
JOIN application a ON a.personid = sp.personid
JOIN applicationstepelementresponse aser ON aser.ApplicationID = a.ApplicationID
SET sp.HasIEP = 1
WHERE aser.ApplicationStepElementID IN(1247) AND aser.ResponseValue LIKE "%yes%" AND sp.programid=21 AND sp.is_deleted=0 AND sp.statusid IN (0,1);

INSERT INTO student_program_history(`student_program_id`, `date`, `userid`, `student_program_field`, new_value)
SELECT DISTINCT(sp.programid), aser.ResponseDate, '29', 'HasIEP', '1'
FROM student_program sp
JOIN application a ON a.personid = sp.personid
JOIN applicationstepelementresponse aser ON aser.ApplicationID = a.ApplicationID
LEFT JOIN student_program_history sph ON sph.student_program_id = sp.studentprogramid
WHERE sph.student_program_id IS NULL AND aser.ApplicationStepElementID IN(1247) AND aser.ResponseValue LIKE "%yes%" AND sp.programid=21 AND sp.is_deleted=0 AND sp.statusid IN (0,1);

-- update for 504
UPDATE student_program sp
JOIN application a ON a.personid = sp.personid
JOIN applicationstepelementresponse aser ON aser.ApplicationID = a.ApplicationID
SET sp.Has504 = 1
WHERE aser.ApplicationStepElementID IN(1250) AND aser.ResponseValue LIKE "%yes%" AND sp.programid=21 AND sp.is_deleted=0 AND sp.statusid IN (0,1);

INSERT INTO student_program_history(`student_program_id`, `date`, `userid`, `student_program_field`, new_value)
SELECT DISTINCT(sp.programid), aser.ResponseDate, '29', 'Has504', '1'
FROM student_program sp
JOIN application a ON a.personid = sp.personid
JOIN applicationstepelementresponse aser ON aser.ApplicationID = a.ApplicationID
LEFT JOIN student_program_history sph ON sph.student_program_id = sp.studentprogramid
WHERE sph.student_program_id IS NULL AND aser.ApplicationStepElementID IN(1250) AND aser.ResponseValue LIKE "%yes%" AND sp.programid=21 AND sp.is_deleted=0 AND sp.statusid IN (0,1);
