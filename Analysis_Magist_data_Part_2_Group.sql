/* Details of the Company Eniacs's income:
(data from April 2017 – March 2018):
Revenue: 40,044,542 €
Avg monthly revenue: 1,011,256 €
Avg order price: 710 €
Avg item price: 540 € */

-- TOPIC 1: In relation to the products:
-- Q1a. What categories of tech products does Magist have?
/* There are 6 categories of Tech products Magist Have:
Category_name	Category_name_eng	Product_counts
 informatica_acessorios	computer_accessories	1639
 telefonia	telephony	1134
 eletronicos	electronics	517
 consoles_games	game_consoles	317
 audio	audio	58
 pcs	pcs	30 */

-- Q1b. How many products of these tech categories have been sold (within the time window of the database snapshot)?
-- What percentage does that represent from the overall number of products sold?
SELECT product_category_name, COUNT(oi.product_id) AS Counts_product_id, (Count(*)/112650*100) As Percentage
FROM products p INNER JOIN order_items oi ON p.product_id = oi.product_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
GROUP BY product_category_name;

/* There are 112650 products sold
*/

/* Debugging section
SELECT product_category_name, COUNT(oi.product_id) AS Counts_product_id, (Count(*)/112650*100) As Percentage
FROM products AS p INNER JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE product_category_name LIKE ('%eletro%')
GROUP BY product_category_name; */

-- Q1c. What’s the average price of the products being sold?
SELECT AVG(price)
FROM products p INNER JOIN order_items oi ON p.product_id = oi.product_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs');

/*  Average price for MAGIST is 108.47 EUR
	Average price for ENIAC is 540 EUR */

SELECT product_category_name AS product_cat_name, COUNT(oi.product_id) AS product_counts, ROUND(AVG(price), 2) as Average_price, MAX(price) AS max_price, MIN(price) AS min_price
FROM 
	products p
	INNER JOIN
    order_items oi
    ON p.product_id = oi.product_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
GROUP BY product_category_name
ORDER BY COUNT(oi.product_id) DESC
;

/* prod_cat_name 	product_counts 	Average_price 	  max_price 	min_price
	informatica_acessorios	7827		116.51			3699.99			3.9
	telefonia				4545		71.21			2428			5
	eletronicos				2767		57.91			2470.5			3.99
	consoles_games			1137		138.49			4099.99			5.18
	audio					364			139.25			598.99			14.9
	pcs						203			1098.34			6729			34.5 
    
    We have only one category with a highest average itemprice: 1098.34 (pcs)
    All other tech-categories have a lower average price
    We have only one category with a lowest average itemprice: 57.91 (eletronicos)
    */

-- Q1d.Are expensive tech products popular?
SELECT 
	p.product_category_name, COUNT(oi.order_id) AS order_count,
CASE 
      WHEN p.product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs') THEN 'Tech'
      ELSE 'Non Tech'
  END AS 'Category'
    FROM products AS p
    INNER JOIN order_items AS oi ON p.product_id = oi.product_id
    INNER JOIN orders AS o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name, 'Category'
ORDER BY Category DESC;
/* Here we found that total tech catg. makes 15% of the etired product sold, 
so it might not be most popular one, yet significant. */  
/* MAGIC lines:
-- COUNT(oi.product_id) AS product_sold,
-- COUNT(p.product_id) AS total_products
-- (product_sold/total_products) AS 'Percentage'
-- COUNT(oi.product_id) AS product_counts,
-- ROUND(AVG(price), 2) as Average_price, 
-- MAX(price) AS max_price,
-- MIN(price) AS min_price */

-- Topic 2. In relation to the sellers:
-- Q2a. How many months of data are included in the magist database?
SELECT COUNT(order_id) AS order_count, MONTH(order_purchase_timestamp) AS Month, YEAR(order_purchase_timestamp) AS Year
FROM orders
GROUP BY Year, Month
ORDER BY Year;
/* Two years and one month data is 
included in the magist database */

-- Q2b. How many sellers are there? How many Tech sellers are there? 
-- What percentage of overall sellers are Tech sellers?
SELECT COUNT(distinct seller_id) AS sellers_count
FROM order_items;

SELECT Count(distinct s.seller_id) AS tech_sellers
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
;

SELECT Count(distinct s.seller_id)
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs') 
AND o.order_purchase_timestamp < '2017-01-01' AND o.order_purchase_timestamp > '2016-01-01'
;

/* Seller details based on sales
-- --> There are 3095 sellers in total (who also sold stuff) the same amount as all sellers from the sellers table.
-- --> There are 476 sellers in the tech segment
-- --> 15.4% of sellers are tech sellers "SELECT(476/3095*100); -- --> 15.3796% "
-- 2018: 360 tech sellers (for 10 months)
-- 2017: 275 tech sellers (for 12 months)
-- 2016:  22 tech sellers (for 4 months) 
*/

-- Q2c. What is the total amount earned by all sellers? 
-- Q2d. What is the total amount earned by all Tech sellers?
SELECT SUM(oi.price)
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs') 
-- AND o.order_purchase_timestamp < '2017-01-01' AND o.order_purchase_timestamp > '2016-01-01'
;

SELECT SUM(price), p.product_category_name
FROM order_items AS oi
JOIN sellers AS s ON oi.seller_id = s.seller_id
JOIN products AS p on oi.product_id = p.product_id 
WHERE p.product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
GROUP BY s.seller_id, p.product_category_name;

/* all sellers: 13,591,643.7 for all 26 months and all sellers. 
-- Compared to our company Eniac it has much less revenue (40,044,542 for 12 months April 2017 - March 2018)
-- tech sellers: 1,826,985.44. for all 26 months and tech sellers only.
-- Percentage of revenue of tech sellers: 13.4 % SELECT(1826985.44 / 13591643.7 * 100); -- 13.4419

-- Can you work out the average monthly income of all sellers? 
-- Can you work out the average monthly income of Tech sellers?
-- all sellers: 13,591,643.7   for all 26 months and all sellers. 
-- tech sellers: 1,826,985.44. for all 26 months and tech sellers only.
SELECT (13591643.7 / 26); -- 522,755.53
SELECT (1826985.44 / 26); --  70,268.67 */

-- Topic 3. In relation to the delivery time:
-- Q3a. What’s the average time between the order being placed and the product being delivered?
SELECT 
    order_status, 
    AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS 'Average_Duration_in_days'
FROM orders
GROUP BY order_status;

/* the average time between the order being placed and the product being delivered is 12 days
and it takes around 20 days to reach a conclusion that order is cancelled */

-- Q3b. How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    CASE
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0 THEN 'Arrived on time'
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'Delayed'
        ELSE 'Unknown'
    END AS Delivery_Status, COUNT(*) AS Delivery_counts
FROM orders
GROUP BY Delivery_Status;

/*Delivery status:
Total Shipments = 99441
Arrived on time: 89810; Percentage of arrived on time = 90.31%
Delayed: 6666; Percentage of shipments delayed = 6.70%
Unknown: 2965; Percentage of shipments unknow/lost = 2.98%
*/

-- Q3c. Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT
    CASE 
		WHEN product_weight_g < 2000 AND product_length_cm < 60 AND product_width_cm < 30 AND product_height_cm < 15 THEN 'Packet 2kg'
        WHEN product_weight_g < 5000 AND product_length_cm < 120 AND product_width_cm < 60 AND product_height_cm < 60 THEN 'Packet 5kg'
        ELSE 'Packet big'
	END AS PacketSize, 
    Count(*), 
    AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS Delay
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
 JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered' 
-- AND product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
AND order_estimated_delivery_date < order_delivered_customer_date
GROUP BY PacketSize;

/* Pattern in delayed for heavy products:
-- NOTES: for TECH products: 
-- PAKET 2kg has most counts (1019). and a delay of 8 days (only for those who arrived later than estimated)
-- PAKET 5kg has 281 counts and a delay of 7.7 days
-- PAKET big has fewer counts 73 and a delay of 8 days

-- for all products:  (only delayed ones)
-- approximately 1 day more delay
-- the bigger the product the little later the delay (not significant for tech products)
-- a significant pattern could not be concluded */
