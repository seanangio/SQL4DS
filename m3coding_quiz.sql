--Using a subquery, find the names of all the tracks for the album "Californication".
SELECT Name
FROM Tracks
WHERE AlbumId IN (SELECT AlbumId
  FROM Albums
  WHERE Title = 'Californication');

--Find the total number of invoices for each customer along with the customer's full name, city and email.
SELECT C.CustomerId, COUNT(InvoiceId), FirstName, LastName, City, Email
FROM Customers C
LEFT JOIN Invoices I
ON C.CustomerId = I.CustomerId
GROUP BY C.CustomerId

--Retrieve the track name, album, artist, and trackID for all the albums.
SELECT T.Name As Track, Al.Title AS Album, Ar.Name AS Artist, T.TrackId
FROM Albums Al
LEFT JOIN Tracks T
Using (AlbumId)
LEFT JOIN Artists Ar
USING (ArtistId)

--Retrieve a list with the managers last name, and the last name of the employees who report to him or her.
SELECT e1.LastName AS MgrLastName, e2.LastName AS EmpLastName
FROM Employees e1, Employees e2
WHERE e1.EmployeeId = e2.ReportsTo

--Find the name and ID of the artists who do not have albums.
SELECT *
FROM Artists
WHERE ArtistId NOT IN (
  SELECT DISTINCT ArtistId
  FROM Albums)

--Use a UNION to create a list of all the employee's & customer's first names and last names ordered by the last name in descending order.
SELECT FirstName, LastName
FROM Customers
UNION
SELECT FirstName, LastName
FROM Employees
ORDER BY LastName DESC

--See if there are any customers who have a different city listed in their billing city versus their customer city.
SELECT DISTINCT CustomerId, City, BillingCity
FROM Customers
LEFT JOIN Invoices
USING (CustomerId)
WHERE City <> BillingCity
