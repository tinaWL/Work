DELIMITER $$
DROP PROCEDURE IF EXISTS sp_test_math_la$$
CREATE PROCEDURE sp_test_math_la()

BEGIN

drop temporary table if exists mla_all;
create temporary table mla_all 

SELECT distinct  e.programid as 'prid', e.personid as 'pid', cf.filecount as 'LP'
    FROM enrollment e 
  --  JOIN enrollment e USING (personid)
    -- JOIN `user` u ON u.userid=e.personid 
       JOIN section s USING (sectionid)
    -- JOIN class c ON c.classid=s.classid
   --  JOIN semester m USING (semesterid)
    -- JOIN `schedule` h ON h.sectionid=s.sectionid 
   -- JOIN person t ON t.personid=s.teacherid 
  --  JOIN program_class pc ON pc.classid=s.classid
--    JOIN program pr ON pr.programid=pc.programid --  and pr.programid IN(5,2,18,20,21,11)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID
     LEFT JOIN ( -- 504/IEP info
        SELECT pf.personid, COUNT(pf.person_fileid) AS 'FileCount'
        FROM person_file pf 
        WHERE pf.is_confidential=1
        GROUP BY pf.personid) AS cf ON cf.personid=e.personid

WHERE s.semesterid >= 46 AND e.credithours > 0 AND e.statusid = 1  AND tpp.TPPayerID = 12612 -- AND h.begindate < DATE(NOW())
order by pid;
        

drop temporary table if exists mla_both; -- all students currently enrolled in math and/or language arts classes
create temporary table mla_both
SELECT distinct  ma.prid as 'prid', ma.pid as 'pid'
    FROM mla_all ma 
    where ma.prid in(2,5,18,20)
order by pid;


drop temporary table if exists mla_no_math; -- students not enrolled in any math class
create temporary table mla_no_math
SELECT distinct  ma.prid as 'prid', ma.pid as 'pid'
    FROM mla_all ma 
    where ma.pid not in(select pid from mla_both where prid in(2,18))
order by pid;

drop temporary table if exists mla_no_la; -- students not enrolled in any language arts class
create temporary table mla_no_la
SELECT distinct  ma.prid as 'prid', ma.pid as 'pid'
    FROM mla_all ma 
    where ma.pid not in(select pid from mla_both where prid in(5,20))
order by pid;

drop temporary table if exists mla_neither; -- students enrolled in NEITHER math nor language arts 
create temporary table mla_neither
SELECT distinct ma.pid as 'pid'
    FROM mla_all ma 
    where ma.pid not in(select pid from mla_both) 
    order by pid;
    

drop temporary table if exists math_final; -- students ONLY missing math
create temporary table math_final
SELECT distinct  pid
    FROM mla_no_math 
    where pid not in(select pid from mla_neither) 
    order by pid;
    
    
drop temporary table if exists la_final; -- students ONLY missing language arts
create temporary table la_final
SELECT distinct  pid
    FROM mla_no_la 
    where pid not in(select pid from mla_neither) 
    order by pid;


drop temporary table if exists final; -- combination of students ONLY missing math, ONLY missing language arts, and missing NEITHER (no overlap)
create temporary table final
select * from la_final
group by la_final.pid

UNION

select * from math_final
group by math_final.pid

UNION

select * from mla_neither
group by mla_neither.pid;

select distinct f.pid as 'StudentID', concat(p.lastname, ', ', p.firstname) as 'S. Name', pg.personid as 'ParentID', concat(pg.lastname, ', ', pg.firstname) as 'P.Name'
from final f
join person p on p.personid = f.pid
LEFT JOIN `person_relation` pr ON pr.secondpersonid=p.personid AND pr.deleted IS NULL 
LEFT JOIN `person` pg ON pg.personid=pr.firstpersonid;
/*select pg.personid, pg.lastname, f.pid as 'student id' , p.firstname-- , ma.lp as '504/IEP' 
from mla_all ma
left join final f on ma.pid = f.pid
join person p on p.personid = f.pid
LEFT JOIN `person_relation` pr ON pr.secondpersonid=p.personid AND pr.deleted IS NULL 
LEFT JOIN `person` pg ON pg.personid=pr.firstpersonid
group by f.pid
order by pg.lastname;*/
/*drop temporary table if exists mla_none;
create temporary table mla_none
SELECT distinct ma.pid as 'pid', ma.prid as 'prid'
    FROM mla_neither ma
    where ma.pid not in(select pid from mla_no_math) 
    order by pid;*/

    
-- select * from mla_all where pid not in (select pid from mla_both) -- don't have either 
-- select * from mla_all where pid not in(select pid from mla_both where prid in(2,18)) -- don't have math
-- select * from mla_all where pid not in(select pid from mla_both where prid in(5,20)) -- don't have language arts
/*select ma.pid, la.pid, nm.pid, n.pid from mla_all ma
left join mla_no_la la on la.pid = ma.pid
left join mla_no_math nm on nm.pid = la.pid
left join mla_neither n on n.pid = nm.pid
group by ma.pid;*/
-- left join mla_no_math nm on nm.pid = la.pid
end $$
DELIMITER ;

call sp_test_math_la();
