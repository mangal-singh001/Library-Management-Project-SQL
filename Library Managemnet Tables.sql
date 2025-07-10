 -- Library Management System Project 
 
 

CREATE DATABASE library;

USE library;

CREATE TABLE branch (
    branch_id VARCHAR(50) PRIMARY KEY,
    manager_id VARCHAR(50),
    branch_address VARCHAR(55),
    contact_no VARCHAR(50)
);

CREATE TABLE employess (
    emp_id VARCHAR(50) PRIMARY KEY,
    emp_name VARCHAR(50),
    position VARCHAR(50),
    salary INT,
    branch_id VARCHAR(50)  -- FK
);


CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(75),
    category VARCHAR(20),
    rental_price FLOAT,
    status VARCHAR(20),
    author VARCHAR(40),
    publisher VARCHAR(60)
);

CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(20),
    member_address VARCHAR(20),
    reg_date DATE
);


CREATE TABLE issued_status (
    issued_id VARCHAR(20) PRIMARY KEY,
    issued_member_id VARCHAR(20), -- FK
    issued_book_name VARCHAR(50),
    issued_date DATE,
    issued_book_isbn VARCHAR(20),  -- FK
    issued_emp_id VARCHAR(20)  -- FK
);

ALTER TABLE issued_status
MODIFY issued_book_name VARCHAR(50);

CREATE TABLE return_status (
    return_id VARCHAR(20) PRIMARY KEY,
    issued_id VARCHAR(20),  -- FK
    return_book_name VARCHAR(20),
    return_date DATE,
    return_book_isbn VARCHAR(20)
);


ALTER TABLE return_status
ADD CONSTRAINT fk_member
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_member_id
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employess(emp_id);

ALTER TABLE employess
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);





