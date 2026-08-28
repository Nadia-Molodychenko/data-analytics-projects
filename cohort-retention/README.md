# Cohort Analysis — User Retention (SQL + Google Sheets)

**Tools:** SQL (PostgreSQL), Google Sheets
**Goal:** Measure user retention with cohort analysis, and compare retention
between promo-acquired and organic users.

## What it does

Raw signup and event data came with messy, inconsistent date formats (different
separators `. / -`, two- or four-digit years, leading spaces, time components).
The task was to clean the dates, build monthly cohorts, calculate each user's
tenure (month offset), and measure retention rate — then compare acquisition
quality of promo vs organic users.

## SQL (the hard part — date cleaning)

The dates were stored as free text in mixed formats. I cleaned them in stages:
- trimmed spaces and dropped the time component
- replaced all separators (`.` `/`) with a single `-` using regexp_replace
- handled two-digit vs four-digit years (added `20` prefix where the year was 2 digits)
- converted the normalized string to a real timestamp with to_timestamp

Then, using CTEs, I:
- joined users and events on user_id
- filtered out missing dates, null event types, and test events
- derived cohort_month (signup month) and month_offset (months since signup)
- aggregated distinct users per promo_signup_flag + cohort_month + month_offset,
  limited to the Jan–Jun 2025 observation window

The output is a tidy table: promo flag, cohort month, month offset, users_total.

## Google Sheets (cohort tables)

From the SQL output I built in Sheets:
- a **user-count cohort table** (rows = cohort month, columns = month offset),
  with gradient conditional formatting
- a **retention-rate cohort table** (each cell as % of the cohort's month-0 size,
  100% at offset 0)
- a **slicer** on promo_signup_flag so both tables update for promo / organic / all
- a short written conclusion comparing the two groups

## What I found

Retention declines month over month for all cohorts (from 100% at signup down to
~40% by month 5). Comparing promo vs organic users shows a difference in
acquisition quality — the slicer makes it easy to switch between the two and see
how each group's retention curve behaves.

## Files

- cohort_analysis.sql — the full SQL script (date cleaning, cohorts, retention)
- [View cohort tables in Google Sheets](https://docs.google.com/spreadsheets/d/19Gp3JxAT1G8VjbNMVa4-xqt_d3m1deZW8b-PGGiZHLE/edit?usp=sharing)
