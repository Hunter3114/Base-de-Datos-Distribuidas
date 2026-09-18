/*
**************************************************************
	Concurrencia en Base de Datos
**************************************************************
*/

/*
En base de datos es la capaciddad de gestionar multiples BD

Actualizaciones perdidas
El problema de actualización perdido en 

Lost Update.

Niveles de Aislamiento.
+--------------------+-----------------+
|     Proceso A      |    Proceso B    |
+--------------------+-----------------+ 
| t_1: Leer(x)       |	   			   |
| t_2:               |   Leer(x)       |
| t_3: escribir      |                 |
| t_4: escribir(x+1) |
| t_5:               |   Leer(x)
| t_6: callback		 |
+--------------------------------------+

1. Problema de actualización perdida - resuelto de forma implicita en el Servidor
   Transacción
2. Lectura sucia
   Cuando una transacción incluye más de una operación (lectura/escritura)
3. Lectura repetible
4. Lectura fantasma


Niveles de aislamiento son configuraciones para resolver problemas de concurrencia

READ UNCOMMITED

--Transacción A
Tarea: concurrencia en transacciones.

SET TRANSACTION ISLOATION LEVEL READDUNCOMMITED
	INSTANCIAS DE UNA TABLA (SNAPSHOT).

	Algoritmo de confirmacion de fase y con la configuración
	coordinada
waitfor

*/

--Arquitecturas para base de datos distribuidas
-- Estrategias de distribución 
-- 1. Fragmentación de una BD (Modelo de datos conceptual
-- 2. capitulo 3 diseño de BD en fragmentación
-- 2.1 Por qué fragmentar?
-- 2.2 Qué información se requiere para fragmentar=
-- 2.3 Hasta que nivel fragmentar?
-- 2.4 Que tipos de gramentación se pueden aplicar y qué lo determina?
-- 2.5 Gráfo relacional en el contexto de la fragmentación (tablas miembro,
-- tablas propietaria, relaciones entre dihas tablas).


-- 3. Selectividad
-- Cardinalida
-- Relevancia
-- 
--Estos temas me tocan exponer Dariel y 
-- Algoritmo COM_MIN (esta en el libro)
-- Variantes del algoritmo.
-- Algoritmos de Fragmentación horizontal primaria