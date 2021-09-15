CREATE DATABASE proc_async;
CREATE SCHEMA proc_async;
---
---
CREATE TABLE proc_async.corr (id uuid primary key, category text);
CREATE TABLE proc_async.tab1 (id uuid not null constraint id REFERENCES proc_async.corr on update cascade on delete cascade, name text, category text);
CREATE TABLE proc_async.tab2 (id uuid not null constraint id REFERENCES proc_async.corr on update cascade on delete cascade, age int, category text);
---
---
INSERT INTO proc_async.corr VALUES (uuid_generate_v4(), 'Music'), (uuid_generate_v4(), 'Art'), (uuid_generate_v4(), 'Development');
SELECT * FROM proc_async.corr;
---
---
CREATE OR REPLACE PROCEDURE proc_async.async (_CATEGORY text, _NAME text, _AGE int)
AS $BODY$
    DECLARE
        _ID uuid;
    BEGIN
        SELECT id INTO _ID FROM proc_async.corr WHERE category = _CATEGORY;
        INSERT INTO proc_async.tab1 VALUES (_ID, _NAME, _CATEGORY);
        INSERT INTO proc_async.tab2 VALUES (_ID, _AGE, _CATEGORY);
    END;
$BODY$ LANGUAGE plpgsql;
---
---
CALL proc_async.async('Music', 'Jonas Brothers', 20);
CALL proc_async.async('Art', 'Mona Lisa', 30);
CALL proc_async.async('Development', 'John Doe', 40);
---
---
SELECT * FROM proc_async.tab1;
SELECT * FROM proc_async.tab2;
---
---
DROP PROCEDURE IF EXISTS proc_async.async(_ID int, _NAME text, _AGE int);
DROP TABLE IF EXISTS proc_async.corr cascade;
DROP TABLE IF EXISTS proc_async.tab1;
DROP TABLE IF EXISTS proc_async.tab2;
DROP SCHEMA IF EXISTS proc_async cascade;
DROP DATABASE IF EXISTS proc_async;
