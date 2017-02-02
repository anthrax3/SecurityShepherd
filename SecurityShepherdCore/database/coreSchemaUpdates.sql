USE `core` ;

-- This file contains non-reversible schema changes, to be run after coreSchema.sql

-- add nullable column for week
ALTER TABLE modules ADD week INT;

-- alteration of original stored proc to support returning week
DROP PROCEDURE `core`.`moduleTournamentOpenInfo`;

DELIMITER $$

CREATE PROCEDURE `core`.`moduleTournamentOpenInfo` (IN theUserId VARCHAR(64))
BEGIN
(SELECT moduleNameLangPointer, moduleCategory, moduleId, finishTime, incrementalRank, scoreValue, week  FROM modules LEFT JOIN results USING (moduleId)
WHERE userId = theUserId AND moduleStatus = 'open') UNION (SELECT moduleNameLangPointer, moduleCategory, moduleId, null, incrementalRank, scoreValue, week FROM modules WHERE moduleId NOT IN (SELECT moduleId FROM modules JOIN results USING (moduleId) WHERE userId = theUserId AND moduleStatus = 'open') AND moduleStatus = 'open') ORDER BY week, incrementalRank, scoreValue, moduleNameLangPointer;
END


$$
