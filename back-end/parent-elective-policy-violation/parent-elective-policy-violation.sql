select e.personid, p.lastname, p.firstname
FROM person p        
JOIN enrollment e USING (personid)        
JOIN section s USING (sectionid)
JOIN semester m USING (semesterid)
WHERE s.classid in(215, 251,439,711,784) AND e.statusid =1 AND s.semesterid=46 

UNION


       SELECT eee.personid, p.lastname, p.firstname
        FROM enrollment eee 
        join person p on p.personid = eee.personid
        JOIN section see USING (sectionid)
        JOIN semester mee ON mee.semesterid=see.semesterid
        JOIN `schedule` dee ON dee.sectionid=see.sectiongroupid 
        JOIN class cee ON cee.classid=see.classid
        WHERE dee.scheduledesc LIKE "%LAU Funded%" AND eee.statusid =1 AND mee.semesterid=46  
        
        
        UNION
        
    select e.personid, p.lastname, p.firstname
FROM person p        
JOIN enrollment e USING (personid)        
JOIN section s USING (sectionid)
JOIN semester m USING (semesterid)
WHERE s.classid in(272) AND e.statusid =1 AND s.semesterid=46   and s.sectionid = 36663  
        
 

ORDER BY `lastname` ASC
