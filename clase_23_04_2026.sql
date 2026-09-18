/*
mongoDB
Modelado Relacional: recomentadado para lectura y escritura simultanea por lo que se controla la concurrencia
para aplicaciones transaccionales.
Conceptos clave 
Un documento seria una fila
Coleccion contiene lista o tabla
Campo
Cluster/Sharding

Datos Embebidos (Desnormalización)
Referencias (Normalización Manual)

--Caracteristicas prooricona
Flexiilidad de esquema
Alto Disponibilidad
Aggregation Framework
Escalabilidad Horizontal Nativa

--Casandra
Trabaja con el concepto ce Cluster. y se trabaja el tema de replicación.
Diseñado completamente para la gestion de base de datos distribuidas.
Arquitectura Descentralizada
Replicación Configurable
Consistecia Eventual

Dispnivilidad "Always-On"
Escolabilidad Lineal
Aquitectura Distribuida(Peer-to-Peer)
Modelo de Datos de Columnas Anchas

--Firebase
Plataforma de desarrollo que invluye dos opciones NoSQL para datos:

Caracteristicas:
Sincronización en tiempo real, Listeners y snapshots
Seguridad Integrada

Conceptos clave
Cloud Firestore
Realtime Database Arbol JSON

Abra una practica de Desnormalización.


Base de datos distribuidas 
Enfoque de diseño
1.- Diseño Top-Down - Botton-Up
	a. Fragmentación - Dividir un modelo conceptual
	   que permitadistribuir los datos.
	   I. Horizontal(Filas)
	   II. Vertical(Columnas)
	   III. Mixta
	   Fragmentación Horizontal
	   Primaria(Tablas propietarias)
	   Derivada(Relaciones con tablas miembro)
	   Grafo Relacional
    b. Niveles de fragmentación horizontal
	   I. Tablas - Segmentación de datos
	   II. Filas - considerar que información requiero para comenzar diseño de fragmentación(esquema relacional)
	       estaran representadas por el grafo relacional, cardinalidad, estadisticas.
	   III. Información de las palicaciones o sonsultas que acceden al modelo conceptual para recuperar predicados o condiciones en los
	   filtros para acceder a los datos. 
	   IV. Información sobre la frecuencia de acceso a los datos(nodos desde donde accedo a los datos).
	   V. Información de la red en la que se distribuira el modelo(Topología, capacidad de cada nodo)
	   para que se determine el esquema de asignación de fragmentos.
	   
	   LA IDEA ES SEGMENTAR HASTA CIERTO PUNTO
	   Hasta que nivel fragmentar o cuando para de fragmentar?
	   Rendimiento > costo de gestión de la distribución.
	   Información de las palicaciones - informacion de la red
	   

	   Información de las apliaciones o consultas que acceden al modelo cnoceptual para recuperar predicaciones o condiciones para acceder a los datos
*/