USE `core` ;

-- This file contains updates to existing instance data

UPDATE modules SET week = 1 WHERE incrementalRank < 45;
UPDATE modules SET week = 2 WHERE moduleNameLangPointer LIKE 'sql.injection%';
UPDATE modules SET week = 3 WHERE moduleNameLangPointer LIKE 'cross.site.scripting%';

UPDATE modules SET moduleStatus = 'closed' WHERE week is null;
UPDATE modules SET moduleStatus = 'open' WHERE week is not null;

COMMIT;
