-- disable prework, enable main

USE `core` ;

UPDATE modules SET moduleStatus = 'closed' WHERE week = 0;
UPDATE modules SET moduleStatus = 'open' WHERE week >= 1;
COMMIT;
