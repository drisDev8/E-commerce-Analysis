DESCRIBE e_commerce_company;
DESCRIBE products;
DESCRIBE order_details;
DESCRIBE customers;
DESCRIBE orders;

-- Objective 1: Identify the top 3 cities with the highest number of customers.
SELECT location, COUNT(customer_id) number_of_customers
FROM Customers
GROUP BY location
ORDER BY COUNT(customer_id) DESC 
LIMIT 3;

-- Objective 2: Determine the distribution of customers by the number of orders placed.
WITH customer_order_count AS (
    SELECT customer_id, COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT order_count AS NumberOfOrders, COUNT(*) AS CustomerCount
FROM customer_order_count
GROUP BY order_count
ORDER BY order_count;

-- Objective 3: Identify products where the average purchase quantity per order is 2 but with a high total revenue.
SELECT product_id, AVG(quantity) AvgQuantity, SUM(quantity * price_per_unit) TotalRevenue
FROM order_details
GROUP BY product_id
HAVING AVG(quantity) = 2
ORDER BY TotalRevenue DESC;

-- Objective 4: For each product category, calculate the unique number of customers purchasing from it. 
SELECT p.category, COUNT(DISTINCT o.customer_id) unique_customers
FROM order_details od 
JOIN Products p ON p.product_id = od.product_id
JOIN Orders o ON o.order_id = od.order_id
GROUP BY p.category
ORDER BY unique_customers DESC;

-- Objective 5: Analyze the month-on-month percentage change in total sales.
WITH Monthlysales AS(
SELECT DATE_FORMAT(order_date,'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month
)
SELECT Month, TotalSales,
ROUND(((TotalSales - LAG(TotalSales,1) OVER (ORDER BY Month)) / LAG(TotalSales,1) OVER (ORDER BY Month)) * 100,
2) AS PercentChange
FROM Monthlysales
ORDER by Month;

-- Objective 6: Examine how the average order value changes month-on-month.
WITH MonthlyValue AS( 
SELECT DATE_FORMAT(order_date, '%Y-%m') AS Month, ROUND(AVG(total_amount),2) AS AvgOrderValue
FROM orders
GROUP BY Month
)
SELECT Month, AvgOrderValue, ROUND((AvgOrderValue - LAG(AvgOrderValue,1)OVER (ORDER BY Month)),2) AS ChangeInValue
FROM MonthlyValue
ORDER BY ChangeInValue DESC;

-- Objective 7: Based on sales data, identify products with the fastest turnover rates.
SELECT product_id, COUNT(*) SalesFrequency
FROM Order_details
GROUP BY product_id
ORDER BY SalesFrequency DESC 
LIMIT 5;

-- Objective 8: List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
SELECT p.product_id, p.name AS Name,
  COUNT(DISTINCT c.customer_id) AS UniqueCustomerCount
FROM Products AS p
JOIN order_details AS od ON od.product_id = p.product_id
JOIN Orders AS o ON od.order_id = o.order_id
JOIN Customers AS c ON c.customer_id = o.customer_id
GROUP BY p.product_id, p.name
HAVING COUNT(DISTINCT c.customer_id) < (
    SELECT COUNT(customer_id) * 0.4
    FROM Customers
  );
  
-- Objective 9: Evaluate the month-on-month growth rate in the customer base.
SELECT DATE_FORMAT(min_order_date, '%Y-%m') AS FirstPurchaseMonth,
  COUNT(customer_id) AS TotalNewCustomers
FROM (
  SELECT customer_id, MIN(order_date) AS min_order_date
  FROM orders
  GROUP BY customer_id
) AS FirstOrdersByCustomer
GROUP BY  FirstPurchaseMonth
ORDER BY FirstPurchaseMonth ASC;

-- Objective 10: Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.
SELECT DATE_FORMAT(order_date,'%Y-%m') AS Month, SUM(total_amount) AS TotalSales
FROM orders
GROUP BY Month
ORDER BY TotalSales DESC 
LIMIT 3;
