DELIMITER $$
DROP PROCEDURE IF EXISTS sp_test_math_la$$
CREATE PROCEDURE sp_test_math_la()

BEGIN

drop temporary table if exists mla_all;
create temporary table mla_all 

SELECT distinct  e.programid as 'prid', e.personid as 'pid'
    FROM enrollment e 
    JOIN section s USING (sectionid)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID

WHERE s.semesterid >= 46 AND e.credithours > 0 AND e.statusid = 1  AND tpp.TPPayerID = 12612 
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
select *, 'Language Arts' as 'Missing' from la_final
group by la_final.pid

UNION

select *, 'Math' as 'Missing' from math_final
group by math_final.pid

UNION

select *, 'Math or Language Arts' as 'Missing' from mla_neither 
group by mla_neither.pid;

	

-- INSERT INTO externalactivity(`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`, `CreatedDate`)
SELECT DISTINCT pg.personid, 'InfusionSoft_Email', 13312, p.firstname, f.missing, NOW()
FROM final f
JOIN person p on p.personid = f.pid
LEFT JOIN `person_relation` pr ON pr.secondpersonid=p.personid AND pr.deleted IS NULL 
LEFT JOIN `person` pg ON pg.personid=pr.firstpersonid
order by p.lastname;

end $$
DELIMITER ;

call sp_test_math_la();
