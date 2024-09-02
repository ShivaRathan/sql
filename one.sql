WITH SalesSummary AS (
    SELECT
        s.sale_date,
        c.region,
        c.name AS customer_name,
        SUM(s.amount) AS total_sales,
        SUM(sd.quantity) AS total_quantity,
        AVG(s.amount) AS avg_sale_amount
    FROM sales s
    JOIN customers c ON s.customer_id = c.id
    JOIN sales_details sd ON s.id = sd.sale_id
    GROUP BY s.sale_date, c.region, c.name
),
RankedCustomers AS (
    SELECT
        region,
        customer_name,
        total_sales,
        RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank
    FROM SalesSummary
),
RegionSummary AS (
    SELECT
        region,
        SUM(total_sales) AS region_total_sales,
        AVG(avg_sale_amount) AS region_avg_sale_amount
    FROM SalesSummary
    GROUP BY region
)
SELECT
    rs.region,
    rs.customer_name,
    rs.total_sales,
    rs.total_quantity,
    rs.avg_sale_amount,
    reg.region_total_sales,
    reg.region_avg_sale_amount
FROM RankedCustomers rs
JOIN RegionSummary reg ON rs.region = reg.region
WHERE rs.rank <= 5
ORDER BY rs.region, rs.rank;
