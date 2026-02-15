--understanding data ---
select  count(*) as total_orders,
        count(order_delivered_customer_date) as delivered_orders,
        count(order_estimated_delivery_date) as estimated_orders,
        count(order_approved_at) as approved_orders,
        count(order_purchase_timestamp) as purchased_orders
from orders;
--finding the percentage of delivered orders---
select  (count(order_delivered_customer_date)*100.0/count(*)) as percentage_delivered_orders
from orders;
--finding the percentage of approved orders---
select  (count(order_approved_at)*100.0/count(*)) as percentage_approved_orders
from orders;
--finding the percentage of purchased orders---
select  (count(order_purchase_timestamp)*100.0/count(*)) as percentage_purchased_orders
from orders;
--DELIVERY DELAY ANALYSIS---
select  avg(julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date)) as avg_delivery_delay_days,
        min(julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date)) as min_delivery_delay_days,
        max(julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date)) as max_delivery_delay_days
from orders
where order_delivered_customer_date is not null;    
--creating buckets for analysis of delivery delays--
SELECT
  CASE
    WHEN julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date)< -50 THEN 'Very Early'
    WHEN julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date) BETWEEN -50 AND -1 THEN 'Early'
    WHEN julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date) = 0 THEN 'On Time'
    WHEN julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date) BETWEEN 1 AND 10 THEN 'Slight Delay'
    WHEN julianday(order_delivered_customer_date)-julianday(order_estimated_delivery_date) BETWEEN 11 AND 30 THEN 'Late'
    ELSE 'Very Late'
  END AS delivery_bucket,
  COUNT(*) AS total_orders
FROM orders 
GROUP BY delivery_bucket
ORDER BY total_orders DESC;
-- calculate delivery delays in days---
WITH order_delay AS (
  SELECT
    o.order_id,
    CAST(
      julianday(o.order_delivered_customer_date) -
      julianday(o.order_estimated_delivery_date)
      AS INTEGER
    ) AS delay_days
  FROM orders o
  WHERE
    o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
  oi.seller_id,
  CASE
    WHEN od.delay_days < -50 THEN 'Very Early'
    WHEN od.delay_days BETWEEN -50 AND -1 THEN 'Early'
    WHEN od.delay_days = 0 THEN 'On Time'
    WHEN od.delay_days BETWEEN 1 AND 10 THEN 'Slight Delay'
    WHEN od.delay_days BETWEEN 11 AND 30 THEN 'Late'
    ELSE 'Very Late'
  END AS delivery_bucket,
  COUNT(*) AS total_orders
FROM order_delay od
JOIN order_items oi
  ON od.order_id = oi.order_id
GROUP BY
  oi.seller_id,
  delivery_bucket
ORDER BY seller_id,
  total_orders desc;
--finding the top 10 sellers---
select seller_id , count(*)as total_orders  from order_items
group by seller_id 
order by total_orders desc
limit 10;
--finding the bottom 10 sellers---
select seller_id , count(*)as total_orders  from order_items      
group by seller_id 
order by total_orders asc
limit 10;
---top 10 ten actual revenue generating sellers---
select seller_id , sum(price - (price*0.08)-(price*0.02)) as total_revenue from order_items
group by seller_id
order by total_revenue desc
limit 10;
--product category wise revenue---
 select product_category_name,sum(price) as revenue from order_items JOIN PRODUCTS ON order_items.product_id = PRODUCTS.product_id GROUP by product_category_name
order by revenue desc;
--actual revenue by subtracting freight value---
 select product_category_name_english,sum(price -freight_value) as actual_revenue from order_items 
 JOIN PRODUCTS ON order_items.product_id = PRODUCTS.product_id  
 join product_category_name_translation on products.product_category_name=product_category_name_translation.product_category_name
  where product_category_name_english is not null 
  GROUP by product_category_name_english
  order by actual_revenue desc;
---bad reviews count---
select * from order_reviews;
select count(*) as total_reviews from order_reviews;
select count(*) as bad_reviews from order_reviews
where review_score <=2;
select (count(*)*100.0/(select count(*) from order_reviews)) as percentage_bad_reviews from order_reviews
where review_score <=2;
--good reviews count---
select count(*) as good_reviews from order_reviews
where review_score >=4; 
select (count(*)*100.0/(select count(*) from order_reviews)) as percentage_good_reviews from order_reviews
where review_score >=4;
--neutral reviews count---
select count(*) as neutral_reviews from order_reviews 
where review_score =3;  
select (count(*)*100.0/(select count(*) from order_reviews)) as percentage_neutral_reviews from order_reviews 
where review_score =3;
--review score distribution---
select review_score, count(*) as total_reviews from order_reviews
group by review_score
order by review_score;
--average review score---
select avg(review_score) as average_review_score from order_reviews;
--average review score by product category---
 select product_category_name_english, avg(review_score) as average_review_score from order_items 
 JOIN PRODUCTS ON order_items.product_id = PRODUCTS.product_id  
 join product_category_name_translation on products.product_category_name=product_category_name_translation.product_category_name
 JOIN order_reviews ON order_items.order_id = order_reviews.order_id
  where product_category_name_english is not null 
  GROUP by product_category_name_english
  order by average_review_score desc;
--product with reviews less than 3----
select product_id, count(*) as total_reviews from order_items 
 JOIN order_reviews ON order_items.order_id = order_reviews.order_id
where review_score < 3
group by product_id
order by total_reviews desc;
--reviews by sellers--
select oi.seller_id, count(*) as total_reviews from order_items oi
 JOIN order_reviews orv ON oi.order_id = orv.order_id
group by oi.seller_id
order by total_reviews desc;
--sellers with bad reviews---
select oi.seller_id, count(*) as bad_reviews from order_items oi
 JOIN order_reviews orv ON oi.order_id = orv.order_id
where orv.review_score <=2
group by oi.seller_id
order by bad_reviews desc;
--sellers with good reviews---
select oi.seller_id, count(*) as good_reviews from order_items oi
 JOIN order_reviews orv ON oi.order_id = orv.order_id
where orv.review_score >=4
group by oi.seller_id
order by good_reviews desc; 
--late delivery vs bad reviews---
WITH ORDER_DELAY AS (SELECT ORDER_ID, 
(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)) AS delay_days
FROM ORDERS
WHERE order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL)
SELECT od.delay_days, COUNT(*) AS total_orders,
       SUM(CASE WHEN orv.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews
FROM ORDER_DELAY od
JOIN order_reviews orv ON od.order_id = orv.order_id
WHERE od.delay_days > 0 
GROUP BY od.delay_days
ORDER BY od.delay_days DESC;
--on time delivery vs good reviews---
WITH ORDER_DELAY AS (SELECT ORDER_ID,
(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)) AS delay_days
FROM ORDERS
WHERE order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL)
SELECT od.delay_days, COUNT(*) AS total_orders,
       SUM(CASE WHEN orv.review_score >= 4 THEN 1 ELSE 0 END) AS good_reviews
FROM ORDER_DELAY od
JOIN order_reviews orv ON od.order_id = orv.order_id
WHERE od.delay_days <= 0 
GROUP BY od.delay_days
ORDER BY od.delay_days DESC;
--seller performance analysis combining delivery and reviews and revenue--
create view seller_performance as
WITH ORDER_DELAY AS (SELECT ORDER_ID,
(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)) AS delay_days
FROM ORDERS
WHERE order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL)
SELECT oi.seller_id,
  CASE
    WHEN od.delay_days < -50 THEN 'Very Early'
    WHEN od.delay_days BETWEEN -50 AND -1 THEN 'Early'
    WHEN od.delay_days = 0 THEN 'On Time'
    WHEN od.delay_days BETWEEN 1 AND 10 THEN 'Slight Delay'
    WHEN od.delay_days BETWEEN 11 AND 30 THEN 'Late'
    ELSE 'Very Late'
  END AS delivery_bucket,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN orv.review_score >= 4 THEN 1 ELSE 0 END) AS good_reviews,
  SUM(CASE WHEN orv.review_score <= 2 THEN 1 ELSE 0 END) AS bad_reviews,
  sum(oi.price - freight_value) AS total_revenue
FROM ORDER_DELAY od
JOIN order_items oi ON od.order_id = oi.order_id  
JOIN order_reviews orv ON od.order_id = orv.order_id
GROUP BY oi.seller_id, delivery_bucket  
ORDER BY oi.seller_id, total_orders DESC;
--good contributing +goood_reviewed sellers---
 select *  from seller_performance 
 where good_reviews>bad_reviews
 order by total_revenue desc;
---bad contributing +bad_reviewed sellers---
 select *  from seller_performance 
 where bad_reviews>good_reviews
 order by total_revenue asc;
 --neutral contributing +neutral_reviewed sellers---
 select *  from seller_performance 
  where bad_reviews=good_reviews
  order by total_revenue;
--good review but low revenue sellers---
 select *  from seller_performance 
 where good_reviews>bad_reviews
 order by total_revenue asc
 limit 10;
--bad review but high revenue sellers---
 select *  from seller_performance 
 where bad_reviews>good_reviews 
  order by total_revenue desc
  limit 10;
  --customer analysis--
 create view customer_analysis as select customer_id, count(*) as total_orders, sum(price - freight_value) as total_revenue from order_items oi
  JOIN orders o ON oi.order_id = o.order_id
  GROUP by customer_id
  order by total_revenue desc;
--repeating customers---
 select * from customer_analysis
 where total_orders >1
 order by total_revenue desc;
--one time customers---
 select * from customer_analysis
 where total_orders =1
  order by total_revenue desc;
  --customer loyalty analysis--
select (count(*)*100.0/(select count(*) from customer_analysis)) as percentage_repeating_customers from customer_analysis
where total_orders >1;
select (count(*)*100.0/(select count(*) from customer_analysis)) as percentage_one_time_customers from customer_analysis
where total_orders =1;
SELECT 
  CASE
    WHEN total_orders = 1 THEN 'One-time'
    WHEN total_orders BETWEEN 2 AND 3 THEN 'Low repeat'
    WHEN total_orders BETWEEN 4 AND 7 THEN 'Medium loyal'
    ELSE 'High loyal'
  END AS customer_type,
  COUNT(*)*100.0/(SELECT COUNT(*) FROM customer_analysis) AS percentage
FROM customer_analysis
GROUP BY customer_type;
--joining customer analysis ,orders  and order_reviews for deeper insights--
create view customer_insight as
SELECT ca.customer_id,
       ca.total_orders,
       ca.total_revenue,
       AVG(orv.review_score) AS average_review_score
FROM customer_analysis ca
JOIN orders o ON ca.customer_id = o.customer_id 
JOIN order_reviews orv ON o.order_id = orv.order_id
GROUP BY ca.customer_id, ca.total_orders, ca.total_revenue;
--joining feature order delay with customer insights--
create view customer_full_insight as
WITH ORDER_DELAY AS (SELECT ORDER_ID, (julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)) AS delay_days
FROM ORDERS
WHERE order_delivered_customer_date IS NOT NULL 
AND order_estimated_delivery_date IS NOT NULL)
SELECT ci.customer_id,
       ci.total_orders,
       ci.total_revenue,
       ci.average_review_score,
       ci.good_reviews,
       ci.bad_reviews,
       AVG(od.delay_days) AS average_delivery_delay_days,
       o.order_purchase_timestamp
FROM customer_insights ci
JOIN orders o ON ci.customer_id = o.customer_id
JOIN ORDER_DELAY od ON o.order_id = od.order_id
GROUP BY ci.customer_id, ci.total_orders, ci.total_revenue, ci.average_review_score, ci.good_reviews, ci.bad_reviews;
select *from customer_insight;
select *from customer_full_insight;
create view dashboard_columns_view as 
select * FROM customer_full_insight
join orders o on customer_full_insight.customer_id=o.customer_id
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id=p.product_id
join product_category_name_translation pct on p.product_category_name=pct.product_category_name
join order_reviews orv on o.order_id=orv.order_id
JOIN seller_performance sp on oi.seller_id=sp.seller_id;
select * from dashboard_columns_view;