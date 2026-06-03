SHOW DATABASES;
SHOW TABLES FROM customer_behaviour;
USE customer_behaviour;
#What is the total revenue generate by male vs female 
Select gender, sum(purchase_amount) as revenue 
from customer_table
group by gender;

#--Q2.Which customers used a discount but still spent more than the average purchase amount? 
Select customer_id,purchase_amount
from customer_table
where discount_applied= 'yes' and purchase_amount >= (select avg(purchase_amount) from customer_table);

#Q3. Which are the top 5 products with the highest average review rating?
SELECT item_purchased,
       ROUND(AVG(CAST(review_rating AS DECIMAL(3,2))), 2) AS avg_product_rating
FROM customer_table
GROUP BY item_purchased
ORDER BY avg_product_rating DESC
LIMIT 5;
 
 
 
#-Q4. Compare the average Purchase Amounts between Standard and Express Shipping. 
 Select shipping_type, avg(purchase_amount)
 from customer_table
 where shipping_type in ('Standard','Express')
 group by shipping_type;
 
 #-Q5. Do subscribed customers spend more? Compare average spend and total revenue 
#--between subscribers and non-subscribers.
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_table
GROUP BY subscription_status
ORDER BY total_revenue DESC, avg_spend DESC;

#--Q6. Which 5 products have the highest percentage of purchases with discounts applied?
SELECT item_purchased,
       COUNT(*) AS total_purchases,
       SUM(CASE 
              WHEN discount_applied = 'Yes' THEN 1 
              ELSE 0 
           END) AS discounted_purchases,
       ROUND(
           100.0 * SUM(CASE 
                          WHEN discount_applied = 'Yes' THEN 1 
                          ELSE 0 
                       END) / COUNT(*),
           2
       ) AS discount_percentage
FROM customer_table
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;


#-Q7. Segment customers into New, Returning, and Loyal based on their total 
-- number of previous purchases, and show the count of each segment. 
SELECT 
    CASE
        WHEN previous_purchases = 0 THEN 'New'
        WHEN previous_purchases BETWEEN 1 AND 5 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_table
GROUP BY customer_segment;
#--Q8. What are the top 3 most purchased products within each category? 
SELECT category,
       item_purchased,
       purchase_count
FROM (
    SELECT category,
           item_purchased,
           COUNT(*) AS purchase_count,
           ROW_NUMBER() OVER (
               PARTITION BY category
               ORDER BY COUNT(*) DESC
           ) AS rn
    FROM customer_table
    GROUP BY category, item_purchased
) ranked_products
WHERE rn <= 3
ORDER BY category, purchase_count DESC;
#--Q9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT
    CASE
        WHEN previous_purchases > 5 THEN 'Repeat Buyer'
        ELSE 'Non-Repeat Buyer'
    END AS customer_type,
    subscription_status,
    COUNT(*) AS customer_count
FROM customer_table
GROUP BY customer_type, subscription_status
ORDER BY customer_type, subscription_status;

#--Q10. What is the revenue contribution of each age group? 
SELECT age_group,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer_table
GROUP BY age_group
ORDER BY total_revenue DESC;
