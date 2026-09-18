/*
Fragmentación horizontal

1. Información de las aplicaciones.
-- Identificar las consultas sobre las BD.
-- Lista de predicados simples
   (where, join, having).
2. Frecuencia de acceso o frecuencia de ejecución
   de las consultas.
--Indica si los predicados realmente seleccionan la cantidad de filas
y con esa selectivilidad que tanto se relacina.
3. Sitios desde donde se ejecutan las consultas.

*/
use AdventureWorks2022;

select TerritoryID, count(*)
from Sales.SalesOrderHeader
group by TerritoryID

--Fragmentación Derivada
--Aplicar un semiJoin por
--Cada fragmento de la
--tabla propietaria de la relacion

select * from Sales.SalesOrderHeader soh
join Sales.SalesOrderDetail sod
on 

--jerarquia de la distribución ya que la llave primaria se encuentra
--en SalesOrderHeader

-- varios criterios a segmentar muchas que analizar
--Fragmentacion primaria
select t.[group], count(*)
from Sales.SalesOrderHeader soh
join Sales.SalesTerritory t
on soh.TerritoryID = t.TerritoryID
group by t.[Group]
--segmentar -> dividir una tabla por filas
--separación fisica y logica.
--ahora cada tabla es independiente por lo que
--tengo tres grupos, ahí se pueda distribuir las tablas en otros servidores
--Lista de Predicados que me lleven a fragmentar por región
/*Formato simple, despues de esto sacamos la frecuencia
PRSalesOrderHeader = {
	TerritoryID = 1, --North America
	TerritoryID = 2,
	TerritoryID = 3,
	TerritoryID = 4,
	TerritoryID = 5,
	TerritoryID = 6,
	TerritoryID = 7, -- Europe
	TerritoryID = 8,
	TerritoryID = 9, -- Pacific
	TerritoryID = 10, -- Europe
	OnlineOnLife = 1
	}
*/
/*Frecuencia de acceso
			Por mes
Region NA    1000		SalesOrderHeader
						SalesOrderDetails
Region E     1500
Region P	 700
Region NA	 500		Productcon con
						categoyID = 2
Region E	 700		CategoryID = 4
Region P	 350		CategoryID <> 2 and
						CategoryID <> 4 
*/

select *
from Production.ProductCategory pc
join Production.ProductSubcategory psc
on pc.ProductCategoryID = psc.ProductCategoryID
join Production.[Product]
/*
Algorimo COM_MIN
Este algoritmo tiene una entrada el cual es un conjunto de PR de formto simple,
R(Tabla), la salida de este es un conjunto PR' el cual es un conjunto de redicados simples
completo y minimo.
Regla fundamental de gragmentación. Cada predicado divide la tabla en dos grupos y debemos
observar si esa division es relevante pero si existe una consulta que consulte a los predicados
esta sirve y si no tiene una consulta que acceda a ese conjunto por lo tanto no sirve

Selectivilidad del predicado es el conjunto de filas que me selecciona.
Entre mayor cantidad de filas tenga es mejor cantidato para fragmentación.
Esta me indica numero de filas que se genera en un predicado y se tiene que
analizar al a par de la regla fundamental de fragmentación.

Generar un conjunto de predicados miniTermino, la cual es,
conjunción de predicados simples
Miniterminos = {
	F1: TerritoryID = 1 ^ OFF (OOF -> OnlyOnFlag o algo parecido)
	F2: TerritoryID = 2 ^ (OOF = 1)
	...
	F19: TerrirotyID = 10 ^ OOF = 1
	
	F20: tERRYTOTYid = 10 ^ (OOF = 1)
*/
select soh.SalesOrderID, soh.CustomerID, soh.SalesPersonID, soh.TerritoryID,
	   t.[group]
from Sales.SalesOrderHeader soh
join Sales.SalesTerritory t
on soh.TerritoryID = t.TerritoryID
where soh.OnlineOrderFlag = 1

/*Regla que debe cumplir el esquema de grafmentación
1. Completitud
2. Disjunción( dos o mas fragmentos no deben tener la misma fila)
3. Reconstrución( operador que permita 
unir los fragmentos y obtener el conjunto original).
--Fragmentación Horizontas ya se primaria o derivada.
UNION
--Fragmentación Vertical
JOIN
*/

/*ESQUEMA FINAL DE FRAGMENTOS
para SalesOrderHeader por region y ventas en liena

F = {
	F1: M1 U M3 U M5 U M7 U M9 U M11 --north america
	F2: M2 U M4 U M6 U M8 U M10 U M12 --north america
	F3: M13 U M15 U M19 --Europe
	F4: M14 U M16 U M20 --Europe
	F5: M17 --Pacific
	F6: M18 --Pacific
	F7: Nuevos regiones
*/