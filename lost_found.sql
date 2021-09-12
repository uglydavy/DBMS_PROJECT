--- =====================================
--- DATABASE INFORMATION
--- =====================================
---
--- author: uglydavy
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
DROP TABLE IF EXISTS lost_found_sys.users;      --- Delete table users from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.groups;     --- Delete table groups from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.logs;       --- Delete table logs from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.centers;    --- Delete table centers from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.posts;      --- Delete table posts from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.items;      --- Delete table items from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.lost_found; --- Delete table lost_found from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.categories; --- Delete table categories from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.imgs;       --- Delete table imgs from lost_found_sys if it already exists
DROP TABLE IF EXISTS lost_found_sys.pickups;    --- Delete table pickups from lost_found_sys if it already exists
DROP DATABASE IF EXISTS lost_found_sys;         --- Delete database lost_found_sys if it already exists
---
--- =====================================
--- CREATING DATABASE AND TABLES
--- =====================================
---
CREATE DATABASE lost_found_sys;
---
CREATE TABLE lost_found_sys.users (
    user_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id uuid NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(512) NOT NULL,
    email VARCHAR(20),
    contact TEXT
);
--- =====================================
CREATE TABLE lost_found_sys.groups (
    group_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_name title NOT NULL,
    description describe NOT NULL,
    allow_add BOOLEAN DEFAULT true,
    allow_delete BOOLEAN DEFAULT true,
    allow_modify BOOLEAN DEFAULT true,
    allow_import BOOLEAN NOT NULL,
    allow_export BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.logs (
    log_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    description VARCHAR(512) NOT NULL,
    time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.centers (
    center_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    contacts TEXT [] NOT NULL,
    address addr NOT NULL,
    working_hours VARCHAR(10) NOT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.posts (
    post_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    category_id uuid NOT NULL,
    title VARCHAR(30),
    description VARCHAR(512) NOT NULL,
    category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.items (
    item_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    status numeric(1) DEFAULT 0
);
--- =====================================
CREATE TABLE lost_found_sys.lost_found (
    item_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type_desc TEXT NOT NULL,
    item_location VARCHAR(100) NOT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.categories (
    category_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(30) NOT NULL
);
--- =====================================
CREATE TABLE lost_found_sys.imgs (
    img_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id uuid NOT NULL,
    description VARCHAR(50) NOT NULL,
    img bytea NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--- =====================================
CREATE TABLE lost_found_sys.pickups (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id uuid NOT NULL,
    center_id uuid NOT NULL,
    picked_by TEXT,
    pickup_at addr NOT NULL,
    time TIME DEFAULT CURRENT_TIME(HH:MIN)
);
---
--- =====================================
--- USER DEFINED TYPES
--- =====================================
---
CREATE TYPE title AS ENUM ('admin', 'student', 'center');                                                                                                           --- User's group
CREATE TYPE describe AS ENUM ('manages the entire system', 'can only post lost or found stuff', 'manages his center only');                                         --- Group description
CREATE TYPE addr AS ENUM ('North Campus', 'South Campus', 'Library', 'Card recharge Center', 'Student Union', 'A area', 'B area', 'C area', 'D area', 'E area');    --- center address
---
--- =====================================
--- SET TABLES CONSTRAINTS
--- =====================================
---
--- users table
ALTER TABLE lost_found_sys.users                                                    ---
    ADD CONSTRAINT FK_groups                                                        ---
        FOREIGN KEY (group_id) REFERENCES groups                                    ---
            ON UPDATE CASCADE
                ON DELETE CASCADE;                                                  ---
--- =====================================
--- logs table
ALTER TABLE lost_found_sys.logs                                                     ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users                  ---
        ON UPDATE CASCADE                                                           ---
                  ON DELETE NO ACTION,                                              ---
    ADD CONSTRAINT FK_groups FOREIGN KEY (group_id) REFERENCES groups               ---
        ON UPDATE CASCADE                                                           ---
                  ON DELETE NO ACTION;                                              ---
--- =====================================
--- posts table
ALTER TABLE lost_found_sys.posts                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users                  ---
        ON UPDATE CASCADE                                                           ---
                ON DELETE CASCADE,                                                  ---
    ADD CONSTRAINT FK_categories FOREIGN KEY (category_id) REFERENCES categories    ---
        ON UPDATE CASCADE                                                           ---
                ON DELETE CASCADE;                                                  ---
--- =====================================
--- items table
ALTER TABLE lost_found_sys.items                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users                  ---
        ON UPDATE CASCADE                                                           ---
            ON DELETE CASCADE;                                                      ---
--- =====================================
--- lost_found table
ALTER TABLE lost_found_sys.lost_found                                               ---
    ADD CONSTRAINT PK_lost_found PRIMARY KEY (item_id, user_id),                    ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES users                  ---
        ON UPDATE NO ACTION                                                         ---
            ON DELETE NO ACTION,                                                    ---
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users                  ---
        ON UPDATE NO ACTION                                                         ---
            ON DELETE NO ACTION;                                                    ---
--- =====================================
--- imgs table
ALTER TABLE lost_found_sys.imgs                                                     ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES items                  ---
        ON UPDATE CASCADE                                                           ---
            ON DELETE CASCADE;                                                      ---
--- =====================================
--- pickups table
ALTER TABLE lost_found_sys.pickups                                                  ---
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES users                  ---
        ON UPDATE NO ACTION                                                         ---
            ON DELETE NO ACTION,                                                    ---
    ADD CONSTRAINT FK_centers FOREIGN KEY (center_id) REFERENCES centers            ---
        ON UPDATE NO ACTION                                                         ---
            ON DELETE NO ACTION;                                                    ---
---
--- =====================================
--- SCHEMAS CREATION
--- =====================================
---
CREATE SCHEMA center_schema;    --- Objects' container "center_schema" for each center administrator
---
--- =====================================
--- ROLES AND GRANTS
--- =====================================
---
--- revoking access
REVOKE ALL ON DATABASE lost_found_sys FROM PUBLIC;                          --- revoke access & grants from public to users
REVOKE ALL ON SCHEMA public FROM PUBLIC;                                    --- revoke access & grants to public
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
GRANT OPTION TO sys_admin;                                                  --- Granting permission to create or remove users

GRANT center_admin TO
      south_center,                                                         --- Granting role "center administrator" to "north_center"
      library_center,                                                       --- Granting role "center administrator" to "south_center"
      recharge_center,                                                      --- Granting role "center administrator" to "library_center"
      student_center,                                                       --- Granting role "center administrator" to "recharge_center"
      a_center,                                                             --- Granting role "center administrator" to "student_center"
      b_center,                                                             --- Granting role "center administrator" to "a_center"
      c_center,                                                             --- Granting role "center administrator" to "b_center"
      d_center,                                                             --- Granting role "center administrator" to "c_center"
      e_center,                                                             --- Granting role "center administrator" to "d_center"
      center_admin;                                                         --- Granting role "center administrator" to "e_center"
GRANT CONNECT ON DATABASE lost_found_sys TO center_admin;                   --- Granting database access to center administrator
GRANT USAGE ON SCHEMA center_schema TO center_admin;                        --- Granting usage on database with schema "center_schema" to center administrator
GRANT SELECT, UPDATE ON center_schema.center_logs TO center_admin;          --- Granting select and update on view "center_logs" to center administrator
GRANT SELECT, UPDATE ON center_schema.center_users TO center_admin;         --- Granting select and update on view "center_users" to center administrator
GRANT SELECT, UPDATE ON center_schema.lost_found_goods TO center_admin;     --- Granting select and update on view "lost_found_goods" to center administrator
--- =====================================
--- owners
ALTER TABLE lost_found_sys.users OWNER TO sys_admin;                        --- Table "users" is owned by system administrator
ALTER TABLE lost_found_sys.groups OWNER TO sys_admin;                       --- Table "groups" is owned by system administrator
ALTER TABLE lost_found_sys.logs OWNER TO sys_admin;                         --- Table "logs" is owned by system administrator
ALTER TABLE lost_found_sys.centers OWNER TO sys_admin;                      --- Table "centers" is owned by system administrator
ALTER TABLE lost_found_sys.posts OWNER TO sys_admin;                        --- Table "posts" is owned by system administrator
ALTER TABLE lost_found_sys.items OWNER TO sys_admin;                        --- Table "items" is owned by system administrator
ALTER TABLE lost_found_sys.lost_found OWNER TO sys_admin;                   --- Table "lost_found" is owned by system administrator
ALTER TABLE lost_found_sys.categories OWNER TO sys_admin;                   --- Table "categories" is owned by system administrator
ALTER TABLE lost_found_sys.imgs OWNER TO sys_admin;                         --- Table "imgs" is owned by system administrator
ALTER TABLE lost_found_sys.pickups OWNER TO sys_admin;                      --- Table "pickups" is owned by system administrator
---
ALTER TABLE center_schema.center_logs OWNER TO center_admin;                --- View "center_logs" is owned by center administrators
ALTER TABLE center_schema.center_users OWNER TO center_admin;               --- View "center_users" is owned by center administrators
ALTER TABLE center_schema.lost_found_goods OWNER TO center_admin;           --- View "lost_found_goods" is owned by center administrators
---
--- =====================================
--- INSERTING DATA TO TABLES
--- =====================================
---
--- =====================================
--- STORED PROCEDURES
--- =====================================
---
--- =====================================
--- ACCESSIBILITY (VIEWS)
--- =====================================
---
--- center_logs view
CREATE VIEW center_schema.center_logs       --- Create view center_logs
    AS SELECT
        log_id,
        user_id,
        description,
        time
    FROM
         lost_found_sys.logs
    WITH CHECK OPTION;                      --- Prevent users from updating or deleting rows not available to the view
--- =====================================
--- center_users view
CREATE VIEW center_schema.center_users      --- Create view center_users
    AS SELECT
        user_id,
        username,
        email,
        contact
    FROM
         lost_found_sys.users
    WITH CHECK OPTION;                      --- Prevent users from updating or deleting rows not available to the view
--- =====================================
--- lost_found_goods view
CREATE VIEW center_schema.lost_found_goods  --- Create view lost_found_goods
    AS SELECT
        u.user_id AS user_id,               --- Rename column "u.user_id" as "user_id"
        it.item_id AS item_id,              --- Rename column "i.item_id" as "item_id"
        u.username AS username,             --- Rename column "u.username" as "username"
        p.title AS post,                    --- Rename column "p.title" as "post"
        p.description AS body,              --- Rename column "p.description" as "body"
        c.category AS category,             --- Rename column "c.category" as "category"
        im.img AS img,                      --- Rename column "im.img" as "img"
        u.contact AS contact,               --- Rename column "u.contact" as "contact"
        it.status AS status,                --- Rename column "it.status" as "status"
        p.created_at AS created_at          --- Rename column "p.created_at" as "created_at"
    FROM
         lost_found_sys.posts p,            --- Rename table as "p"
         lost_found_sys.items it,           --- Rename table items as "it"
         lost_found_sys.users u,            --- Rename table users as "u"
         lost_found_sys.imgs im,            --- Rename table imgs as "im"
         lost_found_sys.categories c,       --- Rename table categories as "c"
         lost_found_sys.groups g            --- Rename table groups as "g"
    WHERE
          c.category_id = p.category_id     --- Joining category and posts tables by "category_id"
    AND
          p.user_id = u.user_id             --- Joining posts and users tables by "user_id"
    AND
          u.user_id = it.user_id            --- Joining users and items tables by "user_id"
    AND
          it.item_id = im.item_id           --- Joining items and images tables by "item_id"
    AND
          g.group_name = 'center'           --- Display info from user of group center
    OR
          g.group_name = 'student'          --- Display info from user of group student
    WITH CHECK OPTION;                      --- Prevent users from updating or deleting rows not available to the view