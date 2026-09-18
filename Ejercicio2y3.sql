use AdventureWorks2022;
go

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
go

/*Ejercicio 2*/
SELECT *
FROM Sales.SalesOrderHeader AS h
WHERE YEAR(h.OrderDate) = 2013;
GO

CREATE NONCLUSTERED INDEX
IX_SalesOrderHeader_OrderDate
ON Sales.SalesOrderHeader(OrderDate);
go

select * from Sales.SalesOrderHeader
where OrderDate >= '2013-01-01' and OrderDate < '2014-01-01';
go

select
    i.name AS Nombre_Idx,
    i.type_desc AS Tipo_Idx,
    c.name AS Columna,
    ic.key_ordinal AS Posicion_Colm,
    i.is_primary_key AS EsPK,
    i.is_unique AS EsUnico
from sys.indexes AS i
inner join sys.index_columns AS ic
    ON i.object_id = ic.object_id
   and i.index_id = ic.index_id
inner join sys.columns AS c
    ON ic.object_id = c.object_id
   and ic.column_id = c.column_id
where i.object_id = OBJECT_ID('Sales.SalesOrderHeader')
ORDER BY i.name, ic.key_ordinal;
go

SELECT
    s.name AS Nombre_Estadistica,
    STATS_DATE(s.object_id, s.stats_id) AS Fecha_Ultima_Actualizacion,
    s.auto_created AS Creada_Automaticamente,
    s.user_created AS Creada_Por_Usuario,
    s.no_recompute AS Sin_Recalculo_Automatico
FROM sys.stats AS s
WHERE s.object_id = OBJECT_ID('Sales.SalesOrderHeader');
GO

DBCC SHOW_STATISTICS ('Sales.SalesOrderHeader', 'NombreDelIndiceOEstadistica');
GO

DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO

/* Ejercicio 3 */

/* Consulta proporcionada */
use AdventureWorks2022
go


SELECT p.Name, SUM(sod.LineTotal) AS TotalSales
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod
    ON p.ProductID = sod.ProductID
GROUP BY p.Name;

/* Solución */

IF OBJECT_ID('dbo.Product_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.Product_Copy;
GO

IF OBJECT_ID('dbo.SalesOrderDetail_Copy', 'U') IS NOT NULL
    DROP TABLE dbo.SalesOrderDetail_Copy;
GO

SELECT *
INTO dbo.Product_Copy
FROM Production.Product;
GO

SELECT *
INTO dbo.SalesOrderDetail_Copy
FROM Sales.SalesOrderDetail;
GO

/**/

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/**/

SELECT p.Name, SUM(sod.LineTotal) AS TotalSales
FROM dbo.Product_Copy p
JOIN dbo.SalesOrderDetail_Copy sod
    ON p.ProductID = sod.ProductID
GROUP BY p.Name;
GO

/* scan recorre todo (tabla desordenada o indice ya ordenado)
   las columnas que agregue, etc.
   index agrupado es más pesado porque incluye todas las columnas
   aunque no tenga indice agrupado o indice no agrupados pueden ser
   beneficos
   
   indice no agrupado sobre la tabla 
   
   el examen sera de esta tabla y sobre la otra base de datos
   para la realización de optimización
   
   revisar el tema de 'arquitecturas para base de datos distribuidas' es para viernes
   20/03/2026
   gestores de base de datos que soporten distribución generales. fracmentación y replicación
   que soporta de distribusión, tipo de modelo de datos que soporta el gestor (relacional o no)
   y si tiene costo o es de acceso gratuito.
   kasandra.
   */

CREATE NONCLUSTERED INDEX IX_Product_Copy_ProductID
ON dbo.Product_Copy (ProductID);
GO

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_Copy_ProductID
ON dbo.SalesOrderDetail_Copy (ProductID);
GO
