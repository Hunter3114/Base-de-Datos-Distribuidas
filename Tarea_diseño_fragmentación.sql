/*
1. Seleccionar uno de los 4 ejercicios
compartidos sobre diseño de fragmentación o
proporner uno considerando la BD AdventureWorks.
2. Generar el segmento de grafo relacional
relacionado con el ejercicio
seleccionado. Considere las tablas que se
derivan de la tabla propietaria de su propuesta
de diseño.
3. Aplicar el algoritmo COM_MIN para generar
los posibles fragmentos primarios de su diseño.
4. Generar los fragmentos derivados a partir de
la operación SEMI-JOIN.
5. Validar el diseño de la fragmentación
para verificar que cumplan las 3 reglas de la 
fragmentación según la teoría de Tamer Özsu
6. Concluir acerca del diseño propuesto.
7. Documentar los pasos anteriores en un
documento PDF.
8. Nombrar el PDF como Tarea_diseño_fragmentación
y subir a su repositorio.
*/
/* TAREA
Ejercicio 4: Descentralizar el control de abastecimiento y 
compras a proveedores, asignando las órdenes de compra a 
los nodos geográficos donde se originan las solicitudes de
inventario. Tabla Purchasing.PurchaseOrderHeader, columna
PurchaseOrderId (rangos).
*/

use AdventureWorks2022;
go

set nocount on;
go

if schema_id(N'Prot_Frag') is null exec(N'create schema Prot_Frag');
go

/* 1. Estadística original: registrar estos resultados en el informe. */

select min(PurchaseOrderID) as MinimoID,
       max(PurchaseOrderID) as MaximoID,
       count_big(*) as TotalOrdenes
from Purchasing.PurchaseOrderHeader;

select count_big(*) as TotalDetalles
from Purchasing.PurchaseOrderDetail;
go

/* 2 Y 3*/

if object_id(N'Prot_Frag.Limites', N'U') is not null
    drop table Prot_Frag.Limites;

;with Num as (
    select PurchaseOrderID,
           ntile(5) over (order by PurchaseOrderID) as Grupo
    from Purchasing.PurchaseOrderHeader
), Rangos as (
    select Grupo,
           min(PurchaseOrderID) as MinID,
           max(PurchaseOrderID) as MaxID,
           count_big(*) as Filas
    from Num
    group by Grupo
)
select Grupo, MinID, MaxID, Filas
into Prot_Frag.Limites
from Rangos;

if (select count(*) from Prot_Frag.Limites) <> 5
    throw 51000, 'Se requieren al menos cinco órdenes para crear cinco fragmentos no vacíos.', 1;

select *
from Prot_Frag.Limites
order by Grupo;
go

/* 4 Y 5
*/

declare @i int = 1,
        @lo int,
        @hi int,
        @where nvarchar(max),
        @sql nvarchar(max);

while @i <= 5
begin
    select @hi = MaxID
    from Prot_Frag.Limites
    where Grupo = @i;

    select @lo = MaxID
    from Prot_Frag.Limites
    where Grupo = @i - 1;

    set @where = case
        when @i = 1 then
            N'h.PurchaseOrderID <= ' + convert(nvarchar(20), @hi)
        when @i = 5 then
            N'h.PurchaseOrderID > ' + convert(nvarchar(20), @lo)
        else
            N'h.PurchaseOrderID > ' + convert(nvarchar(20), @lo) +
            N' and h.PurchaseOrderID <= ' + convert(nvarchar(20), @hi)
    end;

    set @sql = N'if object_id(N''Prot_Frag.POH_' +
        convert(nvarchar(1), @i) +
        N''', N''U'') is not null drop table Prot_Frag.POH_' +
        convert(nvarchar(1), @i) + N';

select h.*
into Prot_Frag.POH_' + convert(nvarchar(1), @i) +
        N'
from Purchasing.PurchaseOrderHeader as h
where ' + @where + N';';

    exec sys.sp_executesql @sql;

    set @sql = N'if object_id(N''Prot_Frag.POD_' +
        convert(nvarchar(1), @i) +
        N''', N''U'') is not null drop table Prot_Frag.POD_' +
        convert(nvarchar(1), @i) + N';

select d.*
into Prot_Frag.POD_' + convert(nvarchar(1), @i) + N'
from Purchasing.PurchaseOrderDetail as d
where exists (
    select 1
    from Prot_Frag.POH_' + convert(nvarchar(1), @i) + N' as h
    where h.PurchaseOrderID = d.PurchaseOrderID
);';

    exec sys.sp_executesql @sql;

    set @i += 1;
end;
go

/* 6 */

create or alter view Prot_Frag.POH_Global as
select * from Prot_Frag.POH_1
union all
select * from Prot_Frag.POH_2
union all
select * from Prot_Frag.POH_3
union all
select * from Prot_Frag.POH_4
union all
select * from Prot_Frag.POH_5;
go

create or alter view Prot_Frag.POD_Global as
select * from Prot_Frag.POD_1
union all
select * from Prot_Frag.POD_2
union all
select * from Prot_Frag.POD_3
union all
select * from Prot_Frag.POD_4
union all
select * from Prot_Frag.POD_5;
go

/* 7 */

select 'POH' as Relacion,

    (select count_big(*)
     from (
         select * from Purchasing.PurchaseOrderHeader
         except
         select * from Prot_Frag.POH_Global
     ) as X) as Faltantes,

    (select count_big(*)
     from (
         select * from Prot_Frag.POH_Global
         except
         select * from Purchasing.PurchaseOrderHeader
     ) as X) as Sobrantes,

    (select count_big(*)
     from Purchasing.PurchaseOrderHeader) as TotalOriginal,

    (select count_big(*)
     from Prot_Frag.POH_Global) as TotalReconstruido,

    (select count_big(*)
     from (
         select PurchaseOrderID
         from Prot_Frag.POH_Global
         group by PurchaseOrderID
         having count_big(*) > 1
     ) as X) as LlavesDuplicadas;


select 'POD' as Relacion,

    (select count_big(*)
     from (
         select * from Purchasing.PurchaseOrderDetail
         except
         select * from Prot_Frag.POD_Global
     ) as X) as Faltantes,

    (select count_big(*)
     from (
         select * from Prot_Frag.POD_Global
         except
         select * from Purchasing.PurchaseOrderDetail
     ) as X) as Sobrantes,

    (select count_big(*)
     from Purchasing.PurchaseOrderDetail) as TotalOriginal,

    (select count_big(*)
     from Prot_Frag.POD_Global) as TotalReconstruido,

    (select count_big(*)
     from (
         select PurchaseOrderID, PurchaseOrderDetailID
         from Prot_Frag.POD_Global
         group by PurchaseOrderID, PurchaseOrderDetailID
         having count_big(*) > 1
     ) as X) as LlavesDuplicadas;


select 1 as Nodo,
       (select count_big(*) from Prot_Frag.POH_1) as Cabeceras,
       (select count_big(*) from Prot_Frag.POD_1) as Detalles

union all

select 2,
       (select count_big(*) from Prot_Frag.POH_2),
       (select count_big(*) from Prot_Frag.POD_2)

union all

select 3,
       (select count_big(*) from Prot_Frag.POH_3),
       (select count_big(*) from Prot_Frag.POD_3)

union all

select 4,
       (select count_big(*) from Prot_Frag.POH_4),
       (select count_big(*) from Prot_Frag.POD_4)

union all

select 5,
       (select count_big(*) from Prot_Frag.POH_5),
       (select count_big(*) from Prot_Frag.POD_5);
go
