-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»

-- №1 Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.

SELECT * FROM users;
UPDATE users SET updated_at = NOW();
UPDATE users SET created_at = NOW();

-- №2 Таблица users была неудачно спроектирована. 
-- Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
-- Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

DROP TABLES IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
  ('Геннадий', '1990-10-05', '07.01.2016 12:15', '07.01.2016 12:15'),
  ('Наталья', '1984-11-12', '07.05.2016 06:01', '07.05.2016 06:01'),
  ('Александр', '1985-05-20', '10.01.2019 12:05', '10.01.2019 12:05'),
  ('Сергей', '1988-02-14', '15.05.2016 12:05', '15.05.2016 12:05'),
  ('Иван', '1998-01-12', '02.12.2010 14:05', '02.12.2010 14:05'),
  ('Мария', '1992-08-29', '07.06.2013 16:15', '07.06.2013 16:15');

SELECT STR_TO_DATE(created_at, '%d.%m.%Y %k:%i') FROM users;
UPDATE users set created_at=STR_TO_DATE(created_at, '%d.%m.%Y %k:%i'), updated_at=STR_TO_DATE(updated_at, '%d.%m.%Y %k:%i');
DESC users;
ALTER TABLE users CHANGE created_at created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users CHANGE updated_at updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;


-- №3 В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, 
-- если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
-- чтобы они выводились в порядке увеличения значения value. 
-- Однако нулевые запасы должны выводиться в конце, после всех записей.

SELECT * FROM storehouses_products;
DESC storehouses_products;

INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES
  (1, 543, 0),
  (1, 789, 2500),
  (1, 3432, 0),
  (1, 826, 30),
  (1, 719, 500),
  (1, 638, 1);

SELECT * FROM storehouses_products ORDER BY value;
SELECT id, value, IF(value > 0, 0, 1) AS sort FROM storehouses_products ORDER BY value;
SELECT * FROM storehouses_products ORDER BY IF(value > 0, 0, 1), value;


-- №4 (по желанию) Из таблицы users необходимо извлечь пользователей, 
-- родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)

SELECT * FROM users;
SELECT name, DATE_FORMAT(birthday_at, '%M') FROM users;
SELECT name FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('May', 'August');

-- №5 (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
-- Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM catalogs;
DESC catalogs;
-- SELECT FIELD(2, 5, 1, 2); 
SELECT id, name, FIELD(id, 5, 1, 2) AS pos FROM catalogs WHERE id IN (5, 1, 2);
SELECT* FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);


-- Практическое задание теме «Агрегация данных».

-- №1 Подсчитайте средний возраст пользователей в таблице users. OK

SELECT YEAR(CURRENT_TIMESTAMP) - YEAR(birthday_at) as age FROM users;
SELECT AVG(age) FROM (SELECT YEAR(CURRENT_TIMESTAMP) - YEAR(birthday_at) as age FROM users) AS Avg_age;

-- №2 Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT name, birthday_at FROM users;
SELECT MONTH(birthday_at), DAY(birthday_at) FROM users;
SELECT YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at) FROM users;
SELECT CONCAT_WS('-',YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at)) AS day FROM users;
SELECT DATE(CONCAT_WS('-',YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))) AS day FROM users;
SELECT DATE_FORMAT(DATE(CONCAT_WS('-',YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day FROM users;
SELECT DATE_FORMAT(DATE(CONCAT_WS('-',YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day FROM users GROUP BY day;
-- решение:
SELECT DATE_FORMAT(DATE(CONCAT_WS('-',YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day, COUNT(*) AS total FROM users GROUP BY day ORDER BY total DESC;

-- №3 (по желанию) Подсчитайте произведение чисел в столбце таблицы.

SELECT id FROM catalogs;
SELECT ROUND(EXP(SUM(LN(id)))) FROM catalogs;

------------------------------------------------------------------------------------------------------

-- БД:

CREATE DATABASE shop;
USE shop;

DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название раздела',
  UNIQUE unique_name(name(10))
) COMMENT = 'Разделы интернет-магазина';

INSERT INTO catalogs VALUES
  (NULL, 'Процессоры'),
  (NULL, 'Материнские платы'),
  (NULL, 'Видеокарты'),
  (NULL, 'Жесткие диски'),
  (NULL, 'Оперативная память');

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Покупатели';

INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DROP TABLE IF EXISTS products;
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  description TEXT COMMENT 'Описание',
  price DECIMAL (11,2) COMMENT 'Цена',
  catalog_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_catalog_id (catalog_id)
) COMMENT = 'Товарные позиции';

INSERT INTO products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1),
  ('AMD FX-8320E', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 4780.00, 1),
  ('AMD FX-8320', 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', 7120.00, 1),
  ('ASUS ROG MAXIMUS X HERO', 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', 19310.00, 2),
  ('Gigabyte H310M S2H', 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', 4790.00, 2),
  ('MSI B250M GAMING PRO', 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', 5060.00, 2);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id)
) COMMENT = 'Заказы';

DROP TABLE IF EXISTS orders_products;
CREATE TABLE orders_products (
  id SERIAL PRIMARY KEY,
  order_id INT UNSIGNED,
  product_id INT UNSIGNED,
  total INT UNSIGNED DEFAULT 1 COMMENT 'Количество заказанных товарных позиций',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Состав заказа';

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id SERIAL PRIMARY KEY,
  user_id INT UNSIGNED,
  product_id INT UNSIGNED,
  discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
) COMMENT = 'Скидки';

DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Название',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Склады';

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';
