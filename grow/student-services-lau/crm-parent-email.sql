SELECT distinct  pr.programid as 'prid', e.personid as 'pid', cf.filecount as 'LP', tppp.preferredname AS 'School of Record'
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
    JOIN person tppp ON tppp.personid=tpp.TPPayerPersonID

     LEFT JOIN ( -- 504/IEP info
        SELECT pf.personid, COUNT(pf.person_fileid) AS 'FileCount'
        FROM person_file pf 
        WHERE pf.is_confidential=1
        GROUP BY pf.personid) AS cf ON cf.personid=p.personid

WHERE s.semesterid  >=46 AND e.credithours > 0 AND e.statusid = 1 AND tpp.TPPayerID = 12612 -- h.begindate < DATE(NOW())
group by pid
order by pid;
