-- practica 4

-- b02: lectura sucia y conservacion del precio

use adventureworks2022;
go
set transaction isolation level read uncommitted;
if object_id('tempdb..#p4_lectura') is not null
    drop table #p4_lectura;
select productoid, preciolista as precioleido
into #p4_lectura
from dbo.p4_producto
where productoid = 1;
select productoid, precioleido from #p4_lectura;
go

-- b04

set transaction isolation level read committed;
insert dbo.p4_detallepedido
    (productoid, preciounitario, cantidad, descuento)
select productoid, precioleido, 10, 0.100
from #p4_lectura;
select d.detalleid, p.preciolista as precioconfirmado,
       d.preciounitario as precioregistrado,
       d.preciounitario - p.preciolista as diferencia
from dbo.p4_detallepedido as d
join dbo.p4_producto as p on p.productoid = d.productoid
order by d.detalleid;
go

-- b06: pedido protegido con read committed

set transaction isolation level read committed;
insert dbo.p4_detallepedido
    (productoid, preciounitario, cantidad, descuento)
select productoid, preciolista, 10, 0.100
from dbo.p4_producto
where productoid = 1;
-- con bloqueo tradicional esta consulta esperara al paso 7.
go

-- b08: consultar datos reales de las tablas
-- ejecutar cuando el paso 6 haya terminado.
select productoid, preciolista as preciofinal
from dbo.p4_producto;
select detalleid, productoid, preciounitario, cantidad,
       descuento,
       cast(preciounitario * cantidad * (1 - descuento)
            as decimal(19,4)) as totalregistrado
from dbo.p4_detallepedido
order by detalleid;
go

-- b09a: guardar resultados en dbo.p4_resultados

-- llenar la tabla con los resultados reales de la ejecucion.
delete from dbo.p4_resultados;
insert dbo.p4_resultados
    (escenario, detalleid, precioconfirmado,
     precioregistrado, diferenciaunidad, cantidad,
     descuento, totalregistrado, totalreferencia,
     diferenciatotal)
select
    case when d.detalleid = 1
         then 'lectura sucia' else 'read committed' end,
    d.detalleid,
    p.preciolista,
    d.preciounitario,
    d.preciounitario - p.preciolista,
    d.cantidad,
    d.descuento,
    cast(d.preciounitario * d.cantidad *
         (1 - d.descuento) as decimal(19,4)),
    cast(p.preciolista * d.cantidad *
         (1 - d.descuento) as decimal(19,4)),
    cast((d.preciounitario - p.preciolista) *
         d.cantidad * (1 - d.descuento) as decimal(19,4))
from dbo.p4_detallepedido as d
join dbo.p4_producto as p on p.productoid = d.productoid
where d.detalleid in (1, 2);
go

-- b09b: consultar dbo.p4_resultados
select escenario, detalleid, precioconfirmado,
       precioregistrado, diferenciaunidad,
       cantidad, descuento, totalregistrado,
       totalreferencia, diferenciatotal
from dbo.p4_resultados
order by detalleid;
go

