USE `core` ;

-- This file contains updates to existing instance data

UPDATE modules SET week = 1 WHERE incrementalRank < 45;
UPDATE modules SET week = 2 WHERE moduleNameLangPointer LIKE 'sql.injection%';
UPDATE modules SET week = 3 WHERE moduleNameLangPointer LIKE 'cross.site.scripting%';

UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'broken.session.management';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'session.management.challenge.1';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'session.management.challenge.2';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'session.management.challenge.3';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'cross.site.request.forgery';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'csrf.1';
UPDATE modules SET week = 4 WHERE moduleNameLangPointer = 'csrf.2';
-- fix ordering
update modules set incrementalRank = 116 where moduleNameLangPointer = 'cross.site.request.forgery';
update modules set incrementalRank = 117 where moduleNameLangPointer = 'csrf.1';

UPDATE modules set week = 5 where moduleNameLangPointer LIKE 'insecure.cryptographic.storag%';
UPDATE modules set week = 5 where moduleNameLangPointer LIKE 'pgp';
update modules set incrementalRank = 135 where moduleNameLangPointer = 'pgp';

UPDATE modules SET week = 6 WHERE moduleNameLangPointer in ('session.management.challenge.4','session.management.challenge.5','session.management.challenge.6','session.management.challenge.7','security.misconfiguration');

UPDATE modules SET week = 6 WHERE moduleNameLangPointer LIKE 'password.hashing%';

UPDATE modules SET moduleStatus = 'closed' WHERE week is null;
UPDATE modules SET moduleStatus = 'open' WHERE week is not null;

COMMIT;
