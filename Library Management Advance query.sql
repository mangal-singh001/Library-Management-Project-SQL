USE library;

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURDATE() - INTERVAL 24 day, '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURDATE() - INTERVAL 13 day,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURDATE() - INTERVAL 7 day,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURDATE() - INTERVAL 32 day,  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;




/*
Task 13: Identify Members with overdue books 
Write a query to identify numbers who have overdue books (assume a 30-day return period).
Display the member's_id ,member's name , book title, issue date, date overdue .
*/


-- issued_status == members == books == return_status 
-- filter books which is return 

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    rs.return_date,
    CURDATE() - ist.issued_date AS over_dues_days
FROM
    issued_status AS ist
        JOIN
    members AS m ON m.member_id = ist.issued_member_id
        JOIN
    books AS bk ON bk.isbn = ist.issued_book_isbn
        LEFT JOIN
    return_status AS rs ON rs.issued_id = ist.issued_id
WHERE
    rs.return_date IS NULL
ORDER BY 1;



/*
Task 14: update a book status on return 
Write a query to update the status of books in the books table to 'Yes' when they are returned
(based on entries in the return_status table
*/

-- Update manually  

SELECT 
    *
FROM
    books
WHERE
    isbn = '978-0-451-52994-2';


--  Update the status no in the books table beacause this book is issued

UPDATE books 
SET 
    status = 'no'
WHERE
    isbn = '978-0-451-52994-2';
    

SELECT 
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-0-451-52994-2';
    
    
SELECT 
    *
FROM
    return_status
WHERE
    issued_id = 'IS130';
    
    

INSERT INTO return_status
(return_id,issued_id,return_date,book_quality)
VALUES 
('RS225','IS130',curdate(),'Good');

UPDATE books 
SET 
    status = 'no'
WHERE
    isbn = '978-0-451-52994-2';


UPDATE books 
SET 
    status = 'yes'
WHERE
    isbn = '978-0-451-52994-2';


-- Now every thing will be done automatically by using 
-- STORE PROCEDURES 

USE library;

DROP PROCEDURE IF EXISTS add_return_records;


DELIMITER //

CREATE PROCEDURE add_return_records (
    IN p_return_id VARCHAR(20),
    IN p_issued_id VARCHAR(30),
    IN p_book_quality VARCHAR(50)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(50);

    -- Insert into return_status
    INSERT INTO return_status (
        return_id, issued_id, return_date, book_quality
    )
    VALUES (
        p_return_id, p_issued_id, CURDATE(), p_book_quality
    );

    -- Get book details from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update books table to mark the book as returned
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Show thank-you message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS Message;
END;
//
 
DELIMITER ;

CALL add_return_records('RS138', 'IS135', 'Good');




/*
Task 15: Branch Performance Report 
Create a query that generates a performance report for each branch , showing the number of books
issued, the number of books returned, and the total revenue generated from book rentals.
*/


CREATE TABLE branch_performance_report
AS
SELECT 
	b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employess AS e
ON ist.issued_emp_id = e.emp_id
JOIN branch AS b 
ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN books AS bk
ON ist.issued_book_isbn = bk.isbn
group by 1,2;





/*
Task 16: Create a table of active members
Use the CTAS statement to create a new table active_members containing members who have issued 
at least one book in the last 2 years
*/ 


CREATE TABLE active_members AS SELECT * FROM
    members
WHERE
    member_id IN (SELECT DISTINCT
            issued_member_id
        FROM
            issued_status
        WHERE
            issued_date >= CURDATE() - INTERVAL 24 MONTH);
            
            
            

/*
Task 17: Find employees with the most book issues processed
Write a query to find the top 3 employees who have processed the most book issues. Display 
the employee name, number of books processed and their branch .
*/

SELECT 
    e.emp_name, b.*, COUNT(ist.issued_id) AS no_book_issued
FROM
    issued_status AS ist
        JOIN
    employess AS e ON ist.issued_emp_id = e.emp_id
        JOIN
    branch AS b ON e.branch_id = b.branch_id
GROUP BY 1 , 2
ORDER BY no_book_issued DESC
LIMIT 3;



/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based 
on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be
updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message 
indicating that the book is currently not available.
*/



DELIMITER //

CREATE PROCEDURE issue_book(
	IN p_issued_id VARCHAR(20),
    IN p_issued_member_id VARCHAR(40),
	IN p_issued_book_isbn VARCHAR(40),
    IN p_issued_emp_id VARCHAR(20))
BEGIN
-- declare all the variable 
		DECLARE v_status VARCHAR(20);
    
-- all the code 
	-- checking if books is available 'yes'
    SELECT STATUS 
	INTO v_status
	FROM books 
    WHERE isbn = p_issued_book_isbn;
    
    IF v_status = 'yes' THEN
		INSERT INTO issued_status(
			issued_id,
            issued_member_id,
            issued_date,
            issued_book_isbn,
			issued_emp_id)
		VALUES(
			p_issued_id,
            p_issued_member_id,
            CURDATE(),
            p_issued_book_isbn,
            p_issued_emp_id);
        
        UPDATE books 
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;
        
         -- Show thank-you message
		SELECT CONCAT('Book records added successfully for book isbn:', p_issued_book_isbn) 
        AS Message;
    
    
    else
		select concat('Sorry to inform you the book you have requested is unavailable book_isbn
        :',p_issued_book_isbn) AS Message;
    
    END IF;

    
END;
//
 
DELIMITER ;


select * from books;
-- '978-0-393-91257-8' - 'yes'
-- '978-0-553-29698-2' - 'no'

call issue_book('IS156','C108','978-0-393-91257-8','E104');f





SELECT isbn, status, LENGTH(status)
FROM books
WHERE isbn = '978-0-393-91257-8';











