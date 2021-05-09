/*
* All LAU students enrolled in ILC elective blocks, OA, Debate, and LAU Funded LEMI
*
* CLASS IDS:
* 203 - 9th Grade Block
* 204 - 10th Grade Block
* 205 - 11th Grade Block
* 206 - 12th Grade Block
* 251 - Debate I
* 439 - Debate II
* 711 - OA
* 784 - MS Debate
* 868 - LAU Funded LEMI
*/
select e.personid, p.lastname, p.firstname,
(SELECT CASE
	WHEN s.classid IN(203,204,205,206) THEN 'ILC BLOCK'
    WHEN s.classid = 251 THEN 'Debate I'
    WHEN s.classid = 439 THEN 'Debate II'
    WHEN s.classid = 711 THEN 'OA'
    WHEN s.classid = 784 THEN 'MS Debate'
    WHEN s.classid = 868 THEN 'LEMI'
    ELSE '????????'
    END) AS 'class'
FROM person p    
JOIN enrollment e USING (personid)        
JOIN section s USING (sectionid)
Join schedule h on h.sectionid = s.sectionid
JOIN semester m USING (semesterid)
JOIN enrollmenttostudentdebit esd USING (enrollmentid)    
JOIN studentdebit sd USING (studentdebitid)    
JOIN thirdpartypayerengagement tppe USING (tppengagementid)
WHERE s.classid in(251,439,711,784,868,203,204,205,206) AND e.statusid =1 AND s.semesterid IN(46,47) and tppe.TPPayerID = 12612


-- group by p.personid

UNION all 


/*
* LAU Students enrolled in any "LAU Funded..." courses
* Section IDs 36515,36517,3651 are all WL IS Electives
*/
SELECT eee.personid, p.lastname, p.firstname, dee.scheduledesc
FROM enrollment eee 
join person p on p.personid = eee.personid
JOIN section see USING (sectionid)
JOIN semester mee ON mee.semesterid=see.semesterid
JOIN `schedule` dee ON dee.sectionid=see.sectionid 
JOIN class cee ON cee.classid=see.classid
JOIN enrollmenttostudentdebit esd USING (enrollmentid)    
JOIN studentdebit sd USING (studentdebitid)    
JOIN thirdpartypayerengagement tppe USING (tppengagementid)
WHERE dee.scheduledesc LIKE "%LAU Funded%" AND eee.statusid =1 AND mee.semesterid IN(46,47) AND see.sectionid NOT IN(36515,36517,36519) and tppe.TPPayerID = 12612


ORDER BY `lastname` ASC
