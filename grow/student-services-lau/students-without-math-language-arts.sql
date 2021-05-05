DELIMITER $$
DROP PROCEDURE IF EXISTS sp_test_math_la$$
CREATE PROCEDURE sp_test_math_la()

BEGIN

drop temporary table if exists mla_all;
create temporary table mla_all 

SELECT distinct e.personid as 'pid', pr.programid as 'prid'
    FROM person p 
    JOIN enrollment e USING (personid)
    JOIN `user` u ON u.userid=e.personid 
    JOIN section s USING (sectionid)
    JOIN class c ON c.classid=s.classid
    JOIN semester m USING (semesterid)
    JOIN `schedule` h ON h.sectionid=s.sectionid 
    JOIN person t ON t.personid=s.teacherid 
    JOIN program_class pc ON pc.classid=s.classid
    JOIN program pr ON pr.programid=pc.programid --  and pr.programid IN(5,2,18,20,21,11)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID

WHERE s.semesterid = 44 AND e.credithours > 0 AND e.statusid = 1 AND h.begindate < DATE(NOW()) AND tpp.TPPayerID = 12612
order by pid;
        

drop temporary table if exists mla_both;
create temporary table mla_both
SELECT distinct ma.pid as 'pid', ma.prid
    FROM mla_all ma 
    where ma.prid in(2,5,18,20)
order by pid;

    
select * from mla_all where pid not in (select pid from mla_both)
group by pid;
end $$
DELIMITER ;

call sp_test_math_la();
