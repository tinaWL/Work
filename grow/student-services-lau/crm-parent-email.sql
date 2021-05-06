DROP TEMPORARY TABLE IF EXISTS mla_all;
CREATE TEMPORARY TABLE IF NOT EXISTS mla_all 

SELECT DISTINCT  e.programid AS 'prid', e.personid AS 'pid'
    FROM enrollment e 
    JOIN section s USING (sectionid)
    JOIN enrollmenttostudentdebit esd USING (enrollmentid)
    JOIN studentdebit sd USING (studentdebitid)
    LEFT JOIN thirdpartypayerengagement tppe USING (tppengagementid)
    LEFT JOIN thirdpartypayer tpp ON tpp.TPPayerID=tppe.TPPayerID

WHERE s.semesterid >= @futuresem AND e.credithours > 0 AND e.statusid = 1  AND tpp.TPPayerID = 12612 
order by pid;
        

DROP TEMPORARY TABLE IF EXISTS mla_both; -- all students currently enrolled in math and/or language arts classes
CREATE TEMPORARY TABLE IF NOT EXISTS mla_both
SELECT DISTINCT  ma.prid AS 'prid', ma.pid AS 'pid'
    FROM mla_all ma 
    WHERE ma.prid in(2,5,18,20)
ORDER BY pid;


DROP TEMPORARY TABLE IF EXISTS mla_no_math; -- students not enrolled in any math class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_math
SELECT distinct  ma.prid AS 'prid', ma.pid AS 'pid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(2,18))
ORDER BY pid;

DROP TEMPORARY TABLE IF EXISTS mla_no_la; -- students not enrolled in any language arts class
CREATE TEMPORARY TABLE IF NOT EXISTS mla_no_la
SELECT distinct  ma.prid AS 'prid', ma.pid AS 'pid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both WHERE prid IN(5,20))
order by pid;

DROP TEMPORARY TABLE IF EXISTS mla_neither; -- students enrolled in NEITHER math nor language arts 
CREATE TEMPORARY TABLE IF NOT EXISTS mla_neither
SELECT DISTINCT ma.pid AS 'pid'
    FROM mla_all ma 
    WHERE ma.pid NOT IN(SELECT pid FROM mla_both) 
ORDER BY pid;
    

DROP TEMPORARY TABLE IF EXISTS math_final; -- students ONLY missing math
CREATE TEMPORARY TABLE IF NOT EXISTS math_final
SELECT DISTINCT pid
    FROM mla_no_math 
    WHERE pid NOT IN(SELECT pid FROM mla_neither) 
    order by pid;
    
    
DROP TEMPORARY TABLE IF EXISTS la_final; -- students ONLY missing language arts
CREATE TEMPORARY TABLE IF NOT EXISTS la_final
SELECT DISTINCT  pid
    FROM mla_no_la 
    WHERE pid NOT IN(SELECT pid FROM mla_neither) 
ORDER BY pid;


DROP TEMPORARY TABLE IF EXISTS final; -- combination of students ONLY missing math, ONLY missing language arts, and missing NEITHER (no overlap)
CREATE TEMPORARY TABLE IF NOT EXISTS final
SELECT *, 'Language Arts' AS 'Missing' FROM la_final
GROUP BY la_final.pid

UNION

SELECT *, 'Math' AS 'Missing' FROM math_final
group by math_final.pid

UNION

SELECT *, 'Math or Language Arts' AS 'Missing' FROM mla_neither 
GROUP BY mla_neither.pid;

	

INSERT INTO externalactivity(`RecipientPersonID`, `ActivityType`, `ExternalID`, `CustomField01`, `CustomField02`,`CreatedDate`)
SELECT DISTINCT pg.personid, 'InfusionSoft_Email', 13312, p.firstname, f.missing, NOW()
FROM final f
JOIN person p on p.personid = f.pid
LEFT JOIN `person_relation` pr ON pr.secondpersonid=p.personid AND pr.deleted IS NULL 
LEFT JOIN `person` pg ON pg.personid=pr.firstpersonid
LEFT JOIN externalactivity ea ON ea.RecipientPersonID=pg.personid AND ea.ExternalID = 13312
WHERE ea.ExternalActivityID IS NULL 
order by p.lastname;
