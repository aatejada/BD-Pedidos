--Ejercicio 1
--El top 10 de productos comprados por nombre, orden descendente por unidades vendidas

SELECT TOP 10 p.ProductName, sum(od.Quantity) AS [Units Sold]
FROM [Order Details] od
INNER JOIN [Products] p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY [Units Sold] DESC

--Ejercicio 2
--Encuentra el producto que tiene el segundo precio mas alto en la compañia
--Product ID 29, 123.79

--(n-1)
--1-1 = 0 --Posición 1
--2-1 = 1 --Posocion 2
--3-1=  2 --Posicion 3


USE Northwind
GO
SELECT ProductName, UnitPrice 
FROM [Products] p1
WHERE 0 = (SELECT COUNt(DISTINCT UnitPrice)
FROM Products p2
WHERE p2.UnitPrice > p1.UnitPrice)

--Ejercicio 3
--Crea un RANK de productos vendidos ordenado por ciudad y cantidad en USA

SELECT p.ProductName, c.City, od.Quantity,
DENSE_RANK () OVER (PARTITION BY c.City ORDER BY od.Quantity DESC) AS RANK
FROM [Customers] c
INNER JOIN [Orders] o on (c.CustomerID = o.CustomerID)
INNER JOIN [Order Details] od on (o.OrderID = od.OrderID)
INNER JOIN [Products] p on (od.ProductID = p.ProductID)
WHERE Country = 'USA'
AND c.City = 'Boise'
ORDER BY RANK ASC


--Ejercicio 4
--Encontrar las ordenes que tardaron mas de 2 dias en entregarse despues de ser realizadas por el usuario, donde el valor sea mayor de 10,000
--Mostrar numero de dias, fecha de la orden, customer ID y pais de envío

SELECT o.OrderID, o.CustomerID, o.OrderDate, o.ShippedDate, o.ShipCountry,
DATEDIFF(DAY, OrderDate, ShippedDate) AS Duration_to_Ship,
SUM(od.Quantity * od.UnitPrice) as [Total Sale Amount]
FROM [Orders] o
INNER JOIN [Order Details] od on o.OrderID = od.OrderID
WHERE DATEDIFF(DAY, OrderDate, ShippedDate) > 2
GROUP BY  o.OrderID, o.CustomerID, o.OrderDate, o.ShippedDate, o.ShipCountry
HAVING SUM(od.Quantity * od.UnitPrice)> 10000

--Ejercicio 5
--Encuentra el TOP 10 de clientes mas valiosos

SELECT TOP 10 c.CompanyName, c.Country, c.City,
SUM(od.Quantity * od.UnitPrice) as [Total Sale]
FROM [Customers] c
INNER JOIN [Orders] o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = '2017'
GROUP BY c.CompanyName, c.Country, c.City
ORDER BY [Total Sale] DESC

--Ejercicio 6
--Muestra los productos que generaron un monto total de venta mayor o igual $30,000 y muestra las unidades vendidas de cada producto en 2018


SELECT p.ProductName, sum(od.Quantity) as [Number of unites], sum(od.Quantity*od.UnitPrice) as [Total Sale Amount]
FROM [Orders] o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN [Products] p ON od.ProductID = p.ProductID
WHERE YEAR(o.OrderDate) = '2018'
GROUP BY p.ProductName
HAVING sum(od.Quantity*od.UnitPrice) >= 30000

--Ejercicio 7
--Clasifica a los clientes de acuerdo al total de ventas
-- >= 30000 Nivel A
-- >= 20000 y < 30000 Nivel B
-- <  20000 Nivel C


SELECT c.CompanyName,
SUM(od.Quantity * od.UnitPrice) as Total,

CASE
	WHEN (SUM(od.Quantity * od.UnitPrice) >= 30000) THEN 'A'
	WHEN (SUM(od.Quantity * od.UnitPrice) <  30000 AND SUM(od.Quantity * od.UnitPrice) >= 20000) THEN 'B'
	ELSE 'C'
	END AS LEVEL

FROM [Customers] c
INNER JOIN [Orders] o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY  c.CompanyName

--Ejercicio 8
--¿Qué clientes generaron ventas por arriba del promedio del total de ventas? Filtrar por año

SELECT c.CompanyName, c.City, c.Country,
SUM(od.Quantity * od.UnitPrice) as TOTAL

FROM [Customers] c
INNER JOIN [Orders] o ON (c.CustomerID = o.CustomerID)
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = '2017'
GROUP BY  c.CompanyName, c.City, c.Country
HAVING SUM(od.Quantity * od.UnitPrice) > (SELECT AVG(Quantity * UnitPrice) FROM [Order Details])
ORDER BY TOTAL DESC

--Ejercicio 9
--¿Qué clientes no han comprado en los ultimos 20 meses?

SELECT c.CompanyName, MAX(o.Orderdate),
DATEDIFF(MONTH, MAX(o.OrderDate), GETDATE()) AS [Months Since Last Order]

FROM [Customers] c
INNER JOIN [Orders] o ON c.CustomerID = o.CustomerID
GROUP BY c.CompanyName
HAVING DATEDIFF(MONTH, MAX(o.OrderDate), GETDATE()) > 20


--Ejercicio 10
--Número de ordenes por clientes

SELECT c.CompanyName,
(SELECT COUNT(OrderID) FROM [Orders] o 
where c.CustomerID = o.CustomerID ) as [Number of orders]
FROM [Customers] c
ORDER BY   [Number of orders] DESC

--Ejercicio 11
--Encuentra la duración de dias entre órdenes de cada cliente

SELECT a.CustomerID, a.OrderDate, b.OrderDate,
DATEDIFF(DAY, a.OrderDate, b.OrderDate) as [Days between two orders]
FROM [Orders] a
INNER JOIN [Orders] b ON a.OrderID = b.OrderID - 1

--Ejercicio 12
--Muestra los empleados con mas ventas
--Calcula un bonos por sus ventas del 2%


SELECT	TOP 3 e.FirstName + ' ' + e.LastName as [Full Name],
SUM(od.Quantity * od.UnitPrice) as [Total Sale],
ROUND(SUM(od.Quantity * od.UnitPrice)*0.02,0) as Bonus

FROM [Employees] e
INNER JOIN [Orders] o ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = '2018'
and MONTH(o.OrderDate) = '1'
GROUP BY e.FirstName + ' ' + e.LastName

--Ejercicio 13
--¿Cuantos empleados tienes por posicion y por ciudad?

SELECT title, city, count(EmployeeID)
FROM [Employees]
GROUP BY title, city, region

--Ejercicio 14
--¿Cuánto tiempo llevan trabajando tus empleados?

SELECT LastName, FirstName, Title,
DATEDIFF(YEAR, HireDate, GETDATE()) AS [Work years in the company]
FROM [Employees]

--Ejercicio 15
--¿Cuántos empleados son mmayores de 70 años?

SELECT FirstName, LastName, Title,
DATEDIFF(YEAR, BirthDate, GETDATE()) AS AGE
FROM [Employees]
WHERE DATEDIFF(YEAR, BirthDate, GETDATE()) >= 70



















