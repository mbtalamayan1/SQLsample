
-- 1
-- What are the daily sales from July 1, 2019 to August 30, 2019?
-- Show date and daily sales amount. Order by date, oldest to recent.
SELECT sales, date 
  FROM sales 
  WHERE date BETWEEN '2019/07/01' AND '2019/08/30'; 

-- 2
-- What are the monthly sales from July 2019 to August 2019?
-- Show month and total amount for the month.Order by month, oldest to recent.
-- Source for use of SUBSTRING function: https://w3resource.com/PostgreSQL/substring-function.php
SELECT SUBSTRING(date,6,2) AS month, SUM(sales) 
  FROM sales 
  GROUP by month 
  ORDER BY month ASC;

-- 3
-- How much is the overall sales for each city for the month of August 2019?
-- Show city name and overall sales for the month. Order by overall sales,
-- highest to lowest.
-- Source for use of SUBSTRING function: https://w3resource.com/PostgreSQL/substring-function.php
SELECT city, sum(sales) AS total_sales 
  FROM sales 
  JOIN customers ON customers.customer_id=sales.customer_id 
  WHERE SUBSTRING(sales.date,6,2)='08'
  GROUP BY city 
  ORDER BY total_sales DESC;

-- 4
-- What are the top 10 products in terms of total sales (i.e. the products that
-- generated the most revenue)?
-- Show product name and total sales for each product. Order by total sales,
-- highest to lowest. Note that the transaction amount is already the total
-- spent by the customer for each transaction (i.e. it is not the amount spent
-- per unit).
SELECT name, sum(sales) AS total_sales 
  FROM sales 
  JOIN products ON products.product_id=sales.product_id 
  GROUP BY name 
  ORDER BY total_sales DESC LIMIT 10; 

-- 5
-- Who are our 10 customers who bought the most number of products overall?
-- Show the customer's first name, last name and total number of products bought
-- by the customer. Assume that it is possible for 2 or more customers to have
-- the same first + last name, so make sure that your query is able to
-- distinguish those customers apart.
-- Order by number of products bought, highest to lowest. And then order by
-- customer's last name in ascending order for those customers who have
-- the same number of total products bought.
SELECT first_name, last_name, sum(quantity) AS total_quantity 
  FROM sales 
  JOIN customers ON customers.customer_id=sales.customer_id 
  GROUP BY sales.customer_id, first_name, last_name 
  ORDER BY total_quantity DESC LIMIT 10;

-- 6
-- For every city, what are our top 10 products in terms of overall sales?
-- Show the name of the city, the name of the product, and the overall sales for
-- the product. This should all be in one query.
-- Order the cities in ascending order alphabetically. For each city, order the
-- products by overall sales of each product, from highest to lowest.
WITH by_city 
  AS (SELECT city, product_id, 
      sum(sales) AS total_sales 
      from customers 
      JOIN sales ON customers.customer_id=sales.customer_id 
      group by city, product_id), 
      by_name AS 
      (SELECT city, name AS product_name, total_sales 
        FROM by_city JOIN products ON by_city.product_id=products.product_id), 
      TOP_TEN AS (SELECT *, Row_Number() over (partition by city order by total_sales DESC) AS RowNo FROM by_name) 
      SELECT city, product_name, total_sales 
      FROM TOP_TEN 
      WHERE RowNo <=10;

-- 7
-- What is our month-over-month growth between July 2019 and August 2019?
-- Source for use of LAG function: https://www.postgresqltutorial.com/postgresql-lag-function/
SELECT month, sum(sales) AS current_sale, lag(sum(sales),1) over (order by month) as previous_month, 
      round ((100*(sum(sales)-lag(sum(sales),1) over (order by month))/sum(sales)),2)|| '%' AS growth
      from (SELECT SUBSTRING(date,6,2) AS month,sum(sales) as sales from sales group by 1) sales 
      group by 1 
      order by 1;
