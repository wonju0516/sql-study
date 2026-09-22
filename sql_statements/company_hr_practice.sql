CREATE SCHEMA hr;
SET search_path TO hr;
CREATE TABLE hr.employees (
    id SERIAL PRIMARY KEY,
    name TEXT,
    position TEXT
);
INSERT INTO hr.employees (name, position)
VALUES ('Alice', 'Manager');

select * from hr.employees