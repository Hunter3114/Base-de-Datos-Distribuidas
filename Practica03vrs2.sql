use covidHistorico2;
go

-- verificar los años que existen en la tabla original
select 
    year(try_convert(date, replace(FECHA_INGRESO,'"',''))) as Anio,
    count(*) as Total_Registros
from datoscovid
where try_convert(date, replace(FECHA_INGRESO,'"','')) is not null
group by year(try_convert(date, replace(FECHA_INGRESO,'"','')))
order by Anio;
go

-- borrar tabla si ya existe
if object_id('covid_particionado', 'U') is not null
drop table covid_particionado;
go

-- borrar esquema de particionamiento si ya existe
if exists (
    select *
    from sys.partition_schemes
    where name = 'ps_anio_covid'
)
drop partition scheme ps_anio_covid;
go

-- borrar funcion de particionamiento si ya existe
if exists (
    select *
    from sys.partition_functions
    where name = 'pf_anio_covid'
)
drop partition function pf_anio_covid;
go

-- crear funcion de particionamiento por año
create partition function pf_anio_covid(date)
as range right for values
(
    '2020-01-01',
    '2021-01-01',
    '2022-01-01',
    '2023-01-01'
);
go

-- crear esquema de particionamiento
create partition scheme ps_anio_covid
as partition pf_anio_covid
all to ([primary]);
go

-- crear tabla particionada
create table covid_particionado(
    ID int identity(1,1) not null,
    FECHA_INGRESO date not null,
    ENTIDAD_RES varchar(50),
    EDAD int,

    constraint pk_covid_particionado primary key clustered(FECHA_INGRESO, ID)
)
on ps_anio_covid(FECHA_INGRESO);
go

-- insertar datos en la tabla particionada
insert into covid_particionado
(
    FECHA_INGRESO,
    ENTIDAD_RES,
    EDAD
)
select 
    try_convert(date, replace(FECHA_INGRESO,'"','')),
    replace(ENTIDAD_RES,'"',''),
    try_convert(int, replace(EDAD,'"',''))
from datoscovid
where try_convert(date, replace(FECHA_INGRESO,'"','')) is not null;
go

-- consultar los limites de la funcion de particionamiento
select 
    pf.name as Funcion,
    prv.boundary_id as Numero_Limite,
    prv.value as Valor_Limite
from sys.partition_functions pf
join sys.partition_range_values prv
on pf.function_id = prv.function_id
where pf.name = 'pf_anio_covid'
order by prv.boundary_id;
go

-- consultar registros por particion
select 
    $partition.pf_anio_covid(FECHA_INGRESO) as Numero_Particion,
    min(FECHA_INGRESO) as Fecha_Minima,
    max(FECHA_INGRESO) as Fecha_Maxima,
    count(*) as Total_Registros
from covid_particionado
group by $partition.pf_anio_covid(FECHA_INGRESO)
order by Numero_Particion;
go

-- consultar detalle de particiones de la tabla
select 
    t.name as Tabla,
    i.name as Indice,
    p.partition_number as Numero_Particion,
    p.rows as Filas
from sys.tables t
join sys.indexes i
on t.object_id = i.object_id
join sys.partitions p
on i.object_id = p.object_id
and i.index_id = p.index_id
where t.name = 'covid_particionado'
order by p.partition_number;
go

-- consultar datos del año 2020
set statistics io on;
set statistics time on;

select *
from covid_particionado
where FECHA_INGRESO >= '2020-01-01'
and FECHA_INGRESO < '2021-01-01';

set statistics io off;
set statistics time off;
go

select * from cat_entidades;
select * from datoscovid;

-- 2.verificacion de datos
select count(*) as Total_DatosCovid
from datoscovid;
go

--  3.verificar que las fechas se puedan convertir
select
    top 20
    FECHA_INGRESO,
    TRY_CONVERT(date, replace(FECHA_INGRESO,'"','')) as Fecha_Convertida
from datoscovid;
go

-- 4.Verificar los años existentes

select
    year(try_convert(date,replace(FECHA_INGRESO,'"',''))) as Anio,
    count(*) as Total_Registros
from datoscovid
where try_convert(date,replace(FECHA_INGRESO,'"','')) is not null
group by year(try_convert(date,replace(FECHA_INGRESO,'"','')))
order by Anio;
go

-- 5.Borrar Objetos Anteriores

if object_id('covid_particionado', 'U') is not null
drop table covid_particionado;
go

if exists (
    select *
    from sys.partition_schemes
    where name = 'ps_anio_covid'
)
drop partition scheme ps_anio_covid;
go

if exists (
    select *
    from sys.partition_functions
    where name = 'pf_anio_covid'
)
drop partition function pf_anio_covid;
go

-- 6. Crear función de particionamiento

create partition function pf_anio_covid(date)
as range right for values
    (
    '2020-01-01',
    '2021-01-01',
    '2022-01-01',
    '2023-01-01'
    );
go

-- 7. Crear esquema de Partición

create partition scheme ps_anio_covid
as partition pf_anio_covid
all to ([primary]);
go

-- 8. Crear tabla particionada

create table covid_particionado(
    ID int identity(1,1) not null,
    FECHA_INGRESO date not null,
    ENTIDAD_RES varchar(50),
    EDAD int,

    constraint pk_covid_particionado primary key clustered(FECHA_INGRESO, ID)
)
on ps_anio_covid(FECHA_INGRESO);
go

--9. Insertar datos en la tabla particionada
insert into covid_particionado
(
    FECHA_INGRESO,
    ENTIDAD_RES,
    EDAD
)
select 
    try_convert(date, replace(FECHA_INGRESO,'"','')),
    replace(ENTIDAD_RES,'"',''),
    try_convert(int, replace(EDAD,'"',''))
from datoscovid
where try_convert(date, replace(FECHA_INGRESO,'"','')) is not null;
go

-- 10. Verificar que sí se insertaron los datos

select count(*) as Total_Covid_Particionado
from covid_particionado;
go