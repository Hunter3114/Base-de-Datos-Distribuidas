use AdventureWorks2022
go

/*
practicar e identificar dudas del tema de optimización de consultas.
*/

-- 1
SELECT p.Name AS Producto, sod.OrderQty, soh.OrderDate, c.Name AS Cliente
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE YEAR(soh.OrderDate) = 2014 AND p.ListPrice > 1000;
 
-- 2 realizado por el profesor en clase.
SELECT e.NationalIDNumber, p.FirstName, p.LastName, edh.DepartmentID,
       (SELECT AVG(rh.Rate) FROM HumanResources.EmployeePayHistory rh 
        WHERE rh.BusinessEntityID = e.BusinessEntityID) as PromedioSalario
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
WHERE edh.EndDate IS NULL;
 
-- 3
SELECT sod.SalesOrderID, p.ProductID, p.Name
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.CategoryID = 1 OR p.CategoryID = 2 OR p.CategoryID = 3 OR p.ListPrice > 500;
 
-- 4
SELECT YEAR(soh.OrderDate) AS Año, MONTH(soh.OrderDate) AS Mes,
       COUNT(*) AS TotalPedidos, SUM(sod.LineTotal) AS TotalVentas
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate);
 
-- 5
SELECT p.ProductID, p.Name, pc.Name AS Categoria
FROM Production.Product p
JOIN Production.ProductSubcategory pc ON p.ProductSubcategoryID = pc.ProductSubcategoryID
WHERE p.Name LIKE '%brake%' OR pc.Name LIKE '%road%';
 
-- 6
SELECT c.CustomerID, c.Name, COUNT(*) AS TotalPedidos
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
WHERE UPPER(c.Name) LIKE 'A%'
GROUP BY c.CustomerID, c.Name;
 
-- 7
SELECT TOP 100 sod.SalesOrderDetailID, sod.OrderQty, sod.UnitPrice, soh.OrderDate
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
ORDER BY soh.ShipDate DESC, sod.OrderQty DESC, sod.UnitPrice DESC;
 
-- 8
SELECT p.ProductID, p.Name, SUM(sod.OrderQty) AS TotalVendido
FROM Production.Product p
WHERE p.ProductID IN (
    SELECT sod.ProductID 
    FROM Sales.SalesOrderDetail sod
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate >= '2014-01-01'
    GROUP BY sod.ProductID
    HAVING SUM(sod.OrderQty) > 100
)
GROUP BY p.ProductID, p.Name;
 
-- 9
SELECT p.ProductID, p.Name,
       (SELECT COUNT(*) FROM Sales.SalesOrderDetail sod WHERE sod.ProductID = p.ProductID) AS VecesVendido,
       (SELECT SUM(sod.OrderQty * sod.UnitPrice) FROM Sales.SalesOrderDetail sod WHERE sod.ProductID = p.ProductID) AS Ingresos
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE psc.ProductCategoryID = 3;
 
-- 10
SELECT c.Name AS Cliente, p.Name AS Producto, 
       SUM(sod.OrderQty) AS Cantidad, SUM(sod.LineTotal) AS Total,
       DATEDIFF(day, soh.OrderDate, soh.ShipDate) AS DiasEnvio
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE DATEDIFF(day, soh.OrderDate, soh.ShipDate) > 5
  AND DATEPART(quarter, soh.OrderDate) = 2
  AND sod.LineTotal > 1000
GROUP BY c.Name, p.Name, soh.OrderDate, soh.ShipDate
ORDER BY Total DESC;

/*
    OPTIMIZACIÓN
    Rojas Hernández Ulises Dariel
*/

--1 Rojas
use AdventureWorks2022

SELECT p.Name AS Producto, sod.OrderQty, soh.OrderDate, c.Name AS Cliente
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
WHERE soh.OrderDate >= '20140101' AND soh.OrderDate < '20150101' 
  AND p.ListPrice > 1000;
--1.1
SELECT 
    p.Name AS Producto, 
    sod.OrderQty, 
    soh.OrderDate, 
    c.CustomerID AS Cliente
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod 
    ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh 
    ON sod.SalesOrderID = soh.SalesOrderID
JOIN Sales.Customer c 
    ON soh.CustomerID = c.CustomerID
WHERE soh.OrderDate >= '20140101' 
  AND soh.OrderDate < '20150101'
  AND p.ListPrice > 1000;

--2 Profesor


--3 Rojas
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

SELECT
    sod.SalesOrderID,
    p.ProductID,
    p.Name
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p
    ON p.ProductID = sod.ProductID
LEFT JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE psc.ProductCategoryID IN (1, 2, 3)
UNION ALL
SELECT
    sod.SalesOrderID,
    p.ProductID,
    p.Name
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p
    ON p.ProductID = sod.ProductID
LEFT JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
WHERE p.ListPrice > 500
  AND (psc.ProductCategoryID NOT IN (1, 2, 3) OR psc.ProductCategoryID IS NULL);

--Realizar una versión con indices ejecutables...


-- con inner join
/*
select
    sod.salesorderid,
    p.productid,
    p.name
from sales.salesorderdetail as sod
inner join production.product as p
    on p.productid = sod.productid
inner join production.productsubcategory as psc
    on p.productsubcategoryid = psc.productsubcategoryid
where psc.productcategoryid in (1, 2, 3)

union all

select
    sod.salesorderid,
    p.productid,
    p.name
from sales.salesorderdetail as sod
inner join production.product as p
    on p.productid = sod.productid
inner join production.productsubcategory as psc
    on p.productsubcategoryid = psc.productsubcategoryid
where p.listprice > 500
  and psc.productcategoryid not in (1, 2, 3);
  */
--4 Luis


--4 forma natural
--No se puede hacer nada con los indices agrupados apesar de tener
--un alto costo, ya que solo esta reconfigurando el material/herramientas
--a utilizar durante el scan
--SalesorderHeader
--drop index nc_includeOrderdate on Sales.SalesOrderHeader
create nonclustered index nc_includeOrderdate
on Sales.SalesOrderHeader(salesorderid) include (orderdate)

--salesorderdetail
create nonclustered index nc_includeSalesOrderID
on Sales.SalesOrderDetail(salesorderid) include(linetotal)

--lo que resta es ejecutar la consulta original...
--4 proponer dos indices no agrupodos 
--5 ANGEL
CREATE NONCLUSTERED INDEX IX_Product_Name_Subcat 
ON Production.Product (Name) 
INCLUDE (ProductSubcategoryID);
GO

SELECT p.ProductID, p.Name, pc.Name AS Categoria
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS pc 
    ON p.ProductSubcategoryID = pc.ProductSubcategoryID
WHERE p.Name LIKE 'brake%' 
   OR pc.Name LIKE 'road%';

--6 Luis


--7 ANGEL
SELECT TOP 100 
    sod.SalesOrderDetailID, 
    sod.OrderQty, 
    sod.UnitPrice, 
    soh.OrderDate
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh 
    ON sod.SalesOrderID = soh.SalesOrderID
ORDER BY soh.ShipDate DESC, sod.SalesOrderID DESC;

--8


--9


--10
/* Martes 24-03-2026*/
