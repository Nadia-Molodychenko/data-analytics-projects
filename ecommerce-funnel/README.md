# E-Commerce Funnel Analysis (BigQuery + Tableau)

**Tools:** BigQuery (SQL), Tableau
**Data:** bigquery-public-data.ga4_obfuscated_sample_ecommerce (Google Merchandise Store, Nov 2020 – Jan 2021)

An interactive funnel dashboard that tracks users through the full purchase journey and shows where the store loses them.

[View interactive dashboard on Tableau Public](https://public.tableau.com/views/EcommerceFunnelDashboard_17848398317130/EcommerceFunnelDashboard)

## What it answers

At which step of the purchase funnel does the store lose the most users, how conversion differs by traffic channel and device, and where to focus to improve conversion.

## The funnel

session_start → view_item → add_to_cart → begin_checkout → add_shipping_info → add_payment_info → purchase

## SQL (the hard part — raw GA4 event data)

GA4 data is nested and event-based, so the query does real preparation work:
- extracts values from nested event_params using UNNEST
- builds a unique session key (user_pseudo_id + ga_session_id) with CONCAT
- captures each session's landing page with REGEXP_EXTRACT, and its geo, device, and marketing channel at the moment of session_start
- reads across daily wildcard tables (events_*) with _TABLE_SUFFIX for the Nov 2020 – Jan 2021 window
- joins session attributes to the seven funnel events with a CTE + LEFT JOIN

The output is a flat, session-level event table that Tableau turns into a funnel.

## Dashboard

Built in Tableau with interactive filters (date, device, language, OS, source, medium, campaign):
- the conversion funnel with step-by-step conversion rates
- conversion rate by traffic medium and by device
- sessions and CR to purchase over time
- top landing pages by sessions and conversion

## Key finding

**The biggest drop happens at the very first step.** Of all sessions, only 21% reach view_item — meaning 79% of users leave without looking at a single product. The largest loss is at the entrance to the funnel, not at checkout.

By contrast, users who reach checkout mostly convert: begin_checkout → add_shipping_info holds steady, and payment converts well. Overall session-to-purchase conversion is 1.34%.

## Recommendation

Since most users are lost before they ever view a product, effort should go to the top of the funnel, not to checkout:
- Review traffic quality by channel (medium) — some sources convert far worse than others; shift budget toward channels that convert.
- Check the mobile experience — device breakdown shows where the early drop-off concentrates.
- Don't prioritise checkout changes yet — users who reach checkout already convert, so that's not where the money is lost.

In one line: the store loses most customers before they even view a product, so the priority is traffic quality and the landing experience, not the checkout flow.

## Files

- funnel_query.sql — the full BigQuery SQL (GA4 event extraction, session key, funnel events)
- dashboard screenshot in this repo
- [Interactive dashboard on Tableau Public](https://public.tableau.com/views/EcommerceFunnelDashboard_17848398317130/EcommerceFunnelDashboard)
