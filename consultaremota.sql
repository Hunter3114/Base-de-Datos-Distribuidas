select * from Openquery(MySQL,'select * from MySQLRemoto.Users limit 1');
/*
MySQL2022
LabTD20251

*/
select * from openquery(MYSQL, ' select * from users.user')
/*
1. Servidor vinculado en SQL server que 
   apunte a un ODBC en Windows
2. ODBC de Windows configura conexión
   a MySQL.
3. MySQL recibe consulta y ejecuta.
NOTA: los errores cometidos en la BD dependeran
4. Deuelve resultado a ODBC
5. ODBC resuelve
*/

select * from openquery (MYSQL, 'call users.getAll()')

/*solucion 01*/

exec ('call users.getAll()') at MYSQL

/*rpc de salida debe estar habilitada*/

/*
GRANT EXECUTE ON
PROCEDURE users.getAll TO 'Alumno'@'%';
select * from (call users.getAll());
se ejecutara con el usuario de root
y la contraseña
*/

/*Ejemplo de la partición*/
select * top 1 --count(*)
from covidHistorico2.dbo.datoscovid
--para tablas de millones de filas, es donde se justifica partición de tabla
--el particionamiento de tabla no es lo mismo del tema de fracmentación.
--funciona a nivel de una tabla y lo divide en filas en aspectos de un criterio
--mientras la fracmentación puede u ocupa más de una tabla.
--cuando la fracmentación de una tabla y su implementación es cuando estos dos conceptos
--se pueden juntar.
/*
Particionamiento de tablas
es un técnica en base de datos que consiste en dividir una tabla grande en partes mas pequeñas llamasdas particiones
-tipos
-Horizontal o sharding
divide en subconjuntos más pequeños y manejables basados en filas, donde cada partición contiene el mismo esquema pero diferentes datos
-Vertical
-Rango
-Por lista
-Hash
divide una tabla en varias partes más pequeñas, usando función hasj sobre una columna o conjunto de columnas.
Fución Hash: Algoritmo que toma un dato(numero, texto, etc) y lo transforma en un numero fijo.

Particionamiento en PostgreSQL

CREATE TABLE ventas (
	id INT,

--Definir el particionamiento en SQL Server Managament

se recomienda que la base de datos este en el disco C: y 
este en un archivo publico.

tabla de preparación
con esta extraemos los datos ya que muchas veces vienen en cadena
y estos suelen venir sucios o incompletos los datos.

La partición me dice cuantos grupos se van a generar y con el rango...

se crean nuevas tablas para establecer los tipos de datos que tendra
en otras palabras declarar que tipo de dato son
DATE, VARCHAR, INT, etc.

ejercicio para la primera practica es fracmenta una tabla.
*/

Select entidad_res, count(*) cant_casos
from covidHistorico2.dbo.datoscovid c
where c.CLASIFICACION_FINAL between 1 and 3 -- 1 al 3 casos confirmados.
group by entidad_res
order by cant_casos

--probablemente se cancelan clases.

use covidHistorico2;
go

CREATE PARTITION FUNCTION pf_anio ()
AS RANGE RIGHT FOR VALUES
('2020-01-01','2021-01-01','2022-01-01')



se-lect year(FECHA_ACTUALIZACION), COUNT(*)
from datoscovid
group by year(FECHA_ACTUALIZACION)

-- en industria se manejan la partición de datos/tablas.


select * from covid_particionado
wh
