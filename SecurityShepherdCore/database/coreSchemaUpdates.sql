USE `core` ;

-- This file contains non-reversible schema changes, to be run after coreSchema.sql

-- add nullable column for week
ALTER TABLE modules ADD week INT;

ALTER TABLE class ADD ordering INT;


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

DELIMITER $$

CREATE PROCEDURE `core`.`moduleTournamentOpenInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime, incrementalRank, scoreValue, week, moduleStatus FROM modules LEFT JOIN results USING (moduleId)
WHERE userId = theUserId) UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null, incrementalRank, scoreValue, week, moduleStatus FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId)) ORDER BY week, incrementalRank, scoreValue, moduleNameLangPointer;
END
$$

CREATE PROCEDURE `core`.`classesGetData` ()
BEGIN
    SELECT classId, className, classYear FROM class ORDER BY ordering, className;
END
$$


