-- Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
UPDATE users
SET created_at = IF(created_at IS NULL, NOW(), created_at), updated_at = IF(updated_at IS NULL, NOW(), updated_at)
WHERE
 created_at IS NULL OR updated_at IS NULL ;

-- Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
ALTER TABLE users MODIFY created_at datetime;
ALTER TABLE users MODIFY updated_at datetime;

-- В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры:
-- 0, если товар закончился и выше нуля, если на складе имеются запасы.
-- Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value.
-- Однако, нулевые запасы должны выводиться в конце, после всех записей.
SELECT value FROM storehouses_products ORDER BY value != 0 DESC;

-- Подсчитайте средний возраст пользователей в таблице users
SELECT AVG(YEAR(NOW()) - YEAR(birthday_at)) FROM users;

-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT
	GROUP_CONCAT(name),
	WEEKDAY(birthday_at + INTERVAL (YEAR(NOW()) - YEAR(birthday_at)) YEAR) as `WEEKDAY`,
	COUNT(*)
FROM users
GROUP BY `WEEKDAY`;


