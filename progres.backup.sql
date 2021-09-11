--- =====================================
--- DATABASE INFORMATION
--- =====================================

--- author: Franck Davy
--- release: v1.0
--- date: 2021/9/11
--- title: Lost & Found System
--- description: DBMS Project Course



--- =====================================
--- SETTING UP DATABASE AND TABLES
--- =====================================

DROP TABLE IF EXISTS lost_found_sys.users;
DROP TABLE IF EXISTS lost_found_sys.groups;
DROP TABLE IF EXISTS lost_found_sys.logs;
DROP TABLE IF EXISTS lost_found_sys.centers;
DROP TABLE IF EXISTS lost_found_sys.posts;
DROP TABLE IF EXISTS lost_found_sys.items;
DROP TABLE IF EXISTS lost_found_sys.lost_found;
DROP TABLE IF EXISTS lost_found_sys.categories;
DROP TABLE IF EXISTS lost_found_sys.imgs;
DROP TABLE IF EXISTS lost_found_sys.pickups;
DROP DATABASE IF EXISTS lost_found_sys;

--- =====================================
--- CREATING DATABASE AND TABLES
--- =====================================

CREATE DATABASE lost_found_sys;

CREATE TABLE lost_found_sys.users (
    user_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id uuid NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(512) NOT NULL,
    email VARCHAR(20),
    contact TEXT
);

CREATE TYPE title AS ENUM ('admin', 'student', 'center');
CREATE TYPE describe AS ENUM ('manages the entire system', 'can only post lost or found stuff', 'manages his center only');
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

CREATE TABLE lost_found_sys.logs (
    log_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    group_id uuid NOT NULL,
    description VARCHAR(512) NOT NULL,
    time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE addr AS ENUM ('North Campus', 'South Campus', 'Library', 'Card recharge Center', 'Student Union', 'A area', 'B area', 'C area', 'D area', 'E area');
CREATE TABLE lost_found_sys.centers (
    center_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    contacts TEXT [] NOT NULL,
    address addr NOT NULL,
    working_hours VARCHAR(10) NOT NULL
);

CREATE TABLE lost_found_sys.posts (
    post_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    category_id uuid NOT NULL,
    title VARCHAR(30),
    description VARCHAR(512) NOT NULL,
    category VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lost_found_sys.items (
    item_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    status numeric(1) DEFAULT 0
);

CREATE TABLE lost_found_sys.lost_found (
    item_id uuid NOT NULL,
    user_id uuid NOT NULL,
    type_desc TEXT NOT NULL,
    item_location VARCHAR(100) NOT NULL
);

CREATE TABLE lost_found_sys.categories (
    category_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(30) NOT NULL
);

CREATE TABLE lost_found_sys.imgs (
    img_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id uuid NOT NULL,
    description VARCHAR(50) NOT NULL,
    img bytea NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE lost_found_sys.pickups (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id uuid NOT NULL,
    center_id uuid NOT NULL,
    picked_by TEXT,
    pickup_at addr NOT NULL,
    time TIME DEFAULT CURRENT_TIME(HH:MIN)
);

--- =====================================
--- SCHEMAS CREATION
--- =====================================
CREATE SCHEMA center_schema;

--- =====================================
--- SET TABLES CONSTRAINTS
--- =====================================

--- users table
ALTER TABLE lost_found_sys.users
    ADD CONSTRAINT FK_groups
        FOREIGN KEY (group_id) REFERENCES groups
            ON UPDATE CASCADE
                ON DELETE CASCADE;

--- logs table
ALTER TABLE lost_found_sys.logs
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users
        ON UPDATE CASCADE
                  ON DELETE NO ACTION,
    ADD CONSTRAINT FK_groups FOREIGN KEY (group_id) REFERENCES groups
        ON UPDATE CASCADE
                  ON DELETE NO ACTION;

--- posts table
ALTER TABLE lost_found_sys.posts
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users
        ON UPDATE CASCADE
                ON DELETE CASCADE,
    ADD CONSTRAINT FK_categories FOREIGN KEY (category_id) REFERENCES categories
        ON UPDATE CASCADE
                ON DELETE CASCADE;

--- items table
ALTER TABLE lost_found_sys.items
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users
        ON UPDATE CASCADE
            ON DELETE CASCADE;

--- lost_found table
ALTER TABLE lost_found_sys.lost_found
    ADD CONSTRAINT PK_lost_found PRIMARY KEY (item_id, user_id),
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES users
        ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    ADD CONSTRAINT FK_users FOREIGN KEY (user_id) REFERENCES users
        ON UPDATE NO ACTION
            ON DELETE NO ACTION;

--- imgs table
ALTER TABLE lost_found_sys.imgs
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES items
        ON UPDATE CASCADE
            ON DELETE CASCADE;

--- pickups table
ALTER TABLE lost_found_sys.pickups
    ADD CONSTRAINT FK_items FOREIGN KEY (item_id) REFERENCES users
        ON UPDATE NO ACTION
            ON DELETE NO ACTION,
    ADD CONSTRAINT FK_centers FOREIGN KEY (center_id) REFERENCES centers
        ON UPDATE NO ACTION
            ON DELETE NO ACTION;

--- =====================================
--- STORED PROCEDURES
--- =====================================

--- =====================================
--- ACCESSIBILITY (VIEWS)
--- =====================================

--- =====================================
--- ROLES AND GRANTS
--- =====================================

--- revoking access
REVOKE ALL ON SCHEMA public FROM PUBLIC;            --- revoke access & grants to public
REVOKE ALL ON DATABASE lost_found_sys FROM PUBLIC;  --- revoke access & grants from public to database

--- users
CREATE ROLE sys_admin WITH LOGIN;           --- Creating global role "center_admin" for each center admin
CREATE ROLE center_admin WITH LOGIN;        --- Creating system administrator with username "sys_admin"
CREATE USER north_center;                   --- Creating north campus center's admin with username "north_center"
CREATE USER south_center;                   --- Creating south campus center's admin with username "south_center"
CREATE USER library_center;                 --- Creating librarian center's admin with username "library_center"
CREATE USER recharge_center;                --- Creating Card recharge center's admin with username "recharge_center"
CREATE USER student_center;                 --- Creating Student Union center's admin with username "student_center"
CREATE USER a_center;                       --- Creating A-area center's admin with username "a_center"
CREATE USER b_center;                       --- Creating B-area center's admin with username "b_center"
CREATE USER c_center;                       --- Creating C-area center's admin with username "c_center"
CREATE USER d_center;                       --- Creating D-area center's admin with username "d_center"
CREATE USER e_center;                       --- Creating E-area center's admin with username "e_center"

-- grants
GRANT USAGE ON SCHEMA lost_found_sys TO sys_admin;      --- Granting usage on database with schema "lost_found_sys" to system administrator
GRANT USAGE ON SCHEMA center_schema TO center_admin;    --- Granting usage on database with schema "center_schema" to center administrator
GRANT center_admin TO north_center;                     --- GRANTING role "center_admin" to user center administrator
GRANT south_center TO center_admin;                     --- GRANTING role "south_center" to user center administrator
GRANT library_center TO center_admin;                   --- GRANTING role "library_center" to user center administrator
GRANT recharge_center TO center_admin;                  --- GRANTING role "recharge_center" to user center administrator
GRANT student_center TO center_admin;                   --- GRANTING role "student_center" to user center administrator
GRANT a_center TO center_admin;                         --- GRANTING role "a_center" to user center administrator
GRANT b_center TO center_admin;                         --- GRANTING role "b_center" to user center administrator
GRANT c_center TO center_admin;                         --- GRANTING role "c_center" to user center administrator
GRANT d_center TO center_admin;                         --- GRANTING role "d_center" to user center administrator
GRANT e_center TO center_admin;                         --- GRANTING role "e_center" to user center administrator


--- owners
ALTER TABLE lost_found_sys.users OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.groups OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.logs OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.centers OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.posts OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.items OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.lost_found OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.categories OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.imgs OWNER TO "kv.kn";
ALTER TABLE lost_found_sys.pickups OWNER TO "kv.kn";

--- center_schema
