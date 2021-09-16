--- =====================================
--- DATABASE INFORMATION
--- =====================================
---
--- author: Franck Davy
--- release: v1.0
--- date: 2021/9/11
--- title: Lost & Found System
--- description: DBMS Project Course
---
---
---
--- =====================================
--- SETTING UP DATABASE AND TABLES
--- =====================================
---
TRUNCATE TABLE lost_found_sys.users CASCADE;
TRUNCATE TABLE lost_found_sys.groups CASCADE;
TRUNCATE TABLE lost_found_sys.logs CASCADE;
TRUNCATE TABLE lost_found_sys.centers CASCADE;
TRUNCATE TABLE lost_found_sys.posts CASCADE;
TRUNCATE TABLE lost_found_sys.items CASCADE;
TRUNCATE TABLE lost_found_sys.lost_found CASCADE;
TRUNCATE TABLE lost_found_sys.categories CASCADE;
TRUNCATE TABLE lost_found_sys.imgs CASCADE;
TRUNCATE TABLE lost_found_sys.pickups CASCADE;
---
DROP TABLE IF EXISTS lost_found_sys.users CASCADE;      --- Delete table users from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.groups CASCADE;     --- Delete table groups from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.logs CASCADE;       --- Delete table logs from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.centers CASCADE;    --- Delete table centers from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.posts CASCADE;      --- Delete table posts from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.items CASCADE;      --- Delete table items from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.lost_found CASCADE; --- Delete table lost_found from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.categories CASCADE; --- Delete table categories from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.imgs CASCADE;       --- Delete table imgs from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.pickups CASCADE;    --- Delete table pickups from lost_found_sys if it already exists
DROP DATABASE IF EXISTS lost_found_sys;                 --- Delete database lost_found_sys if it already exists
DROP USER IF EXISTS sys_admin, north_center, south_center, library_center, recharge_center, student_center, a_center, b_center, c_center, d_center, e_center;
DROP ROLE IF EXISTS center_admin;
---
--- =====================================
--- SCHEMAS CREATION
--- =====================================
DROP SCHEMA IF EXISTS lost_found_sys, center_schema CASCADE;    --- Dropping existing schemas
CREATE SCHEMA lost_found_sys;                                   --- Objects' container "lost_found_sys" for system administrator
CREATE SCHEMA center_schema;                                    --- Objects' container "center_schema" for each center administrator
---
--- =====================================
--- USER DEFINED TYPES
--- =====================================
---
DROP TYPE IF EXISTS
    lost_found_sys.grp,
    lost_found_sys.cntr,
    lost_found_sys.cntr_name,
    lost_found_sys.title,
    lost_found_sys.ctgry,
    lost_found_sys.describe,
    lost_found_sys.addr,
    lost_found_sys.i_type CASCADE;

CREATE TYPE lost_found_sys.grp AS ENUM ('grp_001@admin', 'grp_002@cent', 'grp_003@stu');                                                                                           --- Group's ID
CREATE TYPE lost_found_sys.cntr AS ENUM ('001@north', '002@south', '003@lib', '004@card', '005@union', '006@A', '007@B', '008@C', '009@D', '010@E');                               --- Center's ID
CREATE TYPE lost_found_sys.cntr_name AS ENUM ('ZHOU', 'CAINIAO', 'BOGR', 'FAUNA', 'ARIES', 'THEMOLD', 'REDBLUESEED', 'ARCHIPELAGO', 'BABAVOSS', 'WAVER');                          --- Center's name
CREATE TYPE lost_found_sys.title AS ENUM ('admin', 'student', 'center');                                                                                                           --- User's group
CREATE TYPE lost_found_sys.ctgry AS ENUM ('category1', 'category2', 'category3', 'category4', 'category5');                                                                        --- Categories
CREATE TYPE lost_found_sys.describe AS ENUM ('manages the entire system', 'can only post lost or found stuff', 'manages his center only');                                         --- Group description
CREATE TYPE lost_found_sys.addr AS ENUM ('North Campus', 'South Campus', 'Library', 'Card recharge Center', 'Student Union', 'A area', 'B area', 'C area', 'D area', 'E area');    --- center address
CREATE TYPE lost_found_sys.i_type AS ENUM ('lost', 'found');                                                                                                                       --- Item lost or found
---
--- =====================================
--- EXTENSIONS
--- =====================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; --- Extension for adding more randomize IDs than serial type (equivalent of the AUTO_INCREMENT in MySQL)
---
--- =====================================
--- CREATING DATABASE AND TABLES
--- =====================================
---
CREATE DATABASE lost_found_sys;
---
CREATE TABLE lost_found_sys.groups (
                                       group_id lost_found_sys.grp PRIMARY KEY,
                                       group_name lost_found_sys.title NOT NULL,
                                       center_name lost_found_sys.cntr_name DEFAULT NULL UNIQUE,
                                       description lost_found_sys.describe NOT NULL,
                                       allow_add BOOLEAN DEFAULT true,
                                       allow_delete BOOLEAN DEFAULT true,
                                       allow_modify BOOLEAN DEFAULT true,
                                       allow_import BOOLEAN DEFAULT false,
                                       allow_export BOOLEAN DEFAULT false,
                                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.centers (
                                        center_name lost_found_sys.cntr_name PRIMARY KEY NOT NULL,
                                        contacts TEXT [] NOT NULL,
                                        address lost_found_sys.addr NOT NULL,
                                        working_hours VARCHAR(20) NOT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.users (
                                      user_id uuid PRIMARY KEY,
                                      group_id lost_found_sys.grp NOT NULL,
                                      username VARCHAR(50) NOT NULL UNIQUE,
                                      password VARCHAR(512) NOT NULL,
                                      email VARCHAR(20),
                                      contact TEXT DEFAULT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.logs (
                                     log_id uuid PRIMARY KEY,
                                     user_id uuid NOT NULL,
                                     group_id lost_found_sys.grp NOT NULL,
                                     description VARCHAR(512) NOT NULL,
                                     time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.categories (
                                           category_id uuid PRIMARY KEY,
                                           category lost_found_sys.ctgry NOT NULL UNIQUE
);
--- =====================================
CREATE TABLE lost_found_sys.posts (
                                      post_id uuid PRIMARY KEY,
                                      user_id uuid NOT NULL,
                                      category_id uuid NOT NULL,
                                      title varchar(30) DEFAULT NULL,
                                      description VARCHAR(512) NOT NULL,
                                      category lost_found_sys.ctgry NOT NULL,
                                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.items (
                                      item_id uuid PRIMARY KEY,
                                      user_id uuid NOT NULL,
                                      status numeric(1) DEFAULT 0
);
--- =====================================
CREATE TABLE lost_found_sys.lost_found (
                                           item_id uuid NOT NULL,
                                           user_id uuid NOT NULL,
                                           type_desc lost_found_sys.i_type NOT NULL,
                                           item_location VARCHAR(100) NOT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.imgs (
                                     img_id uuid PRIMARY KEY,
                                     item_id uuid NOT NULL,
                                     description VARCHAR(50) NOT NULL,
                                     img bytea NOT NULL,
                                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.pickups (
                                        id uuid PRIMARY KEY,
                                        item_id uuid NOT NULL,
                                        center_name lost_found_sys.cntr_name DEFAULT NULL UNIQUE,
                                        picked_by TEXT DEFAULT NULL,
                                        pickup_at lost_found_sys.addr DEFAULT NULL,
                                        time TIME DEFAULT NULL
);
---
--- =====================================
--- INDEXES (QUERY OPTIMIZATION)
--- =====================================
---
--- indexes on groups table
DROP INDEX IF EXISTS idx_groups_id, idx_groups_id_name;
CREATE INDEX idx_groups_id ON lost_found_sys.groups(group_id);
CREATE INDEX idx_groups_id_name ON lost_found_sys.groups(group_id, group_name);
---
--- indexes on centers table
DROP INDEX IF EXISTS idx_centers_name;
CREATE INDEX idx_centers_name ON lost_found_sys.centers(center_name);
---
--- indexes on users table
DROP INDEX IF EXISTS idx_users_id, idx_users_ctid, idx_users_name;
CREATE INDEX idx_users_id ON lost_found_sys.users(user_id);
CREATE INDEX idx_users_ctid ON lost_found_sys.users(group_id);
CREATE INDEX idx_users_name ON lost_found_sys.users(username);
---
--- indexes on logs table
DROP INDEX IF EXISTS idx_logs_lid, idx_logs_gid, idx_logs_uid;
CREATE INDEX idx_logs_lid ON lost_found_sys.logs(log_id);
CREATE INDEX idx_logs_gid ON lost_found_sys.logs(group_id);
CREATE INDEX idx_logs_uid ON lost_found_sys.logs(user_id);
---
--- indexes on categories table
DROP INDEX IF EXISTS idx_categories_cat, idx_categories_catid;
CREATE INDEX idx_categories_cat ON lost_found_sys.categories(category);
CREATE INDEX idx_categories_catid ON lost_found_sys.categories(category_id, category);
---
--- indexes on items table
DROP INDEX IF EXISTS idx_items_id, idx_items_uid, idx_items_stat, idx_items_ustat;
CREATE INDEX idx_items_id ON lost_found_sys.items(item_id);
CREATE INDEX idx_items_uid ON lost_found_sys.items(user_id);
CREATE INDEX idx_items_stat ON lost_found_sys.items(status);
CREATE INDEX idx_items_ustat ON lost_found_sys.items(user_id, status) ;
---
--- indexes on lost_found table
DROP INDEX IF EXISTS idx_lost_found_id, idx_lost_found_loc;
CREATE INDEX idx_lost_found_id ON lost_found_sys.lost_found(item_id);
CREATE INDEX idx_lost_found_loc ON lost_found_sys.lost_found(item_location);
---
--- indexes on imgs table
DROP INDEX IF EXISTS idx_imgs_id;
CREATE INDEX idx_imgs_id ON lost_found_sys.imgs(item_id);
---
--- indexes on pickups table
DROP INDEX IF EXISTS idx_pickups_id, idx_pickups_ctid, idx_pickups_by, idx_pickups_at, idx_pickups_byat;
CREATE INDEX idx_pickups_id ON lost_found_sys.pickups(item_id);
CREATE INDEX idx_pickups_ctid ON lost_found_sys.pickups(center_name);
CREATE INDEX idx_pickups_by ON lost_found_sys.pickups(picked_by);
CREATE INDEX idx_pickups_at ON lost_found_sys.pickups(pickup_at);
CREATE INDEX idx_pickups_byat ON lost_found_sys.pickups(picked_by, pickup_at);
---
--- =====================================
--- SET TABLES CONSTRAINTS
--- =====================================
---
--- groups table
ALTER TABLE lost_found_sys.groups                                                                   ---
    ADD CONSTRAINT FK_groups FOREIGN KEY (center_name) REFERENCES lost_found_sys.centers            ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE NO ACTION;                                                              ---
--- =====================================
--- users table
ALTER TABLE lost_found_sys.users                                                                    ---
    ADD CONSTRAINT FK_groups                                                                        ---
        FOREIGN KEY (group_id) REFERENCES lost_found_sys.groups                                     ---
            ON UPDATE CASCADE
            ON DELETE CASCADE;                                                                  ---
--- =====================================
--- logs table
ALTER TABLE lost_found_sys.logs                                                                     ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES lost_found_sys.users                   ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE NO ACTION,                                                              ---
    ADD CONSTRAINT FK_groups FOREIGN KEY (group_id) REFERENCES lost_found_sys.groups                ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE NO ACTION;                                                              ---
--- =====================================
--- posts table
ALTER TABLE lost_found_sys.posts                                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES lost_found_sys.users                   ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE CASCADE,                                                                  ---
    ADD CONSTRAINT FK_categories FOREIGN KEY (category_id) REFERENCES lost_found_sys.categories     ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE CASCADE;                                                                  ---
--- =====================================
--- items table
ALTER TABLE lost_found_sys.items                                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES lost_found_sys.users                   ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE CASCADE;                                                                      ---
--- =====================================
--- lost_found table
ALTER TABLE lost_found_sys.lost_found                                                               ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES lost_found_sys.items                   ---
        ON UPDATE NO ACTION                                                                         ---
        ON DELETE NO ACTION,                                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES lost_found_sys.users                   ---
        ON UPDATE NO ACTION                                                                         ---
        ON DELETE NO ACTION;                                                                    ---
--- =====================================
--- imgs table
ALTER TABLE lost_found_sys.imgs                                                                     ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES lost_found_sys.items                   ---
        ON UPDATE CASCADE                                                                           ---
        ON DELETE CASCADE;                                                                      ---
--- =====================================
--- pickups table
ALTER TABLE lost_found_sys.pickups                                                                  ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES lost_found_sys.items                   ---
        ON UPDATE NO ACTION                                                                         ---
        ON DELETE NO ACTION,                                                                    ---
    ADD CONSTRAINT FK_centers FOREIGN KEY (center_name) REFERENCES lost_found_sys.centers           ---
        ON UPDATE NO ACTION                                                                         ---
        ON DELETE NO ACTION;                                                                    ---
---
--- =====================================
--- INSERTING DATA TO TABLES
--- =====================================
---
--- insert into centers table
INSERT INTO lost_found_sys.centers VALUES
                                       ('ZHOU', ARRAY [ '(123)-234566], [(463)-056554]' ], 'North Campus', '8:20 AM to 4:40 PM'),
                                       ('CAINIAO', ARRAY [ '(456)-234566], [(403)-259994]' ], 'South Campus', '8:20 AM to 4:40 PM'),
                                       ('BOGR', ARRAY [ '(789)-234566], [(463)-457454]' ], 'Library', '8:20 AM to 4:40 PM'),
                                       ('FAUNA', ARRAY [ '(101)-234566], [(663)-209854]' ], 'Card recharge Center', '8:20 AM to 4:40 PM'),
                                       ('ARIES', ARRAY [ '(213)-234566], [(400)-557454]' ], 'Student Union', '8:20 AM to 4:40 PM'),
                                       ('THEMOLD', ARRAY [ '(141)-234566], [(473)-159054]' ], 'A area', '8:20 AM to 4:40 PM'),
                                       ('REDBLUESEED', ARRAY [ '(516)-234566], [(030)-859234]' ], 'B area', '8:20 AM to 4:40 PM'),
                                       ('ARCHIPELAGO', ARRAY [ '(718)-234566], [(463)-650914]' ], 'C area', '8:20 AM to 4:40 PM'),
                                       ('BABAVOSS', ARRAY [ '(192)-234566], [(963)-757454]' ], 'D area', '8:20 AM to 4:40 PM'),
                                       ('WAVER', ARRAY [ '(212)-234566], [(773)-911454]' ], 'E area', '8:20 AM to 4:40 PM');
---
--- insert into groups table
INSERT INTO lost_found_sys.groups VALUES ('grp_001@admin', 'admin', 'ARIES', 'manages the entire system', true, true);
INSERT INTO lost_found_sys.groups VALUES ('grp_002@cent', 'center', 'ARCHIPELAGO', 'manages his center only');
INSERT INTO lost_found_sys.groups VALUES ('grp_003@stu', 'student', NULL, 'can only post lost or found stuff');
---
--- insert into users table
INSERT INTO lost_found_sys.users VALUES
                                     (uuid_generate_v4(), 'grp_003@stu', 'uglydavy', 'password1', 'uglydavy@mail.com', '(245)-65734523'),
                                     (uuid_generate_v4(), 'grp_002@cent', 'daniel', 'password2', 'daniel@mail.com', '(185)-65723777'),
                                     (uuid_generate_v4(), 'grp_002@cent', 'mike', 'password3', 'mike@mail.com', '(897)-61109823'),
                                     (uuid_generate_v4(), 'grp_003@stu', 'leila', 'password4', 'leila@mail.com', '(205)-89894523'),
                                     (uuid_generate_v4(), 'grp_003@stu', 'jonas', 'password5', 'jonas@mail.com', '(910)-88734599');
---
--- insert into users table
INSERT INTO lost_found_sys.categories VALUES
                                          (uuid_generate_v4(), 'category1'),
                                          (uuid_generate_v4(), 'category2'),
                                          (uuid_generate_v4(), 'category3'),
                                          (uuid_generate_v4(), 'category4'),
                                          (uuid_generate_v4(), 'category5');
---
---
--- =====================================
--- STORED PROCEDURES
--- =====================================
---
--- usp_posts procedure
DROP PROCEDURE IF EXISTS lost_found_sys.usp_posts;
CREATE OR REPLACE PROCEDURE lost_found_sys.usp_posts
(
    usp_username varchar,                       ---
    usp_title varchar,                          --- Declaring variable usp_title representing (posts.title) with default value null
    usp_desc varchar,                           --- Declaring variable usp_description representing (posts.description)
    usp_category lost_found_sys.ctgry,          --- Declaring variable representing posts.category
    usp_type_desc lost_found_sys.i_type,        --- Declaring variable representing posts.type_desc
    usp_location varchar,                       --- Declaring variable representing posts.item_location
    usp_img_desc varchar,                       --- Declaring variable representing imgs.description
    usp_img bytea                               --- Declaring variable representing imgs_img
)
AS $BODY$
DECLARE
    postID uuid = uuid_generate_v4();           --- Generating a unique ID for (posts.post_id)
    userID uuid;                                --- Declaring variable holding value of a specific categories.category_id users.user_id
    categoryID uuid;                            --- Declaring variable holding value of a specific categories.category_id
    itemID uuid = uuid_generate_v4();           --- Generating a unique ID for (items.item_id)
    imgID uuid = uuid_generate_v4();            --- Generating a unique ID for (imgs.img_id)
    pickupID uuid = uuid_generate_v4();         --- Generating a unique ID for (pickups.id)
BEGIN
    SELECT user_id INTO STRICT userID           --- Fetching unique ID of a specific user and assigning it to a variable (userID)
    FROM
        lost_found_sys.users
    WHERE
            username = usp_username;              --- Only selecting row matching the username

    SELECT category_id INTO STRICT categoryID   --- Fetching unique ID of a specific category and assigning it to a variable (categoryID)
    FROM
        lost_found_sys.categories
    WHERE
            category = usp_category;              --- Only selecting row matching our category

    INSERT INTO lost_found_sys.posts VALUES (postID, userID, categoryID, usp_title, usp_desc, usp_category);
    INSERT INTO lost_found_sys.items VALUES (itemID, userID);
    INSERT INTO lost_found_sys.lost_found VALUES (itemID, userID, usp_type_desc, usp_location);
    INSERT INTO lost_found_sys.imgs VALUES (imgID, itemID, usp_img_desc, usp_img);
    INSERT INTO lost_found_sys.pickups VALUES (pickupID, itemID);
END;
$BODY$ LANGUAGE plpgsql;
---
---
--- insert into posts, items, lost_found, imgs tables
call lost_found_sys.usp_posts
    (
        'uglydavy',
        'Lost Airpods 2',
        'I lost my airpods yesterday around the business center.',
        'category1',
        'lost',
        'Business Center',
        'airpods with green protective case',
        '~/Photos/img1.jpg'
    );
call lost_found_sys.usp_posts
    (
        'daniel',
        '',
        'I left my phone somewhere in south campus. i do not remember the exact location.',
        'category2',
        'lost',
        'Business Center',
        '',
        '~/Photos/img2.jpg'
    );
call lost_found_sys.usp_posts
    (
        'mike',
        'Textbook',
        'I found a desktop in our lab two days ago and no one has come to get it yet.',
        'category3',
        'found',
        'Library',
        'Physics Textbook',
        '~/Photos/img3.jpg'
    );
call lost_found_sys.usp_posts
    (
        'leila',
        'bag',
        'I left my bike at the canteen in E area. Please me find it',
        'category4',
        'lost',
        'Business Center',
        'little brown bag',
        '~/Photos/img4.jpg'
    );
call lost_found_sys.usp_posts
    (
        'jonas',
        'Lost my bike keys',
        'forgot my keys when I went to get some papers at the front desk of the student union.',
        'category5',
        'lost',
        'Student Union',
        '',
        '~/Photos/img5.jpg'
    );
---
--- usp_pickups procedure
DROP PROCEDURE IF EXISTS lost_found_sys.usp_pickups;
CREATE OR REPLACE PROCEDURE lost_found_sys.usp_pickups (itemID uuid, centerNAME lost_found_sys.cntr_name, pickedBY text, pickedAT lost_found_sys.addr)
AS $BODY$
DECLARE
    _ID uuid;
    pickedTIME time := LOCALTIME(0);
BEGIN
    SELECT id INTO STRICT _ID
    FROM
        lost_found_sys.pickups
    WHERE
            item_id = itemID;

    UPDATE
        lost_found_sys.pickups
    SET
        center_name = centerNAME,
        picked_by = pickedBY,
        pickup_at = pickedAT,
        time = pickedTIME
    WHERE
            id = _ID;
END;
$BODY$ LANGUAGE plpgsql;
---
---
call lost_found_sys.usp_pickups
    (
        '742ca27d-710c-4026-968e-c20dbd2327ae',
        'ZHOU',
        'Michael',
        'North Campus'
    );
call lost_found_sys.usp_pickups
    (
        'd339ada4-1401-494d-b2b7-37debda7738c',
        'CAINIAO',
        'Bjorn',
        'South Campus'
    );
call lost_found_sys.usp_pickups
    (
        '8955aacb-81c5-477f-a1a4-3e5e81dfbb1f',
        'REDBLUESEED',
        'Kafka',
        'Library'
    );
call lost_found_sys.usp_pickups
    (
        'cf8d044d-d1e8-4cc2-b0ec-519b86cac5cf',
        'BABAVOSS',
        'Florence',
        'Card recharge Center'
    );
call lost_found_sys.usp_pickups
    (
        '9e8b43d0-e4df-410a-8316-cbf6a93e698b',
        'FAUNA',
        'badriri',
        'Student Union'
    );
---
--- usp_goods procedure
DROP FUNCTION IF EXISTS lost_found_sys.usp_goods();
CREATE OR REPLACE FUNCTION lost_found_sys.usp_goods ()
    RETURNS TABLE (
                      user_id uuid,
                      item_id uuid,
                      username varchar,
                      post varchar,
                      body varchar,
                      category lost_found_sys.ctgry,
                      img bytea,
                      contact text,
                      status numeric,
                      created_at timestamp
                  )
AS $BODY$
DECLARE
    centers text [] := ARRAY ['ZHOU', 'CAINIAO', 'BOGR', 'FAUNA', 'ARIES', 'THEMOLD', 'REDBLUESEED', 'ARCHIPELAGO', 'BABAVOSS', 'WAVER'];
    center lost_found_sys.title := 'center';
    student lost_found_sys.title := 'student';
    name lost_found_sys.cntr_name;
BEGIN
    <<loop_in>>
    FOREACH name IN ARRAY centers LOOP
            RETURN QUERY
                SELECT
                    u.user_id,                           --- Rename column "u.user_id" as "user_id"
                    it.item_id,                          --- Rename column "it.item_id" as "item_id"
                    u.username,                          --- Rename column "u.username" as "username"
                    p.title,                             --- Rename column "p.title" as "post"
                    p.description,                       --- Rename column "p.description" as "body"
                    c.category,                          --- Rename column "c.category" as "category"
                    im.img,                              --- Rename column "im.img" as "img"
                    u.contact,                           --- Rename column "u.contact" as "contact"
                    it.status,                           --- Rename column "it.status" as "status"
                    p.created_at                         --- Rename column "p.created_at" as "created_at"
                FROM
                    lost_found_sys.posts p,              --- Rename table as "p"
                    lost_found_sys.items it,             --- Rename table items as "it"
                    lost_found_sys.users u,              --- Rename table users as "u"
                    lost_found_sys.imgs im,              --- Rename table imgs as "im"
                    lost_found_sys.categories c,         --- Rename table categories as "c"
                    lost_found_sys.groups g              --- Rename table groups as "g"
                WHERE
                            c.category_id = p.category_id       --- Joining category and posts tables by "category_id"
                        AND
                            p.user_id = u.user_id               --- Joining posts and users tables by "user_id"
                        AND
                            u.user_id = it.user_id              --- Joining users and items tables by "user_id"
                        AND
                            it.item_id = im.item_id             --- Joining items and images tables by "item_id"
                        AND
                            g.group_name = center               --- Display info from user of group center
                   OR
                            g.group_name = student              --- Display info from user of group student
                        AND
                            g.center_name = name                --- Displaying relevant info based on center's location
                ORDER BY
                    p.created_at;
            RETURN NEXT;
        END LOOP loop_in;
END;
$BODY$ LANGUAGE plpgsql;
---
---
--- =====================================
--- ACCESSIBILITY (VIEWS)
--- =====================================
---
--- lost_found_goods view
DROP VIEW IF EXISTS center_schema.lost_found_goods;
CREATE OR REPLACE VIEW center_schema.lost_found_goods  --- Create view lost_found_goods under "center_schema"
AS
select * from lost_found_sys.usp_goods();       --- Selecting data by calling procedure "center_schema.usp_goods()" as "usp_goods"
---
---
--- =====================================
--- ROLES AND GRANTS
--- =====================================
---
--- revoking access
-- REVOKE ALL ON DATABASE lost_found_sys FROM PUBLIC;                          --- revoke access & grants from public to users
-- REVOKE ALL ON SCHEMA public FROM PUBLIC;                                    --- revoke access & grants to public
-- REVOKE ALL ON SCHEMA center_schema FROM center_admin;
-- REVOKE ALL ON DATABASE lost_found_sys FROM center_admin;
-- REVOKE CONNECT ON DATABASE lost_found_sys FROM center_admin;
-- REVOKE CONNECT ON DATABASE lost_found_sys FROM sys_admin;
-- REVOKE ALL ON SCHEMA lost_found_sys FROM sys_admin;
-- REVOKE ALL ON SCHEMA public FROM sys_admin;
-- REVOKE ALL ON DATABASE lost_found_sys FROM sys_admin;
--- =====================================
--- users
CREATE USER sys_admin;                                                      --- Creating global role "center_admin" for each center admin
CREATE USER north_center;                                                   --- Creating north campus center admin with username "north_center"
CREATE USER south_center;                                                   --- Creating south campus center admin with username "south_center"
CREATE USER library_center;                                                 --- Creating librarian center admin with username "library_center"
CREATE USER recharge_center;                                                --- Creating Card recharge center admin with username "recharge_center"
CREATE USER student_center;                                                 --- Creating Student Union center admin with username "student_center"
CREATE USER a_center;                                                       --- Creating A-area center admin with username "a_center"
CREATE USER b_center;                                                       --- Creating B-area center admin with username "b_center"
CREATE USER c_center;                                                       --- Creating C-area center admin with username "c_center"
CREATE USER d_center;                                                       --- Creating D-area center admin with username "d_center"
CREATE USER e_center;                                                       --- Creating E-area center admin with username "e_center"
CREATE ROLE center_admin WITH LOGIN;                                        --- Creating system administrator with username "sys_admin"
--- =====================================
-- grants
GRANT CONNECT ON DATABASE lost_found_sys TO sys_admin;                      --- Granting database access to system administrator
GRANT USAGE ON SCHEMA public TO sys_admin;                                  --- Granting usage permission on public schema to system administrator
GRANT USAGE ON SCHEMA lost_found_sys TO sys_admin;                          --- Granting usage permission on database with schema "lost_found_sys" to system administrator
GRANT CREATE ON SCHEMA lost_found_sys TO sys_admin;                         --- Granting select, insert, update, truncate, drop, alter, etc.. to system administrator
---
GRANT center_admin TO
    south_center,                                                         --- Granting role "center administrator" to "north_center"
    library_center,                                                       --- Granting role "center administrator" to "south_center"
    recharge_center,                                                      --- Granting role "center administrator" to "library_center"
    student_center,                                                       --- Granting role "center administrator" to "recharge_center"
    a_center,                                                             --- Granting role "center administrator" to "student_center"
    b_center,                                                             --- Granting role "center administrator" to "a_center"
    c_center,                                                             --- Granting role "center administrator" to "b_center"
    d_center,                                                             --- Granting role "center administrator" to "c_center"
    e_center;                                                             --- Granting role "center administrator" to "d_center"
GRANT CONNECT ON DATABASE lost_found_sys TO center_admin;                   --- Granting database access to center administrator
GRANT USAGE ON SCHEMA center_schema TO center_admin;                        --- Granting usage on database with schema "center_schema" to center administrator
GRANT SELECT, UPDATE ON center_schema.lost_found_goods TO center_admin;     --- Granting select and update on view "lost_found_goods" to center administrator
--- =====================================
--- owners
ALTER TABLE lost_found_sys.groups OWNER TO sys_admin;                       --- Table "groups" is owned by system administrator
ALTER TABLE lost_found_sys.centers OWNER TO sys_admin;                      --- Table "centers" is owned by system administrator
ALTER TABLE lost_found_sys.users OWNER TO sys_admin;                        --- Table "users" is owned by system administrator
ALTER TABLE lost_found_sys.logs OWNER TO sys_admin;                         --- Table "logs" is owned by system administrator
ALTER TABLE lost_found_sys.posts OWNER TO sys_admin;                        --- Table "posts" is owned by system administrator
ALTER TABLE lost_found_sys.items OWNER TO sys_admin;                        --- Table "items" is owned by system administrator
ALTER TABLE lost_found_sys.lost_found OWNER TO sys_admin;                   --- Table "lost_found" is owned by system administrator
ALTER TABLE lost_found_sys.categories OWNER TO sys_admin;                   --- Table "categories" is owned by system administrator
ALTER TABLE lost_found_sys.imgs OWNER TO sys_admin;                         --- Table "imgs" is owned by system administrator
ALTER TABLE lost_found_sys.pickups OWNER TO sys_admin;                      --- Table "pickups" is owned by system administrator
---
ALTER TABLE center_schema.lost_found_goods OWNER TO center_admin;           --- View "lost_found_goods" is owned by center administrators
---
--- =====================================