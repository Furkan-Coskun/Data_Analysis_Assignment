SELECT DISTINCT product_id, discount
FROM sale.order_item
ORDER BY 
	1,2


SELECT COUNT(DISTINCT discount)
FROM sale.order_item


SELECT *
FROM sale.order_item


WITH T1 AS
(
SELECT product_id,discount, SUM(quantity) TOTAL_QUANTÝTY
FROM sale.order_item
GROUP BY 
	product_id, discount
), T2 AS
(
SELECT product_id, discount, TOTAL_QUANTÝTY,
		FIRST_VALUE(TOTAL_QUANTÝTY) OVER (PARTITION BY product_id ORDER BY discount) AS first_disc_quantity,
		LAST_VALUE(TOTAL_QUANTÝTY) OVER (PARTITION BY product_id ORDER BY discount ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_disc_quantity
FROM T1
),  T3 AS
(
SELECT product_id, 1.0 * (last_disc_quantity - first_disc_quantity) /first_disc_quantity increase_rate
FROM T2
)
SELECT DISTINCT product_id,
		CASE WHEN increase_rate BETWEEN -0.10 AND 0.10 THEN 'NEUTRAL'
			WHEN increase_rate > 0.10 THEN 'POSITIVE'
			ELSE 'NEGATIVE'
		END AS discount_effect
FROM T3



