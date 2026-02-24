use AdventureWorks2022
--EJEMPLO DEL PROFESOR
select name, cant
from Production.product p
join (select top 10 productid, sum(orderqty) cant
              from sales.SalesOrderDetail sod
			  group by productid
              order by cant desc) as T
on p.ProductID = t.ProductID
 
select soh.SalesOrderID, sod.ProductID, sod.OrderQty, soh.CustomerID
from sales.SalesOrderHeader soh join sales.SalesOrderDetail sod
on soh.SalesOrderID = sod.SalesOrderID
where year(OrderDate) = '2014'

-- Consulta01
SELECT TOP (10)
    p.Name AS NombreProducto,
    tp.CantidadTotalVendida,
    COALESCE(st.Name, CONCAT(pp.FirstName, ' ', pp.LastName)) AS NombreCliente,
    tp.AvgUnitPrice,
    p.ListPrice
FROM (
    SELECT
        sod.ProductID,
        SUM(sod.OrderQty) AS CantidadTotalVendida,
        AVG(sod.UnitPrice) AS AvgUnitPrice
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesOrderDetail AS sod
        ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate >= '20140101'
      AND soh.OrderDate <  '20150101'
    GROUP BY sod.ProductID
) AS tp
INNER JOIN Production.Product AS p
    ON p.ProductID = tp.ProductID
   AND p.ListPrice > 1000
CROSS APPLY (
    SELECT TOP (1)
        soh2.CustomerID
    FROM Sales.SalesOrderHeader AS soh2
    INNER JOIN Sales.SalesOrderDetail AS sod2
        ON sod2.SalesOrderID = soh2.SalesOrderID
    WHERE soh2.OrderDate >= '20140101'
      AND soh2.OrderDate <  '20150101'
      AND sod2.ProductID = tp.ProductID
    GROUP BY soh2.CustomerID
    ORDER BY SUM(sod2.OrderQty) DESC
) AS ctop
INNER JOIN Sales.Customer AS c
    ON c.CustomerID = ctop.CustomerID
LEFT JOIN Sales.Store AS st
    ON st.BusinessEntityID = c.StoreID
LEFT JOIN Person.Person AS pp
    ON pp.BusinessEntityID = c.PersonID
ORDER BY tp.CantidadTotalVendida DESC;


-- Consulta02
SELECT
    soh.SalesPersonID,
    SUM(soh.SubTotal) AS TotalVentas
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesTerritory AS st
    ON st.TerritoryID = soh.TerritoryID
WHERE st.Name = 'Northwest'
  AND soh.SalesPersonID IS NOT NULL
GROUP BY soh.SalesPersonID
ORDER BY TotalVentas DESC;

SELECT
    AVG(t.TotalVentasTerritorio) AS PromedioVentasTerritorio
FROM (
    SELECT
        soh.SalesPersonID,
        SUM(soh.SubTotal) AS TotalVentasTerritorio
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesTerritory AS st
        ON st.TerritoryID = soh.TerritoryID
    WHERE st.Name = 'Northwest'
      AND soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID
) AS t;

SELECT
    sp.BusinessEntityID AS SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS NombreEmpleado
FROM Sales.SalesPerson AS sp
INNER JOIN Person.Person AS p
    ON p.BusinessEntityID = sp.BusinessEntityID;

--

WITH VentasPorEmpleado AS (
    SELECT
        soh.SalesPersonID,
        SUM(soh.SubTotal) AS TotalVentasTerritorio
    FROM Sales.SalesOrderHeader AS soh
    INNER JOIN Sales.SalesTerritory AS st
        ON st.TerritoryID = soh.TerritoryID
    WHERE st.Name = 'Northwest'
      AND soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID
),
PromedioTerritorio AS (
    SELECT AVG(TotalVentasTerritorio) AS PromedioVentasTerritorio
    FROM VentasPorEmpleado
)
SELECT
    v.SalesPersonID,
    CONCAT(p.FirstName, ' ', p.LastName) AS NombreEmpleado,
    v.TotalVentasTerritorio,
    pt.PromedioVentasTerritorio
FROM VentasPorEmpleado AS v
CROSS JOIN PromedioTerritorio AS pt
INNER JOIN Sales.SalesPerson AS sp
    ON sp.BusinessEntityID = v.SalesPersonID
INNER JOIN Person.Person AS p
    ON p.BusinessEntityID = sp.BusinessEntityID
WHERE v.TotalVentasTerritorio > pt.PromedioVentasTerritorio
ORDER BY v.TotalVentasTerritorio DESC;

--- Consulta03
-- 03.01
SELECT
    st.Name AS Territorio,
    YEAR(soh.OrderDate) AS Anio,
    COUNT(DISTINCT soh.SalesOrderID) AS NumOrdenes,
    SUM(soh.SubTotal) AS VentasTotales
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesTerritory AS st
    ON st.TerritoryID = soh.TerritoryID
GROUP BY
    st.Name,
    YEAR(soh.OrderDate)
HAVING
    COUNT(DISTINCT soh.SalesOrderID) > 5
    AND SUM(soh.SubTotal) > 1000000
ORDER BY
    VentasTotales DESC;

-- 03.02

SELECT
    st.Name AS Territorio,
    YEAR(soh.OrderDate) AS Anio,
    COUNT(DISTINCT soh.SalesOrderID) AS NumOrdenes,
    SUM(soh.SubTotal) AS VentasTotales,
    STDEV(soh.SubTotal) AS DesvStdVentas
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesTerritory AS st
    ON st.TerritoryID = soh.TerritoryID
GROUP BY
    st.Name,
    YEAR(soh.OrderDate)
HAVING
    COUNT(DISTINCT soh.SalesOrderID) > 5
    AND SUM(soh.SubTotal) > 1000000
ORDER BY
    VentasTotales DESC;

-- Consulta04
    --04.01
    WITH ProdCat AS (
    SELECT p.ProductID
    FROM Production.Product p
    JOIN Production.ProductSubcategory psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory pc
        ON pc.ProductCategoryID = psc.ProductCategoryID
    WHERE pc.Name = 'Bikes'
    ),
    Vendio AS (
        SELECT DISTINCT
            soh.SalesPersonID,
        sod.ProductID
        FROM Sales.SalesOrderHeader soh
        JOIN Sales.SalesOrderDetail sod
            ON sod.SalesOrderID = soh.SalesOrderID
        JOIN ProdCat pc
            ON pc.ProductID = sod.ProductID
        WHERE soh.SalesPersonID IS NOT NULL
        )
    SELECT
        v.SalesPersonID,
        CONCAT(pp.FirstName, ' ', pp.LastName) AS Vendedor
    FROM Vendio v
        JOIN Person.Person pp
    ON pp.BusinessEntityID = v.SalesPersonID
    GROUP BY v.SalesPersonID, pp.FirstName, pp.LastName
    HAVING COUNT(*) = (SELECT COUNT(*) FROM ProdCat)
    ORDER BY Vendedor;

    --04.02
    WITH ProdCat AS (
    SELECT p.ProductID
    FROM Production.Product p
    JOIN Production.ProductSubcategory psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory pc
        ON pc.ProductCategoryID = psc.ProductCategoryID
    WHERE pc.ProductCategoryID = 4
),
Vendio AS (
    SELECT DISTINCT
        soh.SalesPersonID,
        sod.ProductID
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod
        ON sod.SalesOrderID = soh.SalesOrderID
    JOIN ProdCat pc
        ON pc.ProductID = sod.ProductID
    WHERE soh.SalesPersonID IS NOT NULL
)
SELECT
    v.SalesPersonID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS Vendedor
FROM Vendio v
JOIN Person.Person pp
    ON pp.BusinessEntityID = v.SalesPersonID
GROUP BY v.SalesPersonID, pp.FirstName, pp.LastName
HAVING COUNT(*) = (SELECT COUNT(*) FROM ProdCat)
ORDER BY Vendedor;
--Propuesta de carlitos

SELECT
    x.SalesPersonID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS Vendedor,
    pc.Name AS Categoria,
    COUNT(DISTINCT sod.ProductID) AS ProductosDistintosVendidos
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product AS p
    ON p.ProductID = sod.ProductID
INNER JOIN Production.ProductSubcategory AS psc
    ON psc.ProductSubcategoryID = p.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS pc
    ON pc.ProductCategoryID = psc.ProductCategoryID
INNER JOIN Person.Person AS pp
    ON pp.BusinessEntityID = soh.SalesPersonID
INNER JOIN (
    -- vendedores que vendieron TODOS los productos de CategoryID=4
    SELECT soh2.SalesPersonID
    FROM Sales.SalesOrderHeader AS soh2
    INNER JOIN Sales.SalesOrderDetail AS sod2
        ON sod2.SalesOrderID = soh2.SalesOrderID
    INNER JOIN Production.Product AS p2
        ON p2.ProductID = sod2.ProductID
    INNER JOIN Production.ProductSubcategory AS psc2
        ON psc2.ProductSubcategoryID = p2.ProductSubcategoryID
    INNER JOIN Production.ProductCategory AS pc2
        ON pc2.ProductCategoryID = psc2.ProductCategoryID
    WHERE soh2.SalesPersonID IS NOT NULL
      AND pc2.ProductCategoryID = 4
    GROUP BY soh2.SalesPersonID
    HAVING COUNT(DISTINCT sod2.ProductID) =
    (
        SELECT COUNT(DISTINCT p3.ProductID)
        FROM Production.Product AS p3
        INNER JOIN Production.ProductSubcategory AS psc3
            ON psc3.ProductSubcategoryID = p3.ProductSubcategoryID
        INNER JOIN Production.ProductCategory AS pc3
            ON pc3.ProductCategoryID = psc3.ProductCategoryID
        WHERE pc3.ProductCategoryID = 4
    )
) AS x
    ON x.SalesPersonID = soh.SalesPersonID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY
    x.SalesPersonID,
    pp.FirstName,
    pp.LastName,
    pc.Name
ORDER BY
    Vendedor,
    Categoria;
/*
Posibles causas del fallo...
El ID 4 no es “Clothing” en tu base (en muchas instalaciones cambia).

Nadie vendió TODOS los productos de esa categoría (por ejemplo, hay productos que nunca se vendieron).

Muchos productos “se venden” pero sin SalesPersonID (ventas que no pasan por vendedor), y tu consulta
filtra SalesPersonID IS NOT NULL, entonces esos productos cuentan en “total de catálogo” pero no son
alcanzables por un vendedor.
*/
    --04.03
    SELECT
    soh.SalesPersonID,
    CONCAT(pp.FirstName, ' ', pp.LastName) AS Vendedor,
    pc.Name AS Categoria,
    COUNT(DISTINCT sod.ProductID) AS ProductosDistintosVendidos
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
    ON sod.SalesOrderID = soh.SalesOrderID
JOIN Production.Product p
    ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory psc
    ON psc.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
    ON pc.ProductCategoryID = psc.ProductCategoryID
JOIN Person.Person pp
    ON pp.BusinessEntityID = soh.SalesPersonID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY
    soh.SalesPersonID,
    pp.FirstName,
    pp.LastName,
    pc.Name
ORDER BY Vendedor, Categoria;


-- Consulta05
