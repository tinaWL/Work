-- students 
-- INSERT INTO externalactivity(`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`, `CreatedDate`) 
SELECT e.personid, p.lastname, p.firstname, 

(CASE 
WHEN l.locationname = 'Logan ILC' THEN 13304
WHEN l.locationname = 'Ogden ILC' THEN 2222
WHEN l.locationname = 'Pleasant Grove ILC' THEN 13302

END) AS 'Email Template', l.locationname

FROM `person` p 
JOIN `enrollment` e USING (personid)
JOIN `section` s USING (sectionid)
JOIN `grade` g USING (gradeid)
JOIN `class` c ON c.classid=s.classid
JOIN location l using (locationid)
LEFT JOIN externalactivity ea ON ea.RecipientPersonID=p.personid AND ea.ExternalID IN(13304,2222,13302)
WHERE ea.ExternalActivityID IS NULL AND s.semesterid>=46 AND e.statusid =1 AND e.credithours > 0 and l.locationid in (1,2,3,4,5) and s.divisionid = 4 AND s.classid NOT IN(703, 704, 710, 711)  
group by e.personid;



-- parents
-- INSERT INTO externalactivity(`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`, `CreatedDate`) 
SELECT pg.personid, pg.lastname, pg.firstname, 

(CASE 
WHEN l.locationname = 'Logan ILC' THEN 13304
WHEN l.locationname = 'Ogden ILC' THEN 2222
WHEN l.locationname = 'Pleasant Grove ILC' THEN 13302

END) AS 'Email Template', l.locationname

FROM `person` p 
JOIN `enrollment` e USING (personid)
JOIN `section` s USING (sectionid)
JOIN `grade` g USING (gradeid)
JOIN `class` c ON c.classid=s.classid
JOIN location l using (locationid)
LEFT JOIN `person_relation` pr ON pr.secondpersonid=p.personid AND pr.deleted IS NULL 
LEFT JOIN `person` pg ON pg.personid=pr.firstpersonid
LEFT JOIN externalactivity ea ON ea.RecipientPersonID=p.personid AND ea.ExternalID IN(13304,2222,13302)
WHERE ea.ExternalActivityID IS NULL AND s.semesterid>=46 AND e.statusid =1 AND e.credithours > 0 and l.locationid in (1,2,3,4,5) and s.divisionid = 4 AND s.classid NOT IN(703, 704, 710, 711)  
group by pg.personid;
