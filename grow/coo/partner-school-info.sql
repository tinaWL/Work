-- https://app.asana.com/0/1200281177330435/1200281177330460/f
SELECT tpp.tppayerid, tppp.preferredname AS 'Third-Party Payer', tppp.state AS 'State', 
(CASE WHEN tpp.tppapproved=1 THEN 'Active' ELSE 'Not Active' END) AS 'Status', 
tppfs.Semester AS 'First Semester',
-- If tpp is active, display student count, otherwise display last active semester
IF(tpp.TPPApproved=1, 
(SELECT COUNT(DISTINCT(e.personid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
 WHERE s.classid 
 		NOT IN (414,497,502,543,544,545,546,502,551) 
 		AND asd.studentdebitid IS NULL 
 		AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid), tppfs.max_s) AS 'Last Semester'

FROM thirdpartypayer tpp   
JOIN person tppp ON tpp.tppayerpersonid=tppp.personid 
LEFT JOIN (
    SELECT tppe.tppayerid, MIN(m.semesterid), m.semestername AS 'Semester', MAX(m.semesterid) as 'Max_n', MAX(m.semestername) as 'Max_s'
    FROM enrollment e
    JOIN section s USING (sectionid)
    JOIN semester m USING (semesterid)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
    WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
       AND sd.obsolete=0
    GROUP BY tppe.tppayerid) AS tppfs ON tppfs.tppayerid=tpp.tppayerid  
ORDER BY `First Semester` ASC
