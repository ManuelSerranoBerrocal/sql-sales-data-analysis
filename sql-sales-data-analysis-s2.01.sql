/* - Ejercicio 1
A partir de los documentos adjuntos (estructura_datos y datos_introducir), 
importa las dos tablas. Muestra las principales características del esquema creado y explica las 
diferentes tablas y variables que existen. Asegúrate de incluir un diagrama que ilustre 
la relación entre las distintas tablas y variables.
*/

SELECT * FROM transactions.company;

SELECT * FROM transactions.transaction;

/* - Ejercicio 2
Utilizando JOIN realizarás las siguientes consultas:
2.1 Listado de los países que están realizando compras. */
SELECT DISTINCT c.country AS Paises_Haciendo_Compras
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

/* 2.2 Desde cuántos países se realizan las compras.*/
SELECT COUNT(distinct c.country) AS Total_Paises_Realizan_Compras
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

/* 2.3 Identifica a la compañía con la mayor media de ventas */
SELECT c.company_name AS Compañía, AVG(t.amount) AS Mayor_Promedio_Ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY Mayor_Promedio_Ventas DESC
LIMIT 1;


/*
- Ejercicio 3
Utilizando sólo subconsultas (sin utilizar JOIN):
Muestra todas las transacciones realizadas por empresas de Alemania.
Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.
*/ -- 3.1 Muestra todas las transacciones realizadas por empresas de Alemania.
SELECT *
FROM transaction
WHERE company_id IN (SELECT id
    FROM company
    WHERE country = 'Germany')
	AND declined = 0;

-- 3.2 Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
SELECT c.company_name AS Empresas_C_Transac_Mayor_a_Media
FROM company c
WHERE id IN (SELECT company_id
			FROM transaction
			WHERE amount > (SELECT AVG(amount)
							FROM transaction
							WHERE declined = 0)
	AND declined = 0);


-- 3.3 Eliminarán del sistema las empresas que carecen de transacciones registradas, entrega el listado de estas empresas.

SELECT *
FROM company
WHERE id NOT IN (
    SELECT DISTINCT company_id
    FROM transaction
);
    

/*
Nivel 2
Ejercicio 1
Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas.
Muestra la fecha de cada transacción junto con el total de las ventas. */
SELECT DATE(timestamp) AS Fecha_Transaccion, SUM(amount) AS Total_Ventas
FROM transaction
WHERE declined = 0
GROUP BY Fecha_Transaccion
ORDER BY Total_Ventas DESC
LIMIT 5;

-- Ejercicio 2
-- ¿Cuál es la media de ventas por país? Presenta los resultados ordenados de mayor a menor medio.
SELECT c.country AS País, AVG(amount) AS Media_Ventas
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.country
ORDER BY Media_Ventas DESC;


/* Ejercicio 3
En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía “Non Institute”. 
Para ello, te piden la lista de todas las transacciones realizadas por empresas que están ubicadas en el mismo país que esta compañía.
Muestra el listado aplicando JOIN y subconsultas.
Muestra el listado aplicando solo subconsultas.*/
-- Muestra el listado aplicando JOIN y subconsultas.
SELECT c.country, C.company_name, t.*
FROM company c 
JOIN transaction t ON c.id = t.company_id
WHERE c.country = (SELECT country 
					FROM company
                    WHERE company_name ='Non Institute');

-- Muestra el listado aplicando solo subconsultas.
SELECT * FROM transaction 
WHERE company_id IN (
	SELECT id FROM company 
	WHERE country = (SELECT country FROM company WHERE company_name ='Non Institute')); 

/* Nivel 3: Ejercicio 1
Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un 
valor comprendido entre 100 y 200 euros 
y en alguna de estas fechas: 29 de abril de 2021, 20 de julio de 2021 y 13 de marzo de 2022. 
Ordena los resultados de mayor a menor cantidad.*/
SELECT c.company_name AS Nombre, c.phone AS Teléfono, c.country AS País, DATE(t.timestamp) AS Fecha, t.amount AS Cantidad
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.amount BETWEEN 100 AND 200 AND DATE(t.timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13')
ORDER BY t.amount DESC;

/* Ejercicio 2: Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, 
por lo que te piden la información sobre la cantidad de transacciones que realizan las empresas, 
pero el departamento de recursos humanos es exigente y quiere 
un listado de las empresas en las que especifiques si tienen más de 4 transacciones o menos.*/
SELECT c.company_name AS Empresa, COUNT(t.id) AS Cant_Transacción, 
CASE WHEN COUNT(t.id) > 4 THEN 'Más de 4 Transacciones'
WHEN COUNT(t.id) = 4 THEN '4 Transacciones'
ELSE 'Tiene menos de 4 Transacciones'
END AS Clasificación
FROM company c 
JOIN transaction t ON c.id = t.company_id
GROUP BY Empresa
ORDER BY Cant_Transacción DESC;
 
 








