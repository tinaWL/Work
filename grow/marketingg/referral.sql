SELECT DISTINCT
	p.personid as 'Student ID', 
    CONCAT(p.lastname, ', ', p.firstname) AS 'Student Name', 
    IFNULL(tppp.preferredname, 'WA') AS 'SOR'
FROM person p
	JOIN person_relation pr on pr.secondpersonid = p.personid
	JOIN student_program sp ON sp.personid=p.personid AND sp.statusid=1 AND sp.is_deleted=0
	JOIN enrollment e ON e.personid=p.personid
    JOIN section s ON s.sectionid = e.sectionid AND s.semesterid = 46
	JOIN enrollmenttostudentdebit esd USING (enrollmentid)
	JOIN studentdebit sd USING (studentdebitid)
	LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid AND asd.obsolete=0
	LEFT JOIN thirdpartypayerengagement tppe ON tppe.tppengagementid=sd.tppengagementid
	LEFT JOIN thirdpartypayer tpp ON tpp.tppayerid=tppe.tppayerid
	LEFT JOIN person tppp ON tppp.personid=tpp.tppayerpersonid  
ORDER BY `Student ID` ASC
