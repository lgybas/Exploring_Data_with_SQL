USE magist;

-- #1 How many orders? 	--> 99,441
SELECT Count(*) 
FROM orders;

SELECT Count(*) 
FROM order_items;

-- How many sellers? 	--> 3,095
-- How many products? 	--> 32,951 may include duplicates
-- How many products per Seller? - Top 3 Sellers with most products, Average Products per Seller, How many sellers with less than 10 products

-- #2 Are orders delivered?	--> 96,478 orders are delivered. That's 97.02 % of all orders.
-- 								But there are also 1,107 orders 'shipped' (1,11%) - What is the difference?
-- 							--> other order_status are: cancelled (0.62%), unavailable (0.61%), invoiced (0.31%), processing (0.30%), created (0.005%), approved (0.002%)
-- 								What is the sequence of order status? Is an invoiced order already delivered? 
-- 								There are many more orders in status 'shipped' than in 'invoiced', 'processing', 'created', and 'approved' combined.
SELECT 
	order_status, 
    Count(*),
    (Count(*)/99441*100) As Percentage
FROM
	orders
GROUP BY order_status
ORDER BY Percentage DESC;

-- #3 Is magist having user / usage growth? --> number of orders on a timescale

SELECT 
	YEAR(order_purchase_timestamp) AS 'year',
	MONTH(order_purchase_timestamp) AS 'month',
    COUNT(*)
FROM orders

GROUP BY year, month
ORDER BY year, month;

-- #4 How many products are there on the products table?
-- How many products? 	--> 32,951 may include duplicates, no duplicates

SELECT COUNT(DISTINCT product_id)
FROM products;


-- #5 Which are the categories with the most products?
-- 							There are no names for the products, just the lenght of the name and the category.
-- 							There are 74 product categories; 10 groups are mentioned more than 1000 times.

SELECT product_category_name, COUNT(product_category_name) AS categories
FROM products
GROUP BY product_category_name
ORDER BY categories DESC;

-- #6 How many of those products were present in actual transactions?  -- 32,951 so all products have been used as order_items

SELECT COUNT(DISTINCT product_id) 
FROM 
	order_items
;    

-- Which categories are ordered most often? - There are 22 categories with more than 1000 entries in order_item
SELECT product_category_name, COUNT(oi.product_id), 
FROM 
	products p
	INNER JOIN
    order_items oi
    ON p.product_id = oi.product_id
WHERE...
GROUP BY product_category_name
ORDER BY COUNT(oi.product_id) DESC
;    

-- How many products have only been ordered once? --- something else
SELECT product_category_name, COUNT(oi.product_id), ROUND(AVG(price), 2), MAX(price), MIN(price)
FROM 
	products p
	INNER JOIN
    order_items oi
    ON p.product_id = oi.product_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
GROUP BY product_category_name
ORDER BY COUNT(oi.product_id) DESC
;    

SELECT AVG(price)
FROM products p INNER JOIN order_items oi ON p.product_id = oi.product_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs');


-- #7 What’s the price for the most expensive and cheapest products? --> most expensive: 6,735 cheapest: 0.85
SELECT product_id, MAX(price), COUNT(product_id)
FROM order_items
GROUP BY product_id
ORDER BY COUNT(product_id) DESC
LIMIT 100
;

SELECT COUNT(product_id)
FROM order_items
-- GROUP BY product_id
ORDER BY COUNT(product_id) DESC
LIMIT 100
;


-- 

SELECT(112650 / 32951);


SELECT MIN(price)
FROM order_items;


-- ---------Business Questions -------------- --

SELECT
AVG(COUNT(product_id))
FROM order_items;


-- SELLERS-related
-- #1 How many months of data are included in the magist database? -- from sept 2016 to october 2018 --> that's 26 months
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM orders;


-- #2 How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
-- --> There are 3095 sellers in total (who also sold stuff) the same amount as all sellers from the sellers table.
-- --> There are 476 sellers in the tech segment
-- --> 15.4 percent of sellers are tech sellers

-- --> in the last 10 month of the data base there were 360 sellers in the tech segment
-- --> in the first 16 month of the data base there were 279 sellers in the tech segment

-- 2018: 360 tech sellers (for 10 months)
-- 2017: 275 tech sellers (for 12 months)
-- 2016:  22 tech sellers (for 4 months)

SELECT(476/3095*100); -- --> 15.3796%

SELECT Count(distinct s.seller_id)
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')
;

SELECT Count(distinct s.seller_id)
FROM sellers s;


-- Further Question: How many active sellers are there? (Who sold stuff in the last 3 month) (answer further above)
-- Further Question: Are there tech sellers, that have been around in 2016 or 2017 but left the market in 2018? - still open -

SELECT Count(distinct s.seller_id)
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs') 
AND o.order_purchase_timestamp < '2017-01-01' AND o.order_purchase_timestamp > '2016-01-01'
;


-- #3 What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- I left out the freight and only looked at the price

-- all sellers in 2016: 49785.92

-- all sellers: 13,591,643.7   for all 26 months and all sellers. 
-- 					Compared to our company Eniac it has much less revenue (40,044,542 for 12 months April 2017 - March 2018)
-- tech sellers: 1,826,985.44. for all 26 months and tech sellers only.
-- Percentage of revenue of tech sellers: 13.4 %

-- All techsellers combined had a yearly revenue of 1050630.4884 for 12 months April 2017 - March 2018
-- Eniac had a yearly revenue of 40,044,542 in the same timeframe -- are all currencies in EUR? even though it is the portugese market?

SELECT(1826985.44 / 13591643.7 * 100); -- 13.4419

SELECT SUM(oi.price)
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN orders o ON oi.order_id = o.order_id
WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs') 
AND o.order_purchase_timestamp < '2018-03-01' AND o.order_purchase_timestamp > '2017-04-01'
;



-- #4 Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

-- all sellers: 13,591,643.7   for all 26 months and all sellers. 
-- tech sellers: 1,826,985.44. for all 26 months and tech sellers only.

SELECT (13591643.7 / 26); -- 522,755.53
SELECT (1826985.44 / 26); --  70,268.67



-- ---- DELIVERIES related ------
-- #1 What’s the average time between the order being placed and the product being delivered?

-- Assembling all the data
SELECT 
	*,
    TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date) AS Duration
FROM orders
WHERE order_status = 'delivered'
ORDER BY Duration DESC
;

-- evalutation: 
-- On average there is 12 days between order and delivery with a maximum of 209 days and a minimum of 0 days 
SELECT 
    order_status, 
    AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS Average_Duration_in_days, 
    MIN(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)),
    MAX(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date))
FROM orders
GROUP BY order_status
;

-- #2 How many orders are delivered on time vs orders delivered with a delay? 
-- 99441 orders in total
-- 96478 delivered --- 7826 are not delivered on time --> 8.1 % are delayed

-- for Tech products 1373 orders have not been delivered on time with an average of 8 days later

SELECT 
	order_status, COUNT(*), AVG(TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date))
FROM orders o
WHERE order_estimated_delivery_date < order_delivered_customer_date 
 GROUP BY order_status
;

SELECT(7826 / 96478);

-- #3 Is there any pattern for delayed orders, e.g. big products being delayed more often?

-- for Tech items we have an average delivery time of 12.65 days. and a maximum of 195 days


-- 3.6 to 4.3

SELECT 
	*,
    TIMESTAMPDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) AS Duration,
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE order_status = 'delivered'
ORDER BY Duration DESC
;


SELECT 
    order_status, 
    AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) AS Average_Duration_in_days, 
    MIN(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)),
    MAX(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date))
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
-- WHERE product_category_name IN ('informatica_acessorios', 'telefonia', 'eletronicos', 'consoles_games', 'audio', 'pcs')

-- Join with tech products? 
-- Join with high price products? 
-- Join with big products?

GROUP BY order_status
;




									  
