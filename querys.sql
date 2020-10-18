/*
 *********************************************** 
 **Представления, триггеры, хранимые процедуры**
 ***********************************************
*/

-- Ягоды на всех точках продажи
CREATE or replace VIEW berries_on_point_sales
AS
 SELECT
  p.name AS 'Наименование товара',
  ps.point_name AS 'Точка продажи',
  ptps.total AS 'Кол-во товара', 
  ptps.created_at AS 'Приход товара'
 FROM
  categories AS c2 
 JOIN 
  products AS p 
 ON
  c2.id = p.cat_id AND c2.name = 'Ягоды'
 JOIN
  products_to_point_sales AS ptps
 ON 
  ptps.product_id = p.id
 JOIN
  point_sales AS ps
 ON
  ps.id = ptps.point_id
 ORDER BY ps.point_name;  

-- Проданный товар за декабрь по всем точкам продаж
CREATE or replace VIEW realized_december_products
AS
 SELECT
  p.name AS 'Наименование товара',
  ps.point_name AS 'Точка продажи',
  rp.weight_or_count AS 'Кол-во товара',
  rp.sold_at AS 'Дата продажи'
 FROM 
  realized_products AS rp
 JOIN
  products_to_point_sales AS ptps
 ON 
  ptps.id = rp.product_on_point_id
 AND
  MONTH(rp.sold_at) = 12
 JOIN
  point_sales AS ps
 ON
  ps.id = ptps.point_id
 JOIN 
  products AS p
 ON 
  ptps.product_id = p.id
 ORDER BY
  ps.point_name;

 
-- Триггер для создания токена аутентификации 
-- при создании учетной записи пользователя
drop TRIGGER if exists `create_user_auth_token`;
DELIMITER //
CREATE TRIGGER `create_user_auth_token`
AFTER INSERT ON accounts FOR EACH ROW
BEGIN 
   DECLARE `_token` VARCHAR(255) DEFAULT 'token';
   DECLARE `_token_id` INT DEFAULT 0;
  
   SET `_token` = TO_BASE64(UUID());
   INSERT INTO tokens (token) VALUES (`_token`);
   
   SET `_token_id` = (SELECT t2.id FROM tokens AS t2 WHERE t2.token = `_token`);
  
   INSERT INTO accounts_to_tokens 
    (token_id, account_id)
   VALUES
    (`_token_id`, NEW.id);
   
END//
DELIMITER ;

-- Хранимая процедура по продаже товара.
-- Кол-во проданного товара вычитается из таблицы products_to_point_sales
-- и записывает данные о проданном товаре в таблицу realized_products  
DROP PROCEDURE IF EXISTS `sell_product_position`;
DELIMITER $$
CREATE PROCEDURE `sell_product_position`(product_on_point_id INT,
                                         product_count INT,
                                         vendor_id INT,
                                         OUT tran_result varchar(200))
BEGIN
 DECLARE `_rollback` BOOL DEFAULT 0;
 DECLARE code varchar(100);
 DECLARE error_string varchar(100);

 DECLARE product_price DECIMAL (11,2);

 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
 begin
  SET `_rollback` = 1;
  GET stacked DIAGNOSTICS CONDITION 1
   code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
    set tran_result := concat('Error occured. Code: ', code, '. Text: ', error_string);
 end;
		        
 START TRANSACTION;
 -- Вычитаем кол-во проданного товара с точки продажи
 UPDATE products_to_point_sales 
  SET total = total - product_count
 WHERE
  id = product_on_point_id;
 
 -- Получаем стоимость товара за кг./единицу
  SET product_price = (SELECT 
                        p2.price 
                       FROM 
                        products AS p2 
                       JOIN 
                        products_to_point_sales AS ptps
                       ON
                        p2.id = ptps.product_id
                       AND
                        ptps.id = product_on_point_id);
                       
 -- Результат записываем в таблицу реализованного товара
 INSERT INTO realized_products 
  (product_on_point_id, weight_or_count, total, vendor_id)
 VALUES
  (product_on_point_id, product_count, product_price * product_count, vendor_id);

 IF `_rollback` THEN
  ROLLBACK;
 ELSE
  set tran_result := 'ok';
  COMMIT;
 END IF;
END$$
DELIMITER ;
