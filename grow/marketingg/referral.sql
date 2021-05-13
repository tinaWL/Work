SELECT DISTINCT
	p.personid as 'Student ID', 
    CONCAT(p.lastname, ', ', p.firstname) AS 'Student Name', 
    IFNULL(tppp.preferredname, 'WA') AS 'SOR',
    CONCAT(pg.lastname, ', ', pg.firstname) AS 'Parent Name',
    pg.personid AS 'Parent ID',
    pr.relationtype,
    COUNT(DISTINCT p.personid) AS 'Children',
    COUNT(e.enrollmentid) as 'Enrollments',
    COUNT(dr.EnrollmentID) as 'Drops'
FROM person p
	JOIN person_relation pr on pr.secondpersonid = p.personid
    JOIN person pg on pg.personid = pr.firstpersonid
	JOIN student_program sp ON sp.personid=p.personid AND sp.statusid=1 AND sp.is_deleted=0
	JOIN enrollment e ON e.personid=p.personid
    left JOIN droprequest dr on dr.EnrollmentID = e.enrollmentid
    JOIN section s ON s.sectionid = e.sectionid 
    JOIN semester m on m.semesterid = s.semesterid
	JOIN enrollmenttostudentdebit esd ON esd.EnrollmentID = e.enrollmentid
	JOIN studentdebit sd USING (studentdebitid)
	LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid AND asd.obsolete=0
	LEFT JOIN thirdpartypayerengagement tppe ON tppe.tppengagementid=sd.tppengagementid
	LEFT JOIN thirdpartypayer tpp ON tpp.tppayerid=tppe.tppayerid
	LEFT JOIN person tppp ON tppp.personid=tpp.tppayerpersonid
    
--  WHERE dr.RequestDate < DATE_ADD(m.begindate, interval 28 day)
GROUP BY pg.personid  
HAVING COUNT(e.enrollmentid) != COUNT(dr.EnrollmentID)
