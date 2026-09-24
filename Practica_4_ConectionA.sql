-- practica 4: 

use adventureworks2022;
go
if object_id('dbo.p4_resultados', 'u') is not null
    drop table dbo.p4_resultados;
if object_id('dbo.p4_detallepedido', 'u') is not null
    drop table dbo.p4_detallepedido;
if object_id('dbo.p4_producto', 'u') is not null
    drop table dbo.p4_producto;
go
create table dbo.p4_producto (
    productoid int not null primary key,
    productoawid int not null,
    nombre nvarchar(50) not null,
    preciolista decimal(19,4) not null
);
create table dbo.p4_detallepedido (
    detalleid int identity(1,1) primary key,
    productoid int not null
        references dbo.p4_producto(productoid),
    preciounitario decimal(19,4) not null,
    cantidad int not null check (cantidad > 0),
    descuento decimal(4,3) not null
        check (descuento between 0 and 1)
);
create table dbo.p4_resultados (
    escenario nvarchar(30) not null primary key,
    detalleid int not null,
    precioconfirmado decimal(19,4) not null,
    precioregistrado decimal(19,4) not null,
    diferenciaunidad decimal(19,4) not null,
    cantidad int not null,
    descuento decimal(4,3) not null,
    totalregistrado decimal(19,4) not null,
    totalreferencia decimal(19,4) not null,
    diferenciatotal decimal(19,4) not null
);
go
insert dbo.p4_producto
    (productoid, productoawid, nombre, preciolista)
select top (1) 1, productid, name, 100.0000
from production.product
where listprice > 0
order by productid;
select productoid, productoawid, nombre, preciolista
from dbo.p4_producto;
go

-- a01


begin transaction;
update dbo.p4_producto
set preciolista = round(preciolista * 1.20, 4)
where productoid = 1;
select productoid, preciolista as precioprovisional
from dbo.p4_producto where productoid = 1;
-- dejar la transaccion abierta: no usar commit.
go


-- a03 rollback 

rollback transaction;
select productoid, preciolista as precioconfirmado
from dbo.p4_producto where productoid = 1;
go


-- a05

begin transaction;
update dbo.p4_producto
set preciolista = round(preciolista * 1.20, 4)
where productoid = 1;
-- transaccion abierta 
go

-- a07: rollback para liberar la conexion b

rollback transaction;
go

