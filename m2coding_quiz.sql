--All of the questions in this quiz refer to the open source Chinook Database.
--Find all the tracks that have a length of 5,000,000 milliseconds or more
SELECT Name
FROM Tracks
WHERE Milliseconds >= 5000000;

--Find all the invoices whose total is between $5 and $15 dollars.
SELECT *
From Invoices
WHERE Total BETWEEN 5 AND 15;

--Find all the customers from the following States: RJ, DF, AB, BC, CA, WA, NY.
SELECT *
FROM Customers
WHERE State IN ('RJ', 'DF', 'AB', 'BC', 'CA', 'WA', 'NY');

--Find all the invoices for customer 56 and 58 where the total was between $1.00 and $5.00.
SELECT *
From Invoices
WHERE CustomerId IN (56,58)
AND Total BETWEEN 1 AND 5;

--Find all the tracks whose name starts with 'All'.
SELECT *
FROM Tracks
WHERE Name LIKE 'All%';

--Find all the customer emails that start with "J" and are from gmail.com.
SELECT Email
FROM Customers
WHERE Email LIKE 'J%gmail.com';

--Find all the invoices from the billing city Brasilia, Edmonton, and Vancouver and sort in descending order by invoice ID.
SELECT *
FROM Invoices
WHERE BillingCity IN ('Brasilia', 'Edmonton', 'Vancouver')
ORDER BY InvoiceId DESC;

--Show the number of orders placed by each customer (hint: this is found in the invoices table) and sort the result by the number of orders in descending order.
SELECT COUNT(CustomerId) as cust_count
, CustomerId
, InvoiceId
FROM Invoices
GROUP BY CustomerId
ORDER BY cust_count DESC;

--Find the albums with 12 or more tracks.
SELECT *
FROM Tracks
GROUP BY AlbumId
HAVING COUNT(TrackId) >= 12;
