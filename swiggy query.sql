USE mysub;
-- 1) Find customer who have never orderd
/*This is a simple question in that you have to write a sub-query that gives the users id who ordered and then use the NOT IN
 operator and find the user_id who hasn't ordered anything on this platform*/
 
SELECT name 
FROM users2 
WHERE user_id NOT IN (SELECT user_id FROM orders1);

-- 2) AVG price of dish
/*In this question, you have to join the food and menu table cause it will give you dish name and their price
, and the user aggregator function AVG and group by on dish name*/
SELECT f_name as dish,ROUND(avg(price),2) as avg_price
FROM food f
JOIN menu m ON f.f_id=m.f_id
GROUP BY f_name ORDER BY avg_price DESC;

-- 3)find top restaurents in term of number of orders for a given month
 /*for this problem, firstly you have to filter the orders in a given month like July(7)
 with the help of the extract function in mysql and then make a join on the restaurant and orders column
 then aggregate them on the name of the restaurant and given month lastly limit the query for the first record you will get your answer*/
 
SELECT *,MONTHNAME(date) AS 'month'    # to extract month 
FROM orders1 
WHERE MONTHNAME(date) LIKE 'July';

SELECT r_name,COUNT(order_id) AS 'Month'
FROM orders1 o
JOIN restaurants r
ON r.r_id = o.r_id
WHERE MONTHNAME(date) LIKE 'July'
GROUP BY r_name
ORDER BY COUNT(order_id) DESC
LIMIT 1;
-- 4. restaurants with monthly sales greater than x for

SELECT r.r_name,SUM(amount) AS 'Revenue'
FROM orders1 o 
JOIN restaurants r
ON o.r_id  = r.r_id
WHERE MONTHNAME(date) LIKE 'June'
GROUP BY r_name
HAVING SUM(amount) > 500;

-- 5. Show all orders with order details for a particular customer in a particular date range 
# pertculer customerne kitne order kiye 
SELECT * FROM orders1 WHERE user_id = (SELECT user_id FROM users2 WHERE name LIKE 'Ankit');
# Perticular cust order in given timeline
SELECT * FROM orders1 
WHERE user_id = (SELECT user_id FROM users2 WHERE name LIKE 'Ankit')
AND (date >='2022-06-10' AND date <= '2022-07-10');
# Full que query
/* First join the table user, restaurants, order details, and food so you will get the all
 desired order details and then put the where condition like particular user as well as a range of date*/
 
SELECT o.order_id,r.r_name,f.f_name
FROM orders1 o
JOIN restaurants r
ON r.r_id = o.r_id
JOIN order_details2 od
ON o.order_id = od.order_id
JOIN food f
ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id FROM users2 WHERE name LIKE 'Ankit')
AND (date >='2022-06-10' AND date <= '2022-07-10');

# 6. Find restaurants with max repeated customers 
 /*With help of the order column filter the customer who make two or more order from the same restaurant using the COUNT
 function and join that on restaurant and group by on restaurant name using having clause*/
 
SELECT r_name AS restaurant,name,COUNT(order_id) AS orders1
FROM restaurants r
JOIN orders1 o ON r.r_id=o.r_id
JOIN users2 u ON o.user_id=u.user_id
GROUP BY r_name,name
HAVING COUNT(order_id) >1
ORDER BY COUNT(order_id) DESC;
#OR
SELECT r.r_name,COUNT(*) AS 'loyal_customer'
FROM (SELECT r_id,user_id,COUNT(order_id) AS 'Visits' FROM orders1 GROUP BY r_id,user_id HAVING visits>1) t
JOIN restaurants r ON r.r_id=t.r_id
GROUP BY r_name
ORDER BY COUNT(*) DESC
LIMIT 1;

# 7. Month over month revenue growth of swiggy 
/* In this query, the tricky part is finding the percentage growth and LAG function.Formula = ((revenue — privious_month_revenue)/c) * 100
 with the help of lag function we can create a column for privious_month_revenue*/
SELECT month ,((revenue - prev)/prev)*100 AS MOM_revenue FROM(
WITH sales AS
(
      SELECT MONTHNAME(date) AS 'month',SUM(amount) AS 'revenue'
      FROM orders1
      GROUP BY MONTHNAME(date)
      ORDER BY MONTHNAME(date)
)
SELECT month ,revenue,LAG(revenue,1) OVER(ORDER BY revenue) AS prev FROM sales )t;

# 8. Customer - favorite food 
/*Simple approach to solving the question is to find the food which has a maximum number of orders.
 Use the COUNT function on the order table and then join on the food table */

SELECT f_name,COUNT(*) AS 'frequency'
FROM orders1 o
JOIN order_details2 od
ON o.order_id=od.order_id
JOIN food f 
ON od.f_id=f.f_id
GROUP BY f_name
ORDER BY COUNT(*) DESC
