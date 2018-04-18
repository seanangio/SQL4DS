--Pull a list of customer ids with the customer’s full name, and address, along with combining their city and country together. Be sure to make a space in between these two and make it UPPER CASE.
SELECT CustomerId
, FirstName || ' ' || LastName AS Name
, Address
, UPPER(City || ' ' || Country) AS City_Country
FROM Customers;

--Create a new employee user id by combining the first 4 letter of the employee’s first name with the first 2 letters of the employee’s last name. Make the new field lower case and pull each individual step to show your work.
SELECT LastName
, FirstName
, LOWER(SUBSTR(FirstName, 1, 4) || SUBSTR(LastName, 1, 2)) AS user_id
FROM Employees;

--Show a list of employees who have worked for the company for 15 or more years using the current date function. Sort by lastname ascending.
SELECT EmployeeId
, FirstName
, LastName
, DATETIME('now') - HireDate AS YoE
FROM Employees
WHERE YoE >= YoE
ORDER BY LastName;

--Profiling the Customers table, answer the following question. Are there any columns with null values?
SELECT
COUNT(*) - COUNT(Fax) AS Fax,
COUNT(*) - COUNT(Phone) AS Phone,
COUNT(*) - COUNT(FirstName) AS FirstName,
COUNT(*) - COUNT(PostalCode) AS PostalCode,
COUNT(*) - COUNT(Company) AS Company,
COUNT(*) - COUNT(Address) AS Address
FROM Customers

--Find the cities with the most customers and rank in descending order.
SELECT City
, COUNT(City)
FROM Customers
GROUP BY City
ORDER BY COUNT(City) DESC;

--Create a new customer invoice id by combining a customer’s invoice id with their first and last name while ordering your query in the following order: firstname, lastname, and invoiceID.
SELECT i.InvoiceId, c.CustomerId, c.FirstName, c.LastName,
c.FirstName ||c.LastName || i.InvoiceId  AS new_id
FROM Invoices i
INNER JOIN Customers c
USING (CustomerId)
ORDER BY FirstName, LastName, InvoiceId;
