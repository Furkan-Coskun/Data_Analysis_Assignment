WITH T1 AS
(
SELECT DISTINCT B.product_id, B.discount,
SUM (b.quantity) OVER(PARTITION BY product_id,discount) sum_quantity
FROM sale.orders A, sale.order_item B
WHERE A.order_id = B.order_id 
)
SELECT DISTINCT product_id,
CASE
    WHEN LAST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) > FIRST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) 
	AND FIRST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) + LAST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) /2 > AVG(sum_quantity) OVER(PARTITION BY product_id)
	THEN 'positive'
	WHEN LAST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) = FIRST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) 
	AND FIRST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) + LAST_VALUE (sum_quantity) OVER(PARTITION BY product_id ORDER BY product_id) /2 = AVG(sum_quantity) OVER(PARTITION BY product_id)
	THEN 'neutral'
    ELSE 'negative'
END AS 'Dscnt_impact'
FROM T1	
ORDER BY product_id
