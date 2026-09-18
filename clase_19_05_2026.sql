/**   
   CONSULTAS DISTRIBUIDAS EN EL ESQUEMA DE
   FRAGMENTACION DE ADVENTUREWORKS
     - Fragmentos de SalesOrderHeader y
	   SalesOrderDetail
	 -7 fragmentos considerando 3 para ventas en linea y 3 para
	  ventas en mostrador, un fragmento para nuevos territorios
	  (Fragmento vacío inicialmente)
	 - Alojar los fragmentos en dos sevidores
	  a. Servidor A(Fragmento de ventas en línea)
	  b. Servidor B(Fragmentos restantes
	 -Crear servidor vinculado en cada servidor que permita
	  acceder al otro servidor
     - tablas globales de Customer y Product



	 - en segurite puedes declarar con que usuario se podra accedera dicho server
	  le pondremos que sera remoto 
	  como solucionar la tuberia

*/
 
/*1. El departamento de finanzas quiere un 
     reporte global de las ventas totales en línea 
	 y el promedio de compra por cliente en todo 
	 el mundo, ordenado de mayor a menor. 
*/

-- la conexión se realiza desde el servidor A.
-- Las tablas globales se consultan localmente
-- Primer escenario
-- consolidar (unir) los datos de los fragmentos, puede ser una vista.
-- antes de realizar la consulta.
-- crear una vista global de los datos fragmentados
-- Vista federada, reune a partir de una consolidación de datos publicos.
-- Segundo escenario
-- Crear consultas fragmentadas para determinar las ventas
-- en cada servidor después unir el resultado antes de calcular
-- el promedio de compra

use AdventureWorks2022
go

select * into customer
from AdventureWorks2022.sales.Customer

select p

select *
from AdventureWorks2022.sales.Customer c 
join dbo.F1SOH
on c.CustomerID = F1SOH.CustomerID
join servidor_B.fragmentacion.dbo.F2SOH
on c.CustomerID = F2SOH.CustomerID
 --Comó calcular las ventas totales?

 select salesorderid, SUM(linetotal)
 from SERVIDOR_B.fragmentación.dbo.F2SOD
 group by salesOrder

 select *
 from SERVIDOR_B.fragmentacion.dbo.F2SOH soh
 join(
		select salesorderid, sum(linetotal) total
		from SERVIDOR_B.fragmentación.dbo.F2SOH sod
		group by salesorderid) T
 on soh.
 --expresiones de tablas común
/*2. El gerente de marketing de la región Europa desea 
     saber cuáles son los 5 productos más vendidos en su
	 territorio para lanzar una campaña específica.
	 Mostrar el nombre y número delos productos.
*/
/*3. La dirección general quiere comparar el rendimiento
     de ventas entre NortAmerica y Pacific durante el
	 año 2014 detallando cuántas ordenes se procesaron 
	 en línea y mostrador, así como el monto total, 
	 utilizando la tabla global SalesTerritor para 
	 mapear los nombres de los países.
*/
