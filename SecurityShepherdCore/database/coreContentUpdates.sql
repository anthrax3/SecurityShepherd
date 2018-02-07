-- This file contains updates to existing instance data

USE `core` ;

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

CALL classCreate('Cybersecurity University', '2017');
CALL classCreate('Cybersecurity University TAs', '2017');
CALL classCreate('Stanford University', '2017');
CALL classCreate('IITD Workshop', '2017');

update class set cohort = 121 where className = 'CyberSec' and classYear = '2017';

INSERT INTO class_modules (classId, moduleId, moduleStatus, week)
  SELECT
    '0ed75302b767616b3a1d52adbee7e70dccb83dcf' as classId,
    1 AS item_code,
    2 AS invoice_code,
    item_costprice
  FROM qa_items
  WHERE item_code = 1;


COMMIT;
