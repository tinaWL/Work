SELECT  e.personid, p.lastname, p.firstname
FROM `person` p 
JOIN `enrollment` e USING (personid)
JOIN `section` s USING (sectionid)
JOIN `grade` g USING (gradeid)
JOIN `class` c ON c.classid=s.classid
join location l using (locationid)



WHERE s.semesterid=44 AND e.statusid =1 AND e.credithours > 0 and l.locationid in (1,2,3,4,5) and s.divisionid = 4 AND s.classid NOT IN(703, 704, 710, 711)
  

 GROUP BY e.personid  
ORDER BY `p`.`lastname` ASC
