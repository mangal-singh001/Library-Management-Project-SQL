-- Project Task

-- Task 1. Create a New Book Record -- '978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,
--         'yes', 'Harper Lee','J.B. Lippincott & Co.'

INSERT INTO books
(isbn,book_title,category,rental_price,status,author,publisher)
VALUES
('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,
'yes', 'Harper Lee','J.B. Lippincott & Co');


-- Task 2. Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';


-- Task 3. Delete a Record from the Issued Status Table 
-- Objective : Delete th record with issued id = 'ISI121' from the issued_status table.


DELETE FROM issued_status
WHERE issued_id = 'ISI121';


-- Task 4. Retrive All Books Issued by  a Specific Employee
-- Objective : Select all books issued by the employee with emp_id = 'E101'


SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5. List Members Who Have Issued more than one book 


SELECT 
    issued_emp_id, COUNT(issued_id) AS total_book_issued
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;


-- Task 6: Cretae Summary Tables: Used CTAS to generate new tables based on query results-each
-- books and total book_issued count


CREATE TABLE book_count 
AS 
SELECT 
	b.isbn, b.book_title, COUNT(ist.issued_id) AS no_issued 
FROM
    books AS b
        JOIN
    issued_status AS ist ON b.isbn = ist.issued_book_isbn
GROUP BY 1;


-- Task 7: Retrieve all books in a specific category


SELECT 
    *
FROM
    books
WHERE
    category = 'Classic';
    

-- Task 8: Find Total Rental income by Category 



SELECT 
    b.category, SUM(b.rental_price), COUNT(*)
FROM
    books AS b
        JOIN
    issued_status AS ist ON ist.issued_book_isbn = b.isbn
GROUP BY 1;


-- Task 9: List members who registered in the last 180 days:


SELECT * FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 day;



-- Task 10: List Employees with their branch manager's name and their branch details:


SELECT 
    e1.*, b.manager_id, e2.emp_name AS manager
FROM
    employess AS e1
        JOIN
    branch AS b ON b.branch_id = e1.branch_id
        JOIN
    employess AS e2 ON b.manager_id = e2.emp_id;
    
    

-- Task 11: Create a table of books with rental proce above a certain threshold 7USD


CREATE TABLE book_price_greater_than_7 AS SELECT * FROM
    books
WHERE
    rental_price > 7;


-- Task 12: Retrieve the list of books not yet returned 


SELECT DISTINCT
    ist.issued_book_name
FROM
    issued_status AS ist
        LEFT JOIN
    return_status AS rs ON ist.issued_id = rs.issued_id
WHERE
    rs.return_id IS NULL;
































