# TheLook E-Commerce — Business Overview Dashboard

**Tools:** BigQuery (SQL) and Tableau
**Data:** bigquery-public-data.thelook_ecommerce (public, synthetic)

An interactive dashboard that shows how the store earns, how it grows, and how much revenue is tied up in cancelled or returned orders.

[View interactive dashboard on Tableau Public](https://public.tableau.com/views/TheLookE-Commerce-BusinessOverview/TheLookE-Commerce-BusinessOverview)

## What it answers

How much do we earn and are we growing, how much revenue is at risk from cancellations and returns, where the revenue comes from (categories and countries), and whether the loss is concentrated anywhere.

## Data

I built one wide table in BigQuery by joining four tables: order_items (price, status, date), products (category), and users (country). The grain is one row per order item. A field called revenue_type marks each item as Healthy (not cancelled or returned) or At Risk (cancelled or returned).

## The main numbers

Healthy Revenue is $8.07M — revenue from orders that were not cancelled or returned. Revenue at Risk is $2.69M — money in cancelled and returned orders. Together they make the Total Order Value of $10.76M ($8.07M + $2.69M = $10.76M). Completed Orders is 93,808. AOV (average order value) is $86.

Revenue at Risk is 33.3% of Healthy Revenue ($2.69M / $8.07M). I use "Healthy Revenue" instead of "Total Revenue" so it isn't misleading — the real total is $10.76M, not $8.07M.

## What "Healthy Revenue" includes

Healthy Revenue is everything that is not cancelled or returned. It is made up of three order statuses: Complete $2.72M (delivered, money confirmed), Shipped $3.20M (in transit), and Processing $2.16M (not yet shipped). So Healthy Revenue mixes delivered sales with orders still in progress. This is intentional for a "healthy vs at-risk" view, but if a finance team needed strict cash, it could be split into Completed Revenue ($2.72M) and Pipeline Revenue ($5.36M, Shipped + Processing).

## AOV — average order value, not item price

The table grain is one row per item, so this distinction matters. AOV is SUM(sale_price) / COUNT(DISTINCT order_id) — total revenue divided by the number of orders, not the number of items. Orders contain 1.45 items on average, so AOV is $86 (per order), while the average item price is about $59. Using distinct orders in the denominator is what makes this a true AOV.

## Decisions I made on purpose

I call it "Revenue at Risk", not "lost revenue", because cancelled money was never earned and returns involve refunds — "lost" would be too strong.

I checked the order status for double-counting. Each item has only one final status, and the statuses are final states (not steps the same item passes through), so adding revenue by status is safe.

I built AOV so it doesn't depend on filters — the "Healthy only" condition is inside the formula. The number came out the same as the filtered version, which proves orders are either fully healthy or fully at risk.

I trimmed the trend line to end on a full quarter. In this synthetic dataset the data runs into 2026, and Q1 2026 (Jan–Mar) is a fully closed quarter, so it is the last point shown; the incomplete Q2 was excluded so it doesn't create a false spike or drop.

I did not show year-over-year growth, because the last period is incomplete and the data is synthetic, so growth percentages could be misleading.

I replaced the country map with a Top-10 bar chart so the exact difference between markets (China vs US) is readable, not just approximate.

## Data quality checks

I checked for duplicate order items, null status, null price, the distribution of statuses, the Healthy vs At Risk split, and reconciled the revenue (Healthy + At Risk = Total). I also found and cleaned duplicate country names (Spain / España).

## What I found

The business is growing steadily from 2019 to 2025. About $2.69M of revenue is at risk (33.3% of Healthy Revenue), roughly $1.63M cancelled and $1.06M returned. Most of the money comes from a few categories (Outerwear, Jeans, Sweaters) and a few countries (China, US, Brazil).

The loss is not concentrated. Return and cancellation rates were broadly consistent across categories, countries, and price bands, with no real outlier. So the problem is system-wide, not tied to one product or market. Finding no outlier is itself a result.

## Recommendation

No clear category, country, or price outlier was found. The dataset has no reason-for-return field, so the root cause can't be determined from this data.

The first step would be to start recording a reason for every cancellation and return. That would let future analysis separate operational, product, delivery, and customer-driven causes.

Two follow-up analyses I'd run next, even without a reason field:
- Time-to-cancel: the gap between order time and cancellation. Cancellations within minutes point to checkout/payment problems; cancellations after days point to slow fulfilment.
- Repeat returners: whether a small group of users drives most returns (possible fraud or sizing/fit issues).

Retention effort should stay focused on the biggest markets (China, US).

## Limitations

The data is synthetic and very evenly spread, which is why no category or country stands out — this project shows the method, not a real-world insight. There is no cost data, so profit and margin can't be calculated. And there are no return reasons, so the root cause of returns can't be found.

## Files

- thelook_queries.sql — all SQL queries
- dashboard screenshot in this repo
- [Interactive dashboard on Tableau Public](https://public.tableau.com/views/TheLookE-Commerce-BusinessOverview/TheLookE-Commerce-BusinessOverview)
