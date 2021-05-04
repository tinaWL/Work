DELIMITER $$
DROP PROCEDURE IF EXISTS sp_test_math_la$$
CREATE PROCEDURE sp_test_math_la()

BEGIN

DROP TEMPORARY TABLE IF EXISTS `m_la`;
CREATE TEMPORARY TABLE m_la (id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY, 
                                      `pid` int, `mla` int);

INSERT INTO m_la (`pid`, `mla`)


SELECT distinct e.personid as 'pid',  IF(pr.programid IN(5,2,18,20,21,11), 1, 0) as 'mla'
    FROM person p 
    JOIN enrollment e USING (personid)
    JOIN `user` u ON u.userid=e.personid 
    JOIN section s USING (sectionid)
    JOIN class c ON c.classid=s.classid
    JOIN semester m USING (semesterid)
    JOIN `schedule` h ON h.sectionid=s.sectionid 
    JOIN person t ON t.personid=s.teacherid 
    JOIN program_class pc ON pc.classid=s.classid
    JOIN program pr ON pr.programid=pc.programid  
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID

WHERE s.semesterid = 44 AND e.credithours > 0 AND e.statusid = 1 AND h.begindate < DATE(NOW()) AND tpp.TPPayerID = 12612

order by pid, mla desc;


        
   
select pid, mla from m_la
group by pid;
        
end $$
DELIMITER ;

call sp_test_math_la();
