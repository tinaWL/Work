
-- https://app.asana.com/0/1200281177330435/1200281177330460/f
SELECT tpp.tppayerid, tppp.preferredname AS 'Third-Party Payer', tppp.state AS 'State', 
(CASE WHEN tpp.tppapproved=1 THEN 'Active' ELSE 'Not Active' END) AS 'Status', tppfs.Semester AS 'First Semester', tppfs.Max_ as 'Max', tppfs.s2 as "S2",


    (SELECT COUNT(DISTINCT(e.personid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN program_class pc ON pc.classid=s.classid
     JOIN program pr ON pr.programid=pc.programid AND pr.subprogramof=13
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'MS Students',

    (SELECT COUNT(DISTINCT(e.enrollmentid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN program_class pc ON pc.classid=s.classid
     JOIN program pr ON pr.programid=pc.programid AND pr.subprogramof=13
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'MS Enrollments',


    (SELECT COUNT(DISTINCT(e.personid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN program_class pc ON pc.classid=s.classid
     JOIN program pr ON pr.programid=pc.programid AND pr.subprogramof=1
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'HS Students',

    (SELECT COUNT(DISTINCT(e.enrollmentid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN program_class pc ON pc.classid=s.classid
     JOIN program pr ON pr.programid=pc.programid AND pr.subprogramof=1
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'HS Enrollments',

  
    

    (SELECT COUNT(DISTINCT(e.personid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'Students',

    (SELECT COUNT(DISTINCT(e.enrollmentid))
     FROM enrollment e
     JOIN section s USING (sectionid)
     JOIN enrollmenttostudentdebit esd USING (enrollmentid)
     JOIN studentdebit sd USING (studentdebitid)
     JOIN thirdpartypayerengagement tppe USING (tppengagementid)
     LEFT JOIN studentdebit asd ON asd.adjustsdebitid=sd.studentdebitid
     WHERE s.classid NOT IN (414,497,502,543,544,545,546,502,551) AND asd.studentdebitid IS NULL AND e.statusid IN (1,4) 
        AND tpp.tppayerid=tppe.tppayerid) AS 'Enrollments'

 

FROM thirdpartypayer tpp   
JOIN person tppp ON tpp.tppayerpersonid=tppp.personid 
LEFT JOIN (
    SELECT tppe.tppayerid, MIN(m.semesterid), m.semestername AS 'Semester', MAX(m.semesterid) as 'Max_', m.semestername as "s2"
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
