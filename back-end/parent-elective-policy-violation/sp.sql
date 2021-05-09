DELIMITER $$
DROP PROCEDURE IF EXISTS pepve$$
CREATE PROCEDURE pepve()

BEGIN
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
DROP TEMPORARY TABLE IF EXISTS _all;
CREATE TEMPORARY TABLE IF NOT EXISTS _all
select  e.personid as 'id', p.lastname as 'lname', p.firstname as 'fname', s.classid as 'classid',
(SELECT CASE
	WHEN s.classid IN(203,204,205,206) THEN 'ILC Block'
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
WHERE s.classid in(251,439,711,784,868,203,204,205,206) AND e.statusid =1 AND s.semesterid =46 and tppe.TPPayerID = 12612
-- GROUP BY e.personid
UNION

/*
* LAU Students enrolled in any "LAU Funded..." courses
* Section IDs 36515,36517,3651 are all WL IS Electives
*/
SELECT e.personid as 'id', p.lastname as 'lname', p.firstname as 'fname',  s.classid as 'classid', dee.scheduledesc as 'class'
FROM enrollment e
join person p on p.personid = e.personid
JOIN section s USING (sectionid)
JOIN semester m ON m.semesterid=s.semesterid
JOIN `schedule` dee ON dee.sectionid=s.sectionid 
JOIN class c ON c.classid=s.classid
JOIN enrollmenttostudentdebit esd USING (enrollmentid)    
JOIN studentdebit sd USING (studentdebitid)    
JOIN thirdpartypayerengagement tppe USING (tppengagementid)
WHERE dee.scheduledesc LIKE "%LAU Funded%" AND e.statusid =1 AND m.semesterid =46 AND s.sectionid NOT IN(36515,36517,36519) and tppe.TPPayerID = 12612;
-- GROUP BY e.personid;

DROP TEMPORARY TABLE IF EXISTS _ilc; -- LAU students enrolled in ILC elective blocks
CREATE TEMPORARY TABLE IF NOT EXISTS _ilc
SELECT id as 'id', lname as 'lname', fname as 'fname', class as 'class', classid as 'classid'
	FROM _all 
WHERE classid IN(203,204,205,206);

select i.id, i.lname, i.fname, a.class from _ilc i
join _all a on a.id = i.id
where a.classid not in(203,204,205,206)
group by i.id
order by i.id;

-- select * from _ilc;



-- group by e.personid
-- HAVING COUNT(DISTINCT e.personid, s.classid) > 1

END$$
DELIMITER ;
CALL pepve();
