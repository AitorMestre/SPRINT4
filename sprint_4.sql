SELECT*FROM COMPANIES;
SELECT* FROM CREDIT_CARDS;
SELECT* FROM PRODUCTS;
SELECT* FROM TRANSACTIONS;
SELECT* FROM users_ca;
SELECT * FROM users_uk;
SELECT* FROM users_usa;

#TABLA TRANSACTION CAMBIOS DE FORMATO DE LOS CAMPOS:
ALTER TABLE transactions
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN card_id VARCHAR(25),
MODIFY COLUMN business_id VARCHAR(25),
MODIFY COLUMN timestamp date,
MODIFY COLUMN product_ids VARCHAR(50),
MODIFY COLUMN user_id VARCHAR(50);

#TABLA COMPANIES CAMBIOS DE FORMATO:
ALTER TABLE companies
MODIFY COLUMN company_id VARCHAR(50),
MODIFY COLUMN phone VARCHAR(25),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN country VARCHAR(25),
MODIFY COLUMN website VARCHAR(50);

#TABLA credit_cards CAMBIOS DE FORMATO:
ALTER TABLE credit_cards
MODIFY COLUMN id VARCHAR (50),
MODIFY COLUMN user_id VARCHAR(50),
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN pan VARCHAR(50),
MODIFY COLUMN pin VARCHAR(10),
MODIFY COLUMN cvv VARCHAR(10),
MODIFY COLUMN track1 VARCHAR(50),
MODIFY COLUMN track2 VARCHAR(50),
MODIFY COLUMN expiring_date VARCHAR(10);

#TABLA PRODUCTS DE FORMATO:
ALTER TABLE products
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN product_name VARCHAR(50),
MODIFY COLUMN price VARCHAR(50),
MODIFY COLUMN colour VARCHAR(10),
MODIFY COLUMN weight VARCHAR(10),
MODIFY COLUMN warehouse_id VARCHAR(50);

#TABLA users_ca DE FORMATO:
ALTER TABLE users_ca
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN name VARCHAR(15),
MODIFY COLUMN surname VARCHAR(15),
MODIFY COLUMN phone VARCHAR(50),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN birth_date VARCHAR(20),
MODIFY COLUMN country VARCHAR(15),
MODIFY COLUMN city VARCHAR(25),
MODIFY COLUMN postal_code VARCHAR(10),
MODIFY COLUMN address VARCHAR(50);

#TABLA users_uk DE FORMATO:
ALTER TABLE users_uk
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN name VARCHAR(15),
MODIFY COLUMN surname VARCHAR(15),
MODIFY COLUMN phone VARCHAR(50),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN birth_date VARCHAR(20),
MODIFY COLUMN country VARCHAR(15),
MODIFY COLUMN city VARCHAR(25),
MODIFY COLUMN postal_code VARCHAR(10),
MODIFY COLUMN address VARCHAR(50);

#TABLA users_usa DE FORMATO:
ALTER TABLE users_usa
MODIFY COLUMN id VARCHAR(50),
MODIFY COLUMN name VARCHAR(15),
MODIFY COLUMN surname VARCHAR(15),
MODIFY COLUMN phone VARCHAR(50),
MODIFY COLUMN email VARCHAR(50),
MODIFY COLUMN birth_date VARCHAR(20),
MODIFY COLUMN country VARCHAR(15),
MODIFY COLUMN city VARCHAR(25),
MODIFY COLUMN postal_code VARCHAR(10), 
MODIFY COLUMN address VARCHAR(50);

##AÑADIMOS LAS PK Y FK DE LAS TABLAS:
#TABLA TRANSACTIONS:
/*ALTER TABLE transactions
ADD PRIMARY KEY (id);

ALTER TABLE COMPANIES
ADD PRIMARY KEY (company_id);

ALTER TABLE CREDIT_CARDS
ADD PRIMARY KEY (id);

ALTER TABLE PRODUCTS
ADD PRIMARY KEY (id);

ALTER TABLE users_ca
ADD PRIMARY KEY (id);

ALTER TABLE users_uk
ADD PRIMARY KEY (id);

ALTER TABLE users_usa
ADD PRIMARY KEY (id);*/

#combino la tablas de users para tener solo una
CREATE TABLE users_combined AS
SELECT *, 'Canada' AS country_origin FROM users_ca
UNION ALL
SELECT *, 'United Kingdom' AS country_origin FROM users_uk
UNION ALL
SELECT *, 'United States' AS country_origin FROM users_usa;

ALTER TABLE users_combined
ADD PRIMARY KEY (id);

# FK:
alter table transactions
add foreign key (card_id) references credit_cards(id);

alter table transactions
add foreign key (business_id) references companies(company_id);

alter table transactions
add foreign key (user_id) references users_combined(id);

#Exercici 1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT u.id, u.name, u.email
FROM users_combined u
WHERE 30 < (
    SELECT COUNT(*)
    FROM transactions t
    WHERE t.user_id = u.id
);


#- Exercici 2
#Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT AVG(t.amount) as average_amount, c.iban
FROM transactions t
JOIN credit_cards c ON t.card_id = c.id
join companies co on t.business_id = co.company_id
WHERE co.company_name = 'Donec Ltd'
GROUP BY c.iban;

#nivell 2:
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:
#Exercici 1
#Quantes targetes estan actives?

CREATE TABLE credit_card_status AS
SELECT 
    card_id, 
    COUNT(*) AS successful_transactions,
    'active' AS status
FROM transactions
WHERE declined = 0
GROUP BY card_id
HAVING COUNT(*) >= 3;

select* from credit_card_status;
CREATE TABLE credit_card_status AS
WITH last_three_transactions AS (
    SELECT 
        card_id, 
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY transaction_date DESC) AS rn
    FROM transactions
)
SELECT 
    card_id,
    SUM(CASE WHEN declined = 0 THEN 1 ELSE 0 END) AS successful_transactions,
    CASE 
        WHEN SUM(CASE WHEN declined = 0 THEN 1 ELSE 0 END) > 0 THEN 'active'
        ELSE 'inactive'
    END AS status
FROM last_three_transactions
WHERE rn <= 3
GROUP BY card_id;

select* from credit_card_status;



#NIVELL 3

#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada,
# tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

#Exercici 1
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.



CREATE TABLE transaction_products (
    transaction_id VARCHAR(50),
    product_id VARCHAR(50),
    FOREIGN KEY (transaction_id) REFERENCES transactions(product_ids),
    FOREIGN KEY (product_id) REFERENCES products(id)
);
SELECT 
    p.id AS product_id,
    p.product_name AS name,
    COUNT(tp.product_id) AS times_sold
FROM 
    products p
LEFT JOIN
    transaction_products tp ON p.id = tp.product_id
GROUP BY 
    p.id, p.name
ORDER BY 
    times_sold DESC;

select * from transaction_products;













