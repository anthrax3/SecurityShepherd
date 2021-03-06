USE `core` ;

-- This file contains non-reversible schema changes, to be run after coreSchema.sql

-- add nullable column for week
ALTER TABLE modules ADD week INT;

ALTER TABLE class ADD ordering INT;
ALTER TABLE class ADD cohort INT;

ALTER TABLE users ADD cohort_member_id INT;


-- -----------------------------------------------------
-- Table `core`.`class_modules`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`class_modules` (
  `classId` VARCHAR(64) NOT NULL ,
  `moduleId` VARCHAR(64) NOT NULL ,
  `week` INT NOT NULL ,
  `moduleStatus` VARCHAR(16) NULL DEFAULT 'open' ,
  PRIMARY KEY (`classId`, `moduleId`) ,
  INDEX `fk_class_modules_index` (`moduleId` ASC) ,
  CONSTRAINT `fk_class_modules_classId`
    FOREIGN KEY (`classId` )
    REFERENCES `core`.`class` (`classId` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_class_modules_moduleId`
    FOREIGN KEY (`moduleId` )
    REFERENCES `core`.`modules` (`moduleId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- alteration of original stored proc to support returning week
DROP PROCEDURE `core`.`moduleTournamentOpenInfo`;
DROP PROCEDURE `core`.`classesGetData`;
DROP PROCEDURE `core`.`classCreate`;

DELIMITER $$

CREATE PROCEDURE `core`.`moduleTournamentOpenInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime, incrementalRank, scoreValue, week, moduleStatus FROM modules LEFT JOIN results USING (moduleId)
WHERE userId = theUserId) UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null, incrementalRank, scoreValue, week, moduleStatus FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId)) ORDER BY week, incrementalRank, scoreValue, moduleNameLangPointer;
END
$$

CREATE PROCEDURE `core`.`classCreate` (IN theClassName VARCHAR(32), IN theClassYear VARCHAR(5))
BEGIN
    DECLARE theId VARCHAR(64);
    COMMIT;
    UPDATE sequence SET
        currVal = currVal + 1
        WHERE tableName = 'users';
    COMMIT;
    SELECT SHA(CONCAT(currVal, tableName)) FROM sequence
        WHERE tableName = 'users'
        INTO theId;
    INSERT INTO class VALUES (theId, theClassName, theClassYear, 0, null);
END

$$

CREATE PROCEDURE `core`.`classCreateCohort` (IN theClassName VARCHAR(32), IN theClassYear VARCHAR(5), IN theCohortId INT(11))
BEGIN
    DECLARE theId VARCHAR(64);
    COMMIT;
    UPDATE sequence SET
        currVal = currVal + 1
        WHERE tableName = 'users';
    COMMIT;
    SELECT SHA(CONCAT(currVal, tableName)) FROM sequence
        WHERE tableName = 'users'
        INTO theId;
    INSERT INTO class VALUES (theId, theClassName, theClassYear, 0, theCohortId);
END

$$


CREATE PROCEDURE `core`.`classesGetData` ()
BEGIN
    SELECT classId, className, classYear FROM class ORDER BY ordering, className;
END
$$

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userProgressWeekly` (IN theClassId VARCHAR(64), IN theWeek INT(11))
BEGIN
    COMMIT;
SELECT userName, userAddress, count(finishTime) FROM users JOIN results USING (userId) WHERE finishTime IS NOT NULL
AND classId = theClassId
AND moduleId in (select moduleId from modules where week = theWeek)
GROUP BY userName UNION SELECT userName, userAddress, 0 FROM users WHERE classId = theClassId AND userId NOT IN (SELECT userId FROM users JOIN results USING (userId) WHERE classId = theClassId AND finishTime IS NOT NULL GROUP BY userName) ORDER BY userName DESC;END

$$

DELIMITER ;


DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userProgressByWeek` (IN theClassId VARCHAR(64))
BEGIN
    COMMIT;
SELECT userName, userAddress, cohort_member_id, count(finishTime) as total_complete,
count(if(week <= 1, finishTime, null)) as w1_complete,
count(if(week = 2, finishTime, null)) as w2_complete,
count(if(week = 3, finishTime, null)) as w3_complete,
count(if(week = 4, finishTime, null)) as w4_complete,
count(if(week = 5, finishTime, null)) as w5_complete,
count(if(week = 6, finishTime, null)) as w6_complete
FROM users
LEFT JOIN results USING (userId)
LEFT JOIN modules USING (moduleId)
WHERE finishTime IS NOT NULL
AND classId = theClassId
GROUP BY userName UNION SELECT userName, userAddress, cohort_member_id, 0, 0, 0, 0, 0, 0, 0 FROM users WHERE classId = theClassId AND userId NOT IN (SELECT userId FROM users JOIN results USING (userId) WHERE classId = theClassId AND finishTime IS NOT NULL GROUP BY userName) ORDER BY total_complete DESC, userAddress
INTO OUTFILE '/var/lib/mysql-files/progress.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';END

$$

DELIMITER ;
