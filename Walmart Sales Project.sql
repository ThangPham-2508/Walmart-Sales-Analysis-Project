--Some basic EDA (Exploratory Data Analysis) 
SELECT * FROM [Walmart Sales]

--Total records
SELECT COUNT(*) FROM [Walmart Sales]

-- Count payment methods and number of transactions by payment method
SELECT payment_method, COUNT(*) AS no_of_transactions
FROM [Walmart Sales]
GROUP BY payment_method
ORDER BY no_of_transactions DESC

-- Count distinct branches
SELECT COUNT(DISTINCT Branch)
FROM [Walmart Sales]

-- Find the maximum/minimum quantity sold
SELECT MAX(quantity) AS max_quantity_sold
FROM [Walmart Sales]

SELECT MIN(quantity) AS max_quantity_sold
FROM [Walmart Sales]

--SOLVE THE BUSINESS PROBLEMS
--Q1: What are the different payment methods, and how many transactions and
--items were sold (quantity sold) with each method?
SELECT payment_method, COUNT(*) AS No_of_transactions, SUM(quantity) AS No_of_item
FROM [Walmart Sales]
GROUP BY payment_method

--Q2: Which category received the highest average rating in each branch?
-- Display the branch, category, and avg rating
SELECT Branch, category, Avg_Rating
FROM 
	(SELECT Branch, category, AVG(rating) AS Avg_Rating, 
	RANK() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS Ranking
	FROM [Walmart Sales]
	GROUP BY Branch, category) AS temp_table 
WHERE Ranking = 1

--Q3: What is the busiest day of the week for each branch based on transaction volume?
SELECT Branch, Day_of_the_week, No_of_transactions
FROM
	(SELECT Branch, DATENAME(WEEKDAY, date) AS Day_of_the_week, COUNT(*) AS No_of_transactions,
	RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS Ranking
	FROM [Walmart Sales]
	GROUP BY Branch, DATENAME(WEEKDAY, date)) AS temp_table
WHERE Ranking = 1

--Q4:  How many items were sold through each payment method?
SELECT payment_method, SUM(quantity) AS No_of_items
FROM [Walmart Sales]
GROUP BY payment_method

--Q5: What are the average, minimum, and maximum ratings for each category in each city
SELECT City, category,
	AVG(rating) AS AVG_rating,
	MIN(rating) AS Min_rating,
	MAX(rating) AS Max_rating
FROM [Walmart Sales]
GROUP BY City, category

--Q6: What is the total profit for each category, ranked from highest to lowest?SELECT category, SUM(Total_Price * profit_margin) AS Total_Profit
FROM [Walmart Sales]
GROUP BY category
ORDER BY Total_Profit DESC

--Q7: What is the most frequently used payment method in each branch?
WITH CTE AS (
	SELECT Branch, payment_method, COUNT(*) AS Using_times,
	RANK() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS Ranking
	FROM [Walmart Sales]
	GROUP BY Branch, payment_method
			)
SELECT Branch, payment_method AS Most_frequently_used_payment_method, Using_times 
FROM CTE
WHERE Ranking = 1

--Q8:  How many transactions occur in each shift (Morning, Afternoon, Evening)
--across branches?
SELECT Branch, Shift, COUNT(*) AS No_of_transactions
FROM (
	SELECT Branch, time, 
	CASE 
		WHEN DATEPART(HOUR, time) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS Shift
	FROM [Walmart Sales]
	) AS temp_table
GROUP BY Branch, Shift
ORDER BY Branch

--Q9: Which 5 branches experienced the largest decrease in revenue compared to
--the previous year? (2022 to 2023)
WITH Revenue_2022 AS (
	SELECT Branch, SUM(Total_Price) AS Revenue_2022
	FROM [Walmart Sales]
	WHERE YEAR(date) = 2022
	GROUP BY Branch
	),
	Revenue_2023 AS (
	SELECT Branch, SUM(Total_Price) AS Revenue_2023
	FROM [Walmart Sales]
	WHERE YEAR(date) = 2023
	GROUP BY Branch
	)
SELECT TOP 5 R2022.Branch, Revenue_2022, Revenue_2023,
ROUND(((Revenue_2022 - Revenue_2023)/Revenue_2022)*100, 2) AS Revenue_Decrease_Ratio
FROM Revenue_2022 AS R2022 
INNER JOIN Revenue_2023 AS R2023 ON R2022.Branch = R2023.Branch
ORDER BY Revenue_Decrease_Ratio DESC










