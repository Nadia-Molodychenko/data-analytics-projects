# Stack Overflow Developer Survey — Analysis (Python / Pandas)

**Tools:** Python, Pandas, Jupyter Notebook
**Data:** Stack Overflow Annual Developer Survey (public results, 49,191 respondents)

Analysis of the global Stack Overflow Developer Survey using Pandas: descriptive statistics, filtering, grouping, and working with multi-value and missing data.

## What it does

Working with a large real-world survey dataset (49,191 respondents, hundreds of columns), I answered a set of analytical questions:

- **Dataset size** — total number of respondents (unique ResponseId): 49,191.
- **Response completeness** — how many respondents answered every survey question. I used set intersection between the schema's question list (qname) and the data columns to keep only real questions, then counted rows with no missing answers.
- **Experience** — central tendency of work experience (WorkExp): mean, median, mode.
- **Remote work** — number of respondents working remotely (RemoteWork).
- **Python popularity** — share of respondents who code in Python, handling the multi-value LanguageHaveWorkedWith field with str.contains.
- **Learning paths** — respondents who learned via online courses (LearnCode).
- **Compensation by country** — for Python developers, mean and median yearly compensation (ConvertedCompYearly) grouped by country, missing values dropped.
- **Education of top earners** — education level (EdLevel) of the 5 highest-paid respondents.

## Pandas techniques used

Loading a large CSV, inspecting the schema, nunique for counting, set intersection for column filtering, dropna for completeness and missing-value handling, descriptive statistics (mean / median / mode), boolean filtering, str.contains for multi-value text fields, groupby + agg for mean/median by group, and sort_values + head for top-N selection.

## Key findings

- 49,191 developers took part in the survey.
- **No respondent answered every single question** — completeness across all schema questions is 0, which is typical for long optional surveys.
- Typical work experience is **10 years (median)**, mean 13 — the gap shows a right-skewed distribution (a minority of very experienced developers pulls the mean up).
- **37.5%** of respondents code in Python.
- 10,931 respondents work fully remotely; 10,973 learned to code via online courses.
- Python developers' compensation varies widely by country (mean and median per country in the notebook).

## Files

- stackoverflow_survey.ipynb — the full notebook with code and outputs
