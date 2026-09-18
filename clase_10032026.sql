use AdventureWorks2022
go

/*
Ejercicio de rendimiento de 'join'
*/

set statistics io on;
 
/* Crear copia de SalesOrderHeader, SalesOrderDetail, 
   Product */
 
select * into soh
from sales.SalesOrderHeader
 
select * into sod
from sales.SalesOrderDetail
 
select * into product
from production.Product
 
SELECT p.ProductID, p.Name, sum(sod.LineTotal) as total -- en indice
FROM dbo.Product p
JOIN dbo.sod sod
/*    with (index(nc_sod_productid)) -- table scan*/
    ON p.ProductID = sod.ProductID -- el filtro de join se encuentre en un indice
WHERE sod.OrderQty > 5 -- Filtro se encuentra en un indice
GROUP BY p.ProductID, p.Name; -- en la medida de lo posible, estos deben estar en un indice

/* Verificar el plan de ejecución estimado
   stream agre
*/
-- covering index
-- las dos tablas en el join estan ordenados
drop index nc_sod_productid

create nonclustered index nc_sod_productid
on dbo.sod(productid)
include (orderqty, linetotal)
--include (linetotal, orderqty)

-- Por que ocupa un table scan
-- no por tener indeces sera beneficioso esa combinación de indices
create nonclustered index nc_product_orderqty
on dbo.sod(orderqty)


--
drop index nc_sod_productid
go

create nonclustered index nc_sod_productid
on dbo.sod(productid)
include (linetotal, orderqty)