-- https://redmine.williamsburglearning.com/issues/3132
CREATE OR REPLACE VIEW `sis_live`.`vw_t_sales_pipeline_semester` AS
SELECT cc.crmid, cc.personid,

    IF(cc.personid IS NULL, 0, 1) AS 'SIS Account', 
    IF(u.userid IS NULL, 0, 1) AS 'SIS Login', 
    IFNULL((SELECT MIN(DATE(ph.date)) 
            FROM person_history ph 
            WHERE ph.field='lastname' AND ph.old_value IS NULL AND ph.person_id=cc.personid
            GROUP BY ph.person_id), '') AS 'SIS Account Created',
    IFNULL(COUNT(DISTINCT(pr.secondpersonid)), 0) AS 'Children in SIS',
    IFNULL(COUNT(DISTINCT(sa.applicationid)), 0) AS 'Applications Started',
    IFNULL(COUNT(DISTINCT(ca.ApplicationID)), 0) AS 'Applications Completed',
    IFNULL(COUNT(DISTINCT(e.personid)), 0) AS 'New Children Registered', 
    IFNULL(SUM(sd.amount), 0) AS 'Gross 21F Sales'   

FROM crmcache cc
LEFT JOIN `user` u ON u.userid=cc.personid  
LEFT JOIN person_relation pr ON pr.firstpersonid=cc.personid AND pr.relationtype='Parent'
LEFT JOIN application sa ON sa.personid=pr.secondpersonid AND sa.ProgramApplicationID IN (18,19)      
LEFT JOIN application ca ON ca.personid=pr.secondpersonid AND ca.ProgramApplicationID IN (18,19) AND ca.ApplicationStatusID IN (      
    SELECT astat.applicationstatusid FROM applicationstatus astat WHERE astat.ProgramApplicationID In (18,19)       
        AND (astat.Status = "Ready for Review" OR astat.Status LIKE "Complete%"))
LEFT JOIN enrollment e ON e.personid=pr.secondpersonid AND e.statusid=1 AND e.credithours > 0 
    AND e.sectionid IN (SELECT sectionid FROM section WHERE semesterid=46)       
    AND e.personid NOT IN (SELECT DISTINCT(e.personid) FROM enrollment e JOIN section USING (sectionid) WHERE semesterid < 45)      
LEFT JOIN enrollmenttostudentdebit esd USING (enrollmentid)
LEFT JOIN studentdebit sd ON sd.studentdebitid=esd.StudentDebitID AND sd.obsolete=0

GROUP BY cc.crmid  
