 -- 1. Primero, crea la tabla credit_card
 -- Creamos la tabla credit_card
 CREATE TABLE IF NOT EXISTS credit_card (
    id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(34),
    pan VARCHAR(19),
    pin VARCHAR(6),
    cvv VARCHAR(4),
    expiring_date VARCHAR(10));
-- Ahora antes de hacer un ALTER TABLE transaction, lo primero que tengo que hacer es 
-- correr el archivo datos_introducir_credit.sql para llenar la tabla credit_card 
--  Luego, en la tabla transaction, se realiza el ALTER TABLE para agregar la clave foránea 
-- que relaciona credit_card_id con credit_card(id):

-- Verificamos que se hayan ingresado los datos en la tabla credit_card
SELECT * FROM credit_card;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- Ahora al cargar ek diagrama se percata que la relación de transactipon y user está mal, 
-- y se verifica que almomento de crear la tabla user, 
-- se creo un foreign key que apunta a transaction lo cual sugiere que un usuario solo 
-- puede estar asociado a una única transacción, lo que es incorrecto.

-- PASO 1: Averiguar el nombre de la clave foránea mal puesta
-- Se utiliza la siguiente consulta para encontrar el nombre exacto de la foreign key en la tabla user:
SELECT constraint_name
FROM information_schema.key_column_usage
WHERE table_name = 'user' AND referenced_table_name = 'transaction';



-- Paso 2  Ahora simplemente se ejecuta la instrucción para eliminarla:
ALTER TABLE user DROP FOREIGN KEY user_ibfk_1;

-- ¿Qué se está corrigiendo con esto?
-- Se está corrigiendo una relación mal definida. La tabla user no debería depender de transaction, 
-- sino al revés: una transacción pertenece a un usuario, y no un usuario a una transacción.

-- Paso 3 Una vez eliminada se procede a crear correctamente la relación desde transaction hacia user:
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id) REFERENCES user(id);

 /* Agregar la relación correcta
Ejecuta esta sentencia:
*/
ALTER TABLE transaction
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id) REFERENCES user(id);


-- PASO 3  Comprobar que se eliminó
-- Puedes volver a correr esta consulta para verificar:

SELECT * 
FROM information_schema.table_constraints 
WHERE table_name = 'user' AND constraint_type = 'FOREIGN KEY';
-- Si no aparece ninguna constraint hacia transaction, entonces todo fue exitoso.

-- ****  Ejercicio 2  ****
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta del usuario con ID CcU-2938. 
-- La información que debe mostrarse para este registro es: R323456312213576817699999. 
-- Recuerda mostrar que el cambio se realizó.
-- Primero, actualizamos el campo iban en la tabla credit_card para ese usuario (con ID CcU-2938):
SELECT * FROM credit_card WHERE ID = 'CcU-2938';
-- Se actualiza el registro
UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';
-- Luego, se verifica que el cambio se realizó correctamente:
SELECT id, iban
FROM credit_card
WHERE id = 'CcU-2938';

/*  Ejercicio 3
-- En la tabla "transaction" ingresa un nuevo usuario con la siguiente información:
Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
credit_card_id	CcU-9999
company_id	b-9999
user_id	9999
lat	829.999
longitude	-117.999
amount	111.11
declined	0
*/
 -- Importante: Antes de ejecutar, tenemos que asegurarnos: Verificar si existe la tarjeta 'CcU-9999' en credit_card:
SELECT * FROM credit_card WHERE id = 'CcU-9999';
-- Verificar si existe la compañía 'b-9999' en company:
SELECT * FROM company WHERE id = 'b-9999';
-- Verificar si existe el usuario con id = 9999 en user:
SELECT * FROM user WHERE id = 9999;
-- **SE REALIZARON LAS 3 CONSULTAS Y NO EXISTEN**, al no existir, 
-- lo primero que tenemos que hacer es insertar registros
-- 1. Insertar tarjeta CcU-9999:
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
VALUES ('CcU-9999', 'TR309999312213576817699999', '1234567812345678', '1234', '321', '12/31/27');
-- 2. Insertar compañía b-9999:
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'Kaleacuy Terapias Rehabilitacion', '34 61 39 78 291', 'manuelssoftware@gmail.com', 
'España', 'https://instagram.com/site');
-- 3. Insertar usuario 9999:
-- primero verificamos...
SELECT CONSTRAINT_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_NAME = 'user' 
  AND REFERENCED_TABLE_NAME = 'transaction';
-- da como resultado: 'user_ibfk_1'
-- Ahora sí, eliminamos el constraint mal puesta:
ALTER TABLE user DROP FOREIGN KEY user_ibfk_1;

-- Ahora si ingresaremos al nuevo usuario con "id": '9999'
INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address)
VALUES (9999, 'Manel', 'Capitan', '034-613-9782', 'nuevo.usuario@example.com', 'Mar 18, 1974', 
'España', 'Barcelona', '08031', 'Fabra i Puig 123');


-- Recién podremos insertar  en transaction para resolver el Nivel 1 ejercicio 3
INSERT INTO transaction (
    id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined
) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, NOW(), 111.11, 0);

-- Verificamos el ingreso del nuevo usuario en la tabla transaction con la información brindada:
SELECT * FROM transaction WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

/* - Ejercicio 4
Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. 
Recuerda mostrar el cambio realizado.*/
-- ** primero capturamos la pantalla con las columnas actuales
DESCRIBE credit_card;

-- Se elimina la columna pan según lo solicitado en el ejercicio 4
ALTER TABLE credit_card DROP COLUMN pan;

-- Verificamos las columnas de la tabla credit_card
DESCRIBE credit_card;

/* Nivel 2
Ejercicio 1
Elimina de la tabla transaction el registro con ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de datos.*/
-- Primero se verifica si el registro existe:
SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Confirmado, el registro sí existe, se procede a eliminarlo
DELETE FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- verificamos que se haya eliminado
SELECT * FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

/* Ejercicio 2
La sección de marketing desea tener acceso a información específica para realizar análisis 
y estrategias efectivas. Se ha solicitado crear una vista que proporcione detalles clave 
sobre las compañías y sus transacciones. 
Será necesaria que crees una vista llamada 
VistaMarketing que contenga la siguiente información: 
Nombre de la compañía. Teléfono de contacto. País de residencia. Promedio de compra realizado por cada compañía. 
Presenta la vista creada, ordenando los datos de mayor a menor media de compra.*/
 
CREATE OR REPLACE VIEW VistaMarketing AS
SELECT 
    c.company_name AS Nombre_Compania, 
    c.phone AS Telefono, 
    c.country AS Pais, 
    AVG(t.amount) AS Promedio_Compra
FROM company c 
JOIN transaction t ON c.id = t.company_id
GROUP BY c.company_name, c.phone, c.country
ORDER BY Promedio_Compra DESC;

-- Ejecutamos la vista para ver los resultados
SELECT * FROM VistaMarketing;

/* Ejercicio 3
Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"*/

SELECT * 
FROM vistamarketing
WHERE Pais = 'Germany';

/* Ejercicio 1
La semana próxima tendrás una nueva reunión con los gerentes de marketing. 
Un compañero de tu equipo realizó modificaciones en la base de datos, pero no recuerda cómo las realizó. 
Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:*/

-- Comparando los dos diagramas, se procede a ordenar las tablas como nos piden y comparamos las diferencias: 

-- 1.	Tabla user cambia a data_user
RENAME TABLE user TO data_user;
-- 2.	La columna email cambia de nombre a: personal_email. 
ALTER TABLE data_user CHANGE email personal_email VARCHAR(150);
-- 3.	Tabla credit_card: id VARCHAR(15) cambia a: id VARCHAR(20) 
ALTER TABLE credit_card MODIFY id VARCHAR(20);
-- 4.	iban VARCHAR(34) cambia a: iban VARCHAR(50) 
ALTER TABLE credit_card MODIFY iban VARCHAR(50);
-- 5.	pin VARCHAR(6) cambia a: pin VARCHAR(4) 
ALTER TABLE credit_card MODIFY pin VARCHAR(4);
-- 6.	cvv VARCHAR(4) cambia a: cvv INT 
ALTER TABLE credit_card MODIFY cvv INT;
-- 7.	expiring_date VARCHAR(10) cambia a: expiring_date VARCHAR(20) 
ALTER TABLE credit_card MODIFY expiring_date VARCHAR(20);
-- 8.	Se agrega una nueva columna: fecha_actual DATE. 
ALTER TABLE credit_card ADD COLUMN fecha_actual DATE;
-- 9.	Tabla company: Se elimina la columna website. 
ALTER TABLE company DROP COLUMN website;


/* Ejercicio 2:  La empresa también te solicita crear una vista llamada "InformeTecnico" que contenga la siguiente información:
ID de la transacción
Nombre del usuario/a
Apellido del usuario/a
IBAN de la tarjeta de crédito usada.
Nombre de la compañía de la transacción realizada.
Asegúrate de incluir información relevante de ambas tablas y utiliza alias para cambiar de nombre columnas según sea necesario.
Muestra los resultados de la vista, ordena los resultados de manera descendente en función de la variable ID de transaction. */

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id AS ID_Transaccion, u.name AS Nombre_del_Usuario, u.surname AS Apellido_del_Usuario, 
cr.iban AS IBAN_Tarjeta, c.company_name AS Nombre_de_la_Compañia
FROM data_user u 
JOIN transaction t ON u.id = t.user_id
JOIN credit_card cr ON t.credit_card_id = cr.id
JOIN company c ON t.company_id = c.id
ORDER BY ID_Transaccion DESC;

SELECT * FROM informetecnico;
