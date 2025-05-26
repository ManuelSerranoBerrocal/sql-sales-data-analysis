-- PROYECTO: CREACIÓN Y CARGA DE BASE DE DATOS SPRINT 4
-- Autor: Manel Serrat - IT Academy
-- Creamos la base de datos
DROP DATABASE IF EXISTS transactions_db;
CREATE DATABASE transactions_db;
USE transactions_db;
 -- (columnas) id,name,surname,phone,email,birth_date,country,city,postal_code,address 
 -- id,name,surname,phone,email,birth_date,country,city,postal_code,address
  -- Creamos la tabla user
CREATE TABLE IF NOT EXISTS user (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(150),
    email VARCHAR(150),
    birth_date DATE,
    country VARCHAR(150),
    city VARCHAR(150),
    postal_code VARCHAR(100),
    address VARCHAR(255)
);

-- company_id,company_name,phone,email,country,website
  -- Creamos la tabla company
CREATE TABLE IF NOT EXISTS company (
    company_id VARCHAR(15) PRIMARY KEY,
    company_name VARCHAR(255),
    phone VARCHAR(15),
    email VARCHAR(100),
    country VARCHAR(100),
    website VARCHAR(255)
);

-- id,user_id,iban,pan,pin,cvv,track1,track2,expiring_date
  -- Creamos la tabla credit_card
CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(20) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(20),
    pin VARCHAR(4),
    cvv VARCHAR(4),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE
);

-- id	card_id	business_id	timestamp	amount	declined	product_ids	user_id	lat	longitude
  -- Creamos la tabla transactions
CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(20),
    business_id VARCHAR(15),
    timestamp timestamp, 
    amount DECIMAL(10,2),
    declined BOOLEAN,
    product_ids VARCHAR(255), 
    user_id INT,
    lat VARCHAR(50),
    longitude VARCHAR(50),
    FOREIGN KEY (card_id) REFERENCES credit_card(id),
    FOREIGN KEY (business_id) REFERENCES company(company_id),
    FOREIGN KEY (user_id) REFERENCES user(id)
);

SELECT * FROM transactions;

-- Se procederá a cargar los archivos csv
-- Antes de cargar verificamos si está activado 'local_infile', para poder cargar los archivos
SHOW VARIABLES LIKE 'local_infile';

-- tenemos que activar local_infile en el servidor
-- Activa la opción para todas las sesiones nuevas, pero no afecta la sesión actual.
SET GLOBAL local_infile = 'ON';

-- El siguiente comando nos ayuda a conocer la ruta en donde se deben colocar 
-- los archivos *.csv para proceder con la carga de data
SHOW VARIABLES LIKE "secure_file_priv";

-- Después de activarlo, cerré sesión del MySQL y volví a ingresar
-- Se comienza a cargar el archivo de los usuarios comenzando por users_usa.csv, ya que tiene los ID desde 1 hasta 150
-- al cargar la data, se aprovecha en convertir: birth_date al formato date
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

SELECT * FROM user;

-- Se continúa con el archivo users_uk.csv, ya que tiene los ID desde 151 hasta 200
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

SELECT * FROM user;

-- Se continúa con el archivo users_ca.csv, ya que tiene los ID desde 201 hasta 275
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv'
INTO TABLE user
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(id, name, surname, phone, email, @birth_date, country, city, postal_code, address)
SET birth_date = STR_TO_DATE(@birth_date, '%b %d, %Y');

SELECT * FROM user;

-- Se continúa con la carga en la tabla company
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv'
INTO TABLE company
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM company;

-- Se carga la tabla credit_card
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv'
INTO TABLE credit_card
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, user_id, iban, pan, pin, cvv, track1, track2, @expiring_date)
SET expiring_date = STR_TO_DATE(@expiring_date, '%m/%d/%y');

SELECT * FROM credit_card;

-- Carga de la tabla transactions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from transactions;

/* Nivel 1
•	Ejercicio 1
Realiza una subconsulta que muestre todos los usuarios con más de 30 transacciones utilizando al menos 2 tablas. */
-- Seleccionamos todos los campos de la tabla de usuarios
SELECT * 
FROM user u
-- Para cada usuario, verificamos cuántas transacciones tiene
WHERE (
    SELECT COUNT(*)        -- Contamos cuántas transacciones tiene ese usuario
    FROM transactions t     -- Buscamos en la tabla de transacciones
    WHERE t.user_id = u.id -- Solo las transacciones que pertenecen a este usuario
) > 30;                    -- Filtramos solo los usuarios con más de 30 transacciones

/* •	Ejercicio 2
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd, utilizando al menos 2 tablas. */
SELECT cc.iban AS Iban, ROUND(AVG(t.amount), 2) AS Media_Amount
FROM credit_card cc
JOIN transactions t ON cc.id = t.card_id
JOIN company c ON t.business_id = c.company_id
WHERE c.company_name = 'Donec Ltd'
GROUP BY cc.iban;

/* Nivel 2
Crea una nueva tabla que refleje el estado de las tarjetas de crédito basándote en 
si las últimas tres transacciones fueron rechazadas y genera la siguiente consulta: */

DROP TABLE IF EXISTS card_status;
-- Creamos la tabla card_status que guardará el estado de cada tarjeta
CREATE TABLE card_status (
    card_id VARCHAR(20) PRIMARY KEY,
    status VARCHAR(10), -- Puede ser 'activa' o 'inactiva'
    FOREIGN KEY (card_id) REFERENCES credit_card(id) -- Relación directa con credit_card
);

SELECT * from card_status;

-- Insertamos una fila por cada tarjeta indicando si está activa o inactiva
-- Insertamos el estado de cada tarjeta según sus 3 últimas transacciones
INSERT INTO card_status (card_id, status)
SELECT card_id,
    CASE 
        WHEN SUM(declined) = 3 THEN 'inactiva'  -- Las 3 últimas transacciones fueron rechazadas
        ELSE 'activa'                           -- Al menos una fue aceptada
    END AS status
FROM (
    -- Numeramos las transacciones por tarjeta desde la más reciente
    SELECT card_id, declined,
    -- Enumeramos las transacciones por tarjeta, desde la más reciente
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS fila 
    FROM transactions 
    WHERE card_id IS NOT NULL -- Filtramos las transacciones que tienen un card_id no nulo
) AS ultimas
-- Nos quedamos con las 3 más recientes por tarjeta
WHERE fila <= 3 -- Filtramos para quedarnos solo con las 3 últimas transacciones por tarjeta
GROUP BY card_id; -- Agrupamos por card_id para calcular el estado de cada tarjeta

SELECT * from card_status;

/*	Ejercicio 1
¿Cuántas tarjetas están activas? */

SELECT COUNT(*) AS tarjetas_activas
FROM card_status
WHERE status = 'activa';


/* Nivel 3
Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
teniendo en cuenta que desde transactions tienes product_ids. Genera la siguiente consulta: */

-- creamos latabla products
DROP TABLE IF EXISTS products;
CREATE TABLE products (
    id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2),         -- Precio como número decimal
    currency_symbol CHAR(1),     -- Nuevo campo para almacenar el símbolo '$'
    colour VARCHAR(20),
    weight DECIMAL(8,2),
    warehouse_id VARCHAR(10)
);

-- Carga de la tabla products
-- carga el CSV y se convierte el campo price y se crea una nueva columna para el símbolo de moneda
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@id, @product_name, @price_raw, @colour, @weight, @warehouse_id)
SET
    id = @id,
    product_name = @product_name,
    price = CAST(SUBSTRING(@price_raw, 2) AS DECIMAL(10,2)), -- Quitamos el símbolo $
    currency_symbol = SUBSTRING(@price_raw, 1, 1),           -- Guardamos el símbolo $
    colour = @colour,
    weight = @weight,
    warehouse_id = @warehouse_id;

SELECT * FROM products;


--  Como las tablas products y transactions son de muchos amuchos , se creará una tablaintermedio: transactions_product
-- Creación de la tabla transactions_product
CREATE TABLE IF NOT EXISTS transactions_product (
    transactions_id VARCHAR(255),
    product_id INT,
    PRIMARY KEY (transactions_id, product_id),
    FOREIGN KEY (transactions_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

SELECT * FROM transactions_product;

-- Carga de la tabla intermedia transactions_product:
-- Insertamos  transactions_id - product_id en la tabla intermedia
INSERT INTO transactions_product (transactions_id, product_id)
SELECT 
    t.id AS transactions_id,
    p.id AS product_id
FROM transactions t
JOIN products p 
    ON FIND_IN_SET(p.id, t.product_ids) > 0; -- Utilizamos FIND_IN_SET para buscar product_ids en la lista separada por comas
    
SELECT * FROM transactions_product;
    
-- Nivel 3, Ejercicio 1
-- Necesitamos conocer el número de veces que se ha vendido cada producto.
-- Número de veces que se ha vendido cada producto
SELECT 
    product_id, 
    COUNT(*) AS cantidad_vendida
FROM transactions_product
GROUP BY product_id
ORDER BY cantidad_vendida DESC;


