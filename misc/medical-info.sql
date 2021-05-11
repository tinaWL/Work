SELECT ase.asedesc, aser.ResponseDate, aser.ResponseValue

  FROM `applicationstepelement` ase
  JOIN applicationstepelementresponse aser ON aser.ApplicationStepElementID = ase.applicationstepelementid

WHERE aser.responsevalue != '' AND aser.responsevalue != 'No' AND aser.responsevalue != 'Yes' AND (asedesc LIKE "%health%" OR asedesc LIKE "%medical%")  
ORDER BY `aser`.`ResponseValue`  ASC
