DELIMITER ;

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `core` ;
CREATE SCHEMA IF NOT EXISTS `core` DEFAULT CHARACTER SET latin1 ;
USE `core` ;

SELECT "Creating Tables" FROM DUAL;

-- -----------------------------------------------------
-- Table `core`.`class`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`class` (
  `classId` VARCHAR(64) NOT NULL ,
  `className` VARCHAR(32) NOT NULL UNIQUE,
  `classYear` VARCHAR(5) NOT NULL ,
  PRIMARY KEY (`classId`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`users` (
  `userId` VARCHAR(64) NOT NULL ,
  `classId` VARCHAR(64) NULL ,
  `userName` VARCHAR(32) NOT NULL ,
  `userPass` VARCHAR(512) NOT NULL ,
  `userRole` VARCHAR(32) NOT NULL ,
  `badLoginCount` INT NOT NULL DEFAULT 0 ,
  `suspendedUntil` DATETIME NOT NULL DEFAULT '1000-01-01 00:00:00' ,
  `userAddress` VARCHAR(128) NULL ,
  `tempPassword` TINYINT(1)  NULL DEFAULT FALSE ,
  `userScore` INT NOT NULL DEFAULT 0 ,
  `goldMedalCount` INT NOT NULL DEFAULT 0 ,
  `silverMedalCount` INT NOT NULL DEFAULT 0 ,
  `bronzeMedalCount` INT NOT NULL DEFAULT 0 ,
  `badSubmissionCount` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`userId`) ,
  INDEX `classId` (`classId` ASC) ,
  UNIQUE INDEX `userName_UNIQUE` (`userName` ASC) ,
  CONSTRAINT `classId`
    FOREIGN KEY (`classId` )
    REFERENCES `core`.`class` (`classId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`modules`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`modules` (
  `moduleId` VARCHAR(64) NOT NULL ,
  `moduleName` VARCHAR(64) NOT NULL ,
  `moduleNameLangPointer` VARCHAR(64) NOT NULL UNIQUE,
  `moduleType` VARCHAR(16) NOT NULL ,
  `moduleCategory` VARCHAR(64) NULL ,
  `moduleCategoryLangPointer` VARCHAR(64) NULL ,
  `moduleResult` VARCHAR(256) NULL ,
  `moduleHash` VARCHAR(256) NULL UNIQUE,
  `moduleStatus` VARCHAR(16) NULL DEFAULT 'open' ,
  `incrementalRank` INT NULL DEFAULT 200,
  `scoreValue` INT NOT NULL DEFAULT 50 ,
  `scoreBonus` INT NOT NULL DEFAULT 5 ,
  `hardcodedKey` TINYINT(1) NOT NULL DEFAULT TRUE,
  `goldMedalAvailable` TINYINT(1) NOT NULL DEFAULT TRUE,
  `silverMedalAvailable` TINYINT(1) NOT NULL DEFAULT TRUE,
  `bronzeMedalAvailable` TINYINT(1) NOT NULL DEFAULT TRUE,
  PRIMARY KEY (`moduleId`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`results`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`results` (
  `userId` VARCHAR(64) NOT NULL ,
  `moduleId` VARCHAR(64) NOT NULL ,
  `startTime` DATETIME NOT NULL ,
  `finishTime` DATETIME NULL ,
  `csrfCount` INT NULL DEFAULT 0 ,
  `resultSubmission` LONGTEXT NULL ,
  `knowledgeBefore` INT NULL ,
  `knowledgeAfter` INT NULL ,
  `difficulty` INT NULL ,
  PRIMARY KEY (`userId`, `moduleId`) ,
  INDEX `fk_Results_Modules1` (`moduleId` ASC) ,
  CONSTRAINT `fk_Results_users1`
    FOREIGN KEY (`userId` )
    REFERENCES `core`.`users` (`userId` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Results_Modules1`
    FOREIGN KEY (`moduleId` )
    REFERENCES `core`.`modules` (`moduleId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`cheatsheet`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`cheatsheet` (
  `cheatSheetId` VARCHAR(64) NOT NULL ,
  `moduleId` VARCHAR(64) NOT NULL ,
  `createDate` DATETIME NOT NULL ,
  `solution` LONGTEXT NOT NULL ,
  PRIMARY KEY (`cheatSheetId`, `moduleId`) ,
  INDEX `fk_CheatSheet_Modules1` (`moduleId` ASC) ,
  CONSTRAINT `fk_CheatSheet_Modules1`
    FOREIGN KEY (`moduleId` )
    REFERENCES `core`.`modules` (`moduleId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `core`.`sequence`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `core`.`sequence` (
  `tableName` VARCHAR(32) NOT NULL ,
  `currVal` BIGINT(20) NOT NULL DEFAULT 282475249 ,
  PRIMARY KEY (`tableName`) )
ENGINE = InnoDB;

SELECT "Creating Procedures" FROM DUAL;

-- -----------------------------------------------------
-- procedure authUser
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`authUser` (IN theName VARCHAR(32), IN theHash VARCHAR(512))
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
SELECT userId, userName, userRole, badLoginCount, tempPassword, classId FROM `users`
    WHERE userName = theName
    AND userPass = SHA2(theHash, 512)
    AND suspendedUntil < theDate ;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userLock
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userLock` (theName VARCHAR(32))
BEGIN
DECLARE theDate DATETIME;
DECLARE untilDate DATETIME;
DECLARE theCount INT;

COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
-- Get the badLoginCount from users if they are not suspended already or account has attempted a login within the last 10 mins
SELECT badLoginCount FROM `users`
    WHERE userName = theName
    AND suspendedUntil < (theDate - '0000-00-00 00:10:00')
    INTO theCount;

SELECT suspendedUntil FROM `users`
    WHERE userName = theName
    AND suspendedUntil < (theDate - '0000-00-00 00:10:00')
    INTO untilDate;
IF (untilDate < theDate) THEN
    IF (theCount >= 3) THEN
        -- Set suspended until 30 mins from now
        UPDATE `users` SET
            suspendedUntil = TIMESTAMPADD(MINUTE, 30, theDate),
            badLoginCount = 0
            WHERE userName = theName;
        COMMIT;
    -- ELSE the user is already suspended, or theCount < 3
    ELSE
        -- Get user where their last bad login was within 10 mins ago
        SELECT COUNT(userId) FROM users
            WHERE userName = theName
            AND suspendedUntil < (theDate - '0000-00-00 00:10:00')
            INTO theCount;

        -- IF a user was counted then they are not suspended, but have attemped a bad login within 10 mins of their last
        IF (theCount > 0) THEN
            UPDATE `users` SET
                badLoginCount = (badLoginCount + 1),
                suspendedUntil = theDate
                WHERE userName = theName;
            COMMIT;
        -- ELSE this is the first time within 10 mins that this account has logged in bad
        ELSE
            UPDATE `users` SET
                badLoginCount = 1,
                suspendedUntil = theDate
                WHERE userName = theName;
            COMMIT;
        END IF;
    END IF;
END IF;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure suspendUser
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`suspendUser` (theId VARCHAR(64), theMins INT)
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
UPDATE `users` SET
    suspendedUntil = TIMESTAMPADD(MINUTE, theMins, theDate)
    WHERE userId = theId;
COMMIT;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure unSuspendUser
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`unSuspendUser` (theId VARCHAR(64))
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
UPDATE `users` SET
    suspendedUntil = theDate
    WHERE userId = theId;
COMMIT;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userFind
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userFind` (IN theName VARCHAR(32))
BEGIN
COMMIT;
SELECT userName, suspendedUntil FROM `users`
    WHERE userName = theName;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playerCount
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playerCount` ()
BEGIN
    COMMIT;
    SELECT count(userId) FROM users
        WHERE userRole = 'player';
END


$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userCreate
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userCreate` (IN theClassId VARCHAR(64), IN theUserName VARCHAR(32), IN theUserPass VARCHAR(512), IN theUserRole VARCHAR(32), IN theUserAddress VARCHAR(128), tempPass BOOLEAN)
BEGIN
    DECLARE theId VARCHAR(64);
    DECLARE theClassCount INT;
    DECLARE theDate DATETIME;

    COMMIT;
    SELECT NOW() FROM DUAL INTO theDate;
    -- If (Valid User Type) AND (classId = null or (Valid Class Id)) Then create user
    IF (theUserRole = 'player' OR theUserRole = 'admin') THEN
        IF (theClassId != null) THEN
            SELECT count(classId) FROM class
                WHERE classId = theClassId
                INTO theClassCount;
            IF (theClassCount != 1) THEN
                SELECT null FROM DUAL INTO theClassId;
            END IF;
        END IF;

        -- Increment sequence for users table
        UPDATE sequence SET
            currVal = currVal + 1
            WHERE tableName = 'users';
        COMMIT;
        SELECT SHA(CONCAT(currVal, tableName, theDate)) FROM sequence
            WHERE tableName = 'users'
            INTO theId;

        -- Insert the values, badLoginCount and suspendedUntil Values will use the defaults defined by the table
        INSERT INTO users (
                userId,
                classId,
                userName,
                userPass,
                userRole,
                userAddress,
                tempPassword
            ) VALUES (
                theId,
                theClassId,
                theUserName,
                SHA2(theUserPass, 512),
                theUserRole,
                theUserAddress,
                tempPass
            );
        COMMIT;
        SELECT null FROM DUAL;
    ELSE
        SELECT 'Invalid Role Type Detected' FROM DUAL;
    END IF;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userBadLoginReset
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userBadLoginReset` (IN theUserId VARCHAR(45))
BEGIN
    COMMIT;
    UPDATE users SET
        badLoginCount = 0
        WHERE userId = theUserId;
    COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userPasswordChange
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userPasswordChange` (IN theUserName VARCHAR(32), IN currentPassword VARCHAR(512), IN newPassword VARCHAR(512))
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
UPDATE users SET
    userPass = SHA2(newPassword, 512),
    tempPassword = FALSE
    WHERE userPass = SHA2(currentPassword, 512)
    AND userName = theUserName
    AND suspendedUntil < theDate;
COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userPasswordChangeAdmin
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userPasswordChangeAdmin` (IN theUserId VARCHAR(64), IN newPassword VARCHAR(512))
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL INTO theDate;
UPDATE users SET
    userPass = SHA2(newPassword, 512),
    tempPassword = TRUE
    WHERE userId = theUserId;
COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure classCreate
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
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
    INSERT INTO class VALUES (theId, theClassName, theClassYear);
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure classCount
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`classCount` ()
BEGIN
    SELECT count(ClassId) FROM class;
END$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure classesGetData
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`classesGetData` ()
BEGIN
    SELECT classId, className, classYear FROM class;
END$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure classFind
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`classFind` (IN theClassId VARCHAR(64))
BEGIN
    SELECT className, classYear FROM class
        WHERE classId = theClassId;
END$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playersByClass
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playersByClass` (IN theClassId VARCHAR(64))
BEGIN
    COMMIT;
    SELECT userId, userName, userAddress FROM users
        WHERE classId = theClassId
        AND userRole = 'player'
        ORDER BY userName;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playerUpdateClass
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playerUpdateClass` (IN theUserId VARCHAR(64), IN theClassId VARCHAR(64))
BEGIN
COMMIT;
UPDATE users SET
    classId = theClassId
    WHERE userId = theUserId
    AND userRole = 'player';
COMMIT;
SELECT userName FROM users
    WHERE userId = theUserId
    AND classId = theClassId
    AND userRole = 'player';
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playerFindById
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playerFindById` (IN playerId VARCHAR(64))
BEGIN
COMMIT;
SELECT userName FROM users
    WHERE userId = playerId
    AND userRole = 'player';
END$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playersWithoutClass
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playersWithoutClass` ()
BEGIN
    COMMIT;
    SELECT userId, userName, userAddress FROM users
        WHERE classId is NULL
        AND userRole = 'player'
        ORDER BY userName;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure playerUpdateClassToNull
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`playerUpdateClassToNull` (IN theUserId VARCHAR(45))
BEGIN
COMMIT;
UPDATE users SET
    classId = NULL
    WHERE userId = theUserId
    AND userRole = 'player';
COMMIT;
SELECT userName FROM users
    WHERE userId = theUserId
    AND classId IS NULL
    AND userRole = 'player';
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userUpdateRole
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userUpdateRole` (IN theUserId VARCHAR(64), IN theNewRole VARCHAR(32))
BEGIN
COMMIT;
UPDATE users SET
    userRole = theNewRole
    WHERE userId = theUserId;
COMMIT;
SELECT userName FROM users
    WHERE userId = theUserId;
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleCreate
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleCreate` (IN theModuleName VARCHAR(64), theModuleType VARCHAR(16), theModuleCategory VARCHAR(64), isHardcodedKey BOOLEAN, theModuleSolution VARCHAR(256))
BEGIN
DECLARE theId VARCHAR(64);
DECLARE theDate DATETIME;
DECLARE theLangPointer VARCHAR(64);
DECLARE theCategoryLangPointer VARCHAR(64);
COMMIT;
SELECT NOW() FROM DUAL
    INTO theDate;
SELECT REPLACE(LOWER(theModuleName), ' ', '.') FROM DUAL
	INTO theLangPointer;
SELECT REPLACE(LOWER(theModuleCategory), ' ', '.') FROM DUAL
	INTO theCategoryLangPointer;
IF (theModuleSolution IS NULL) THEN
    SELECT SHA2(theDate, 256) FROM DUAL
        INTO theModuleSolution;
END IF;
IF (isHardcodedKey IS NULL) THEN
    SELECT TRUE FROM DUAL
        INTO isHardcodedKey;
END IF;
IF (theModuleType = 'lesson' OR theModuleType = 'challenge') THEN
    -- Increment sequence for users table
    UPDATE sequence SET
        currVal = currVal + 1
        WHERE tableName = 'modules';
    COMMIT;
    SELECT SHA(CONCAT(currVal, tableName, theDate, theModuleName)) FROM sequence
        WHERE tableName = 'modules'
        INTO theId;
    INSERT INTO modules (
        moduleId, moduleName, moduleNameLangPointer, moduleType, moduleCategory, moduleCategoryLangPointer, moduleResult, moduleHash, hardcodedKey
    )VALUES(
        theId, theModuleName, theLangPointer, theModuleType, theModuleCategory, theCategoryLangPointer ,theModuleSolution, SHA2(CONCAT(theModuleName, theId), 256), isHardcodedKey
    );
    COMMIT;
    SELECT moduleId, moduleHash, moduleNameLangPointer, moduleCategoryLangPointer FROM modules
        WHERE moduleId = theId;
ELSE
    SELECT 'ERROR: Invalid module type submited' FROM DUAL;
END IF;

END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleAllInfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleAllInfo` (IN theType VARCHAR(64), IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategoryLangPointer, moduleId, finishTime
FROM modules LEFT JOIN results USING (moduleId) WHERE userId = theUserId AND moduleType = theType AND moduleStatus = 'open') UNION (SELECT moduleNameLangPointer, moduleCategoryLangPointer, moduleId, null FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleType = theType AND moduleStatus = 'open') AND moduleType = theType  AND moduleStatus = 'open') ORDER BY moduleCategoryLangPointer, moduleNameLangPointer;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure lessonInfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`lessonInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime
FROM modules LEFT JOIN results USING (moduleId) WHERE userId = theUserId AND moduleType = 'lesson' AND moduleStatus = 'open') UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleType = 'lesson' AND moduleStatus = 'open') AND moduleType = 'lesson'  AND moduleStatus = 'open') ORDER BY moduleNameLangPointer, moduleCategory, moduleNameLangPointer;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleGetResult
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetResult` (IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
SELECT moduleName, moduleResult FROM modules
    WHERE moduleId = theModuleId
    AND moduleResult IS NOT NULL;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleGetNameLocale
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetNameLocale` (IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
SELECT moduleNameLangPointer, moduleName FROM modules
    WHERE moduleId = theModuleId;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userUpdateResult
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userUpdateResult` (IN theModuleId VARCHAR(64), IN theUserId VARCHAR(64), IN theBefore INT, IN theAfter INT, IN theDifficulty INT, IN theAdditionalInfo LONGTEXT)
BEGIN
DECLARE theDate TIMESTAMP;
DECLARE theBonus INT;
DECLARE totalScore INT;
DECLARE medalInfo INT; -- Used to find out if there is a medal available
DECLARE goldMedalInfo INT;
DECLARE silverMedalInfo INT;
DECLARE bronzeMedalInfo INT;
COMMIT;
SELECT NOW() FROM DUAL
    INTO theDate;
-- Get current bonus and decrement the bonus value
SELECT 0 FROM DUAL INTO totalScore;
SELECT scoreBonus FROM modules
    WHERE moduleId = theModuleId
    INTO theBonus;
IF (theBonus > 0) THEN
    SELECT (totalScore + theBonus) FROM DUAL
        INTO totalScore;
    UPDATE modules SET
        scoreBonus = scoreBonus - 1
        WHERE moduleId = theModuleId;
    COMMIT;
END IF;

-- Medal Available?
SELECT count(moduleId) FROM modules
	WHERE moduleId = theModuleId
	AND (goldMedalAvailable = TRUE OR silverMedalAvailable = TRUE OR bronzeMedalAvailable = TRUE)
	INTO medalInfo;
COMMIT;

IF (medalInfo > 0) THEN
	SELECT count(moduleId) FROM modules WHERE moduleId = theModuleId AND goldMedalAvailable = TRUE INTO goldMedalInfo;
	IF (goldMedalInfo > 0) THEN
		UPDATE users SET goldMedalCount = goldMedalCount + 1 WHERE userId = theUserId;
		UPDATE modules SET goldMedalAvailable = FALSE WHERE moduleId = theModuleId;
		COMMIT;
	ELSE
		SELECT count(moduleId) FROM modules WHERE moduleId = theModuleId AND silverMedalAvailable = TRUE INTO silverMedalInfo;
		IF (silverMedalInfo > 0) THEN
			UPDATE users SET silverMedalCount = silverMedalCount + 1 WHERE userId = theUserId;
			UPDATE modules SET silverMedalAvailable = FALSE WHERE moduleId = theModuleId;
			COMMIT;
		ELSE
			SELECT count(moduleId) FROM modules WHERE moduleId = theModuleId AND bronzeMedalAvailable = TRUE INTO bronzeMedalInfo;
			IF (bronzeMedalInfo > 0) THEN
				UPDATE users SET bronzeMedalCount = bronzeMedalCount + 1 WHERE userId = theUserId;
				UPDATE modules SET bronzeMedalAvailable = FALSE WHERE moduleId = theModuleId;
				COMMIT;
			END IF;
		END IF;
	END IF;
END IF;

-- Get the Score value for the level
SELECT (totalScore + scoreValue) FROM modules
    WHERE moduleId = theModuleId
    INTO totalScore;

-- Update users score
UPDATE users SET
    userScore = userScore + totalScore
    WHERE userId = theUserId;
COMMIT;

-- Update result row
UPDATE results SET
    finishTime = theDate,
    `knowledgeBefore` = theBefore,
    `knowledgeAfter` = theAfter,
    `difficulty`  = theDifficulty,
    `resultSubmission` = theAdditionalInfo
    WHERE startTime IS NOT NULL
    AND finishTime IS NULL
    AND userId = theUserId
    AND moduleId = theModuleId;
COMMIT;
SELECT moduleName FROM modules
    JOIN results USING (moduleId)
    WHERE startTime IS NOT NULL
    AND finishTime IS NOT NULL
    AND userId = theUserId
    AND moduleId = theModuleId;
END $$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleGetHash
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetHash` (IN theModuleId VARCHAR(64), IN theUserId VARCHAR(64))
BEGIN
DECLARE theDate DATETIME;
DECLARE tempInt INT;
COMMIT;
SELECT NOW() FROM DUAL
    INTO theDate;
SELECT COUNT(*) FROM results
    WHERE userId = theUserId
    AND moduleId = theModuleId
    AND startTime IS NOT NULL
    INTO tempInt;
IF(tempInt = 0) THEN
    INSERT INTO results
        (moduleId, userId, startTime)
        VALUES
        (theModuleId, theUserId, theDate);
    COMMIT;
END IF;
SELECT moduleHash, moduleCategory, moduleType FROM modules
    WHERE moduleId = theModuleId AND moduleStatus = 'open';
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleGetResultFromHash
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetResultFromHash` (IN theHash VARCHAR(256))
BEGIN
COMMIT;
SELECT moduleResult FROM modules
    WHERE moduleHash = theHash;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure resultMessageByClass
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`resultMessageByClass` (IN theClassId VARCHAR(64), IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
SELECT userName, resultSubmission FROM results
    JOIN users USING (userId)
    JOIN class USING (classId)
    WHERE classId = theClassId
    AND moduleId = theModuleId;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure resultMessageSet
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`resultMessageSet` (IN theMessage VARCHAR(128), IN theUserId VARCHAR(64), IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
UPDATE results SET
    resultSubmission = theMessage
    WHERE moduleId = theModuleId
    AND userId = theUserId;
COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure resultMessagePlus
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`resultMessagePlus` (IN theModuleId VARCHAR(64), IN theUserId2 VARCHAR(64))
BEGIN
UPDATE results SET
    csrfCount = csrfCount + 1
    WHERE userId = theUserId2
    AND moduleId = theModuleId;
COMMIT;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure resultMessagePlus
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`csrfLevelComplete` (IN theModuleId VARCHAR(64), IN theUserId2 VARCHAR(64))
BEGIN
	DECLARE temp INT;
COMMIT;
SELECT csrfCount FROM results
    WHERE userId = theUserId2
    AND moduleId = theModuleId;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleGetIdFromHash
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetIdFromHash` (IN theHash VARCHAR(256))
BEGIN
COMMIT;
SELECT moduleId FROM modules
    WHERE moduleHash = theHash;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userGetNameById
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userGetNameById` (IN theUserId VARCHAR(64))
BEGIN
COMMIT;
SELECT userName FROM users
    WHERE userId = theUserId;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userGetIdByName
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userGetIdByName` (IN theUserName VARCHAR(64))
BEGIN
COMMIT;
SELECT userId FROM users
    WHERE userName = theUserName;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userClassId
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userClassId` (IN theUserName VARCHAR(64))
BEGIN
COMMIT;
SELECT classId FROM users
    WHERE userName = theUserName;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userBadSubmission
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userBadSubmission` (IN theUserId VARCHAR(64))
BEGIN
UPDATE users SET
    badSubmissionCount = badSubmissionCount + 1
    WHERE userId = theUserId;
COMMIT;
UPDATE users SET
	userScore = userScore - userScore/10
	WHERE userId = theUserId AND badSubmissionCount > 40 AND userScore > 5;
COMMIT;
UPDATE users SET
	userScore = userScore - 10
	WHERE userId = theUserId AND badSubmissionCount > 40 AND userScore <= 5;
COMMIT;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure resetUserBadSubmission
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`resetUserBadSubmission` (IN theUserId VARCHAR(64))
BEGIN
UPDATE users SET
    badSubmissionCount = 0
    WHERE userId = theUserId;
COMMIT;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleComplete
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleComplete` (IN theModuleId VARCHAR(64), IN theUserId VARCHAR(64))
BEGIN
DECLARE theDate DATETIME;
COMMIT;
SELECT NOW() FROM DUAL
    INTO theDate;
UPDATE results SET
    finishTime = theDate
    WHERE startTime IS NOT NULL
    AND moduleId = theModuleId
    AND userId = theUserId;
COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure cheatSheetCreate
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`cheatSheetCreate` (IN theModule VARCHAR(64), IN theSheet LONGTEXT)
BEGIN
DECLARE theDate DATETIME;
DECLARE theId VARCHAR(64);
    COMMIT;
    UPDATE sequence SET
        currVal = currVal + 1
        WHERE tableName = 'cheatSheet';
    COMMIT;
	SELECT NOW() FROM DUAL INTO theDate;

    SELECT SHA(CONCAT(currVal, tableName, theDate)) FROM `core`.`sequence`
        WHERE tableName = 'cheatSheet'
        INTO theId;

    INSERT INTO `core`.`cheatsheet`
        (cheatSheetId, moduleId, createDate, solution)
        VALUES
        (theId, theModule, theDate, theSheet);
    COMMIT;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleGetAll
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetAll` ()
BEGIN
COMMIT;
SELECT moduleId, moduleName, moduleType, moduleCategory FROM modules
    ORDER BY moduleType, moduleCategory, moduleName;
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure cheatSheetGetSolution
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`cheatSheetGetSolution` (IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
SELECT moduleName, solution FROM modules
    JOIN cheatsheet USING (moduleId)
    WHERE moduleId = theModuleID
    ORDER BY createDate DESC;
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleGetHashById
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleGetHashById` (IN theModuleId VARCHAR(64))
BEGIN
COMMIT;
SELECT moduleHash FROM modules
    WHERE moduleId = theModuleId;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userCheckResult
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userCheckResult` (IN theModuleId VARCHAR(64), IN theUserId VARCHAR(64))
BEGIN
COMMIT;
-- Returns a module Name if the user has not completed the module identified by moduleId
SELECT moduleName FROM results
    JOIN modules USING(moduleId)
    WHERE finishTime IS NULL
    AND startTime IS NOT NULL
    AND finishTime IS NULL
    AND userId = theUserId
    AND moduleId = theModuleId;
END


$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleIncrementalInfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleIncrementalInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime, incrementalRank FROM modules LEFT JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'open') UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null, incrementalRank FROM modules WHERE moduleStatus = 'open' AND moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId)) ORDER BY incrementalRank;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleFeedback
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleFeedback` (IN theModuleId VARCHAR(64))
BEGIN
SELECT userName, TIMESTAMPDIFF(MINUTE, finishTime, startTime)*(-1), difficulty, knowledgeBefore, knowledgeAfter, resultSubmission
	FROM modules
	LEFT JOIN results USING (moduleId)
  LEFT JOIN users USING (userId)
  WHERE moduleId = theModuleId;
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userProgress
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userProgress` (IN theClassId VARCHAR(64))
BEGIN
    COMMIT;
SELECT userName, count(finishTime), userScore FROM users JOIN results USING (userId) WHERE finishTime IS NOT NULL
AND classId = theClassId
GROUP BY userName UNION SELECT userName, 0, userScore FROM users WHERE classId = theClassId AND userId NOT IN (SELECT userId FROM users JOIN results USING (userId) WHERE classId = theClassId AND finishTime IS NOT NULL GROUP BY userName) ORDER BY userScore DESC;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure classScoreboard
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`classScoreboard` (IN theClassId VARCHAR(64))
BEGIN
    COMMIT;
SELECT userId, userName, userScore, goldMedalCount, silverMedalCount, bronzeMedalCount FROM users
	WHERE classId = theClassId AND userRole = 'player' AND userScore > 0
	ORDER BY userScore DESC, goldMedalCount DESC, silverMedalCount DESC, bronzeMedalCount DESC, userId ASC;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure totalScoreboard
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`totalScoreboard` ()
BEGIN
    COMMIT;
SELECT userId, userName, userScore, goldMedalCount, silverMedalCount, bronzeMedalCount FROM users
	WHERE userRole = 'player' AND userScore > 0
	ORDER BY userScore DESC, goldMedalCount DESC, silverMedalCount DESC, bronzeMedalCount DESC, userId ASC;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure userStats
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userStats` (IN theUserName VARCHAR(32))
BEGIN
DECLARE temp INT;
SELECT COUNT(*) FROM modules INTO temp;
SELECT userName, sum(TIMESTAMPDIFF(MINUTE, finishTime, startTime)*(-1)) AS "Time", CONCAT(COUNT(*),"/", temp) AS "Progress"
    FROM modules
    LEFT JOIN results USING (moduleId)
    LEFT JOIN users USING (userId)
    WHERE userName = theUserName AND resultSubmission IS NOT NULL
    GROUP BY userName;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure userStatsDetailed
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`userStatsDetailed` (IN theUserName VARCHAR(32))
BEGIN
DECLARE temp INT;
SELECT COUNT(*) FROM modules INTO temp;
SELECT userName, moduleName, TIMESTAMPDIFF(MINUTE, finishTime, startTime)*(-1) AS "Time"
    FROM modules
    LEFT JOIN results USING (moduleId)
    LEFT JOIN users USING (userId)
    WHERE userName = theUserName AND resultSubmission IS NOT NULL
    ORDER BY incrementalRank;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleOpenInfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleOpenInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleName, moduleCategory, moduleId, finishTime FROM modules LEFT JOIN results USING (moduleId)
WHERE userId = theUserId AND moduleStatus = 'open') UNION (SELECT moduleName, moduleCategory, moduleId, null FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'open') AND moduleStatus = 'open') ORDER BY moduleCategory, moduleName;
END

$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleClosednfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleClosednfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleName, moduleCategory, moduleId, finishTime
FROM modules LEFT JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'closed') UNION (SELECT moduleName, moduleCategory, moduleId, null FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'closed') AND moduleStatus = 'closed') ORDER BY moduleCategory, moduleName;
END
$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleTournamentOpenInfo
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleTournamentOpenInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime, incrementalRank, scoreValue FROM modules LEFT JOIN results USING (moduleId)
WHERE userId = theUserId AND moduleStatus = 'open') UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null, incrementalRank, scoreValue FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'open') AND moduleStatus = 'open') ORDER BY incrementalRank, scoreValue, moduleNameLangPointer;
END

$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure moduleSetStatus
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleSetStatus` (IN theModuleId VARCHAR(64), IN theStatus VARCHAR(16))
BEGIN
UPDATE modules SET
    moduleStatus = theStatus
    WHERE moduleId = theModuleId;
COMMIT;
END
$$

DELIMITER ;
-- -----------------------------------------------------
-- procedure moduleAllStatus
-- -----------------------------------------------------

DELIMITER $$
USE `core`$$
CREATE PROCEDURE `core`.`moduleAllStatus` ()
BEGIN
SELECT moduleId, moduleName, moduleStatus
    FROM modules;
END
$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
SELECT "Data for table `core`.`sequence`" FROM DUAL;
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
USE `core`;
INSERT INTO `core`.`sequence` (`tableName`, `currVal`) VALUES ('users', '282475249');
INSERT INTO `core`.`sequence` (`tableName`, `currVal`) VALUES ('cheatSheet', '282475299');
INSERT INTO `core`.`sequence` (`tableName`, `currVal`) VALUES ('class', '282475249');
INSERT INTO `core`.`sequence` (`tableName`, `currVal`) VALUES ('modules', '282475576');

COMMIT;

-- Default admin user

call userCreate(null, 'admin', 'password', 'admin', 'admin@securityShepherd.org', true);

-- Enable backup script

SELECT "Creating BackUp Schema" FROM DUAL;

DROP DATABASE IF EXISTS backup;
CREATE DATABASE backup;

SET GLOBAL event_scheduler = ON;
SET @@global.event_scheduler = ON;
SET GLOBAL event_scheduler = 1;
SET @@global.event_scheduler = 1;

USE core;
DELIMITER $$

drop event IF EXISTS update_status;

create event update_status
on schedule every 1 minute
do

BEGIN

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

drop table IF EXISTS `backup`.`users`;
drop table IF EXISTS `backup`.`class`;
drop table IF EXISTS `backup`.`modules`;
drop table IF EXISTS `backup`.`results`;
drop table IF EXISTS `backup`.`cheatsheet`;
drop table IF EXISTS `backup`.`sequence`;
-- -----------------------------------------------------
-- Table `core`.`class`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`class` (
  `classId` VARCHAR(64) NOT NULL ,
  `className` VARCHAR(32) NOT NULL ,
  `classYear` VARCHAR(5) NOT NULL ,
  PRIMARY KEY (`classId`) )
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `core`.`users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`users` (
  `userId` VARCHAR(64) NOT NULL ,
  `classId` VARCHAR(64) NULL ,
  `userName` VARCHAR(32) NOT NULL ,
  `userPass` VARCHAR(512) NOT NULL ,
  `userRole` VARCHAR(32) NOT NULL ,
  `badLoginCount` INT NOT NULL DEFAULT 0 ,
  `suspendedUntil` DATETIME NOT NULL DEFAULT '1000-01-01 00:00:00' ,
  `userAddress` VARCHAR(128) NULL ,
  `tempPassword` TINYINT(1)  NULL DEFAULT FALSE ,
  `userScore` INT NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`userId`) ,
  INDEX `classId` (`classId` ASC) ,
  UNIQUE INDEX `userName_UNIQUE` (`userName` ASC) ,
  CONSTRAINT `classId`
    FOREIGN KEY (`classId` )
    REFERENCES `backup`.`class` (`classId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `core`.`modules`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`modules` (
  `moduleId` VARCHAR(64) NOT NULL ,
  `moduleName` VARCHAR(64) NOT NULL ,
  `moduleType` VARCHAR(16) NOT NULL ,
  `moduleCategory` VARCHAR(64) NULL ,
  `moduleResult` VARCHAR(256) NULL ,
  `moduleHash` VARCHAR(256) NULL ,
  `incrementalRank` INT NULL ,
  `scoreValue` INT NOT NULL DEFAULT 50 ,
  `scoreBonus` INT NOT NULL DEFAULT 5 ,
  PRIMARY KEY (`moduleId`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`results`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`results` (
  `userId` VARCHAR(64) NOT NULL ,
  `moduleId` VARCHAR(64) NOT NULL ,
  `startTime` DATETIME NOT NULL ,
  `finishTime` DATETIME NULL ,
  `csrfCount` INT NULL DEFAULT 0 ,
  `resultSubmission` LONGTEXT NULL ,
  `knowledgeBefore` INT NULL ,
  `knowledgeAfter` INT NULL ,
  `difficulty` INT NULL ,
  PRIMARY KEY (`userId`, `moduleId`) ,
  INDEX `fk_Results_Modules1` (`moduleId` ASC) ,
  CONSTRAINT `fk_Results_users1`
    FOREIGN KEY (`userId` )
    REFERENCES `backup`.`users` (`userId` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Results_Modules1`
    FOREIGN KEY (`moduleId` )
    REFERENCES `backup`.`modules` (`moduleId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`cheatsheet`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`cheatsheet` (
  `cheatSheetId` VARCHAR(64) NOT NULL ,
  `moduleId` VARCHAR(64) NOT NULL ,
  `createDate` DATETIME NOT NULL ,
  `solution` LONGTEXT NOT NULL ,
  PRIMARY KEY (`cheatSheetId`, `moduleId`) ,
  INDEX `fk_CheatSheet_Modules1` (`moduleId` ASC) ,
  CONSTRAINT `fk_CheatSheet_Modules1`
    FOREIGN KEY (`moduleId` )
    REFERENCES `backup`.`modules` (`moduleId` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `core`.`sequence`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `backup`.`sequence` (
  `tableName` VARCHAR(32) NOT NULL ,
  `currVal` BIGINT(20) NOT NULL DEFAULT 282475249 ,
  PRIMARY KEY (`tableName`) )
ENGINE = InnoDB;



Insert into `backup`.`class` (Select * from `core`.`class`);
Insert into `backup`.`users` (Select * from `core`.`users`);
Insert into `backup`.`modules` (Select * from `core`.`modules`);
Insert into `backup`.`results` (Select * from `core`.`results`);
Insert into `backup`.`cheatsheet` (Select * from `core`.`cheatsheet`);
Insert into `backup`.`sequence` (Select * from `core`.`sequence`);

END $$

DELIMITER ;
