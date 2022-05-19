  --Query 1: Total Confirmed Cases
  --"What was the total count of confirmed cases on 2020-05-10?" 
  --Result: 11156073

SELECT
  SUM(cumulative_confirmed) AS total_cases_worldwide
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date = '2020-05-10'

--------------------------------------------------------------------------------------------------------------------

  --Query 2: Worst Affected Areas
  --"How many states in the United States of America had more than thousand deaths on 2020-05-10?"
  --Result: 21

WITH
  deaths_by_states AS (
  SELECT
    subregion1_name AS state,
    SUM(cumulative_deceased) AS death_count
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="United States of America"
    AND date='2020-05-10'
    AND subregion1_name IS NOT NULL
  GROUP BY
    subregion1_name )
SELECT
  COUNT(*) AS count_of_states
FROM
  deaths_by_states
WHERE
  death_count > 1000

--------------------------------------------------------------------------------------------------------------------

  --Query 3: Identifying Hotspots
  --"List all the states in the United States of America that had more than 10k confirmed cases on 2020-05-10 ?"

SELECT
  *
FROM (
  SELECT
    subregion1_name AS state,
    SUM(cumulative_confirmed) AS total_confirmed_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_code="US"
    AND date='2020-05-10'
    AND subregion1_name IS NOT NULL
  GROUP BY
    subregion1_name
  ORDER BY
    total_confirmed_cases DESC )
WHERE
  total_confirmed_cases > 10000

  --Result (JSON):
{  "state": "New York",  "total_confirmed_cases": "858582"}
{  "state": "New Jersey",  "total_confirmed_cases": "276548"}
{  "state": "Illinois",  "total_confirmed_cases": "155319"}
{  "state": "Massachusetts",  "total_confirmed_cases": "155283"}
{  "state": "California",  "total_confirmed_cases": "138622"}
{  "state": "Pennsylvania",  "total_confirmed_cases": "116648"}
{  "state": "Michigan",  "total_confirmed_cases": "100100"}
{  "state": "Florida",  "total_confirmed_cases": "79717"}
{  "state": "Texas",  "total_confirmed_cases": "78906"}
{  "state": "Georgia",  "total_confirmed_cases": "75371"}
{  "state": "Connecticut",  "total_confirmed_cases": "66808"}
{  "state": "Maryland",  "total_confirmed_cases": "65272"}
{  "state": "Louisiana",  "total_confirmed_cases": "63136"}
{  "state": "Indiana",  "total_confirmed_cases": "49851"}
{  "state": "Ohio",  "total_confirmed_cases": "48167"}
{  "state": "Virginia",  "total_confirmed_cases": "48162"}
{  "state": "Colorado",  "total_confirmed_cases": "39184"}
{  "state": "Washington",  "total_confirmed_cases": "35418"}
{  "state": "Tennessee",  "total_confirmed_cases": "29815"}
{  "state": "North Carolina",  "total_confirmed_cases": "29547"}
{  "state": "Minnesota",  "total_confirmed_cases": "24805"}
{  "state": "Iowa",  "total_confirmed_cases": "23918"}
{  "state": "Arizona",  "total_confirmed_cases": "22238"}
{  "state": "Wisconsin",  "total_confirmed_cases": "22073"}
{  "state": "Rhode Island",  "total_confirmed_cases": "20132"}
{  "state": "Alabama",  "total_confirmed_cases": "19666"}
{  "state": "Mississippi",  "total_confirmed_cases": "19002"}
{  "state": "Missouri",  "total_confirmed_cases": "18983"}
{  "state": "Nebraska",  "total_confirmed_cases": "16562"}
{  "state": "South Carolina",  "total_confirmed_cases": "15306"}
{  "state": "Kansas",  "total_confirmed_cases": "13993"}
{  "state": "Delaware",  "total_confirmed_cases": "13569"}
{  "state": "Kentucky",  "total_confirmed_cases": "12926"}
{  "state": "District of Columbia",  "total_confirmed_cases": "12661"}
{  "state": "Utah",  "total_confirmed_cases": "12491"}
{  "state": "Nevada",  "total_confirmed_cases": "12218"}

--------------------------------------------------------------------------------------------------------------------

  --Query 4: Fatality Ratio
  --"What was the case-fatality ratio in Italy for the month of May 2020??"

SELECT
  SUM(cumulative_confirmed) AS total_confirmed_cases,
  SUM(cumulative_deceased) AS total_deaths,
  (SUM(cumulative_deceased)/SUM(cumulative_confirmed))*100 AS case_fatality_ratio
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name="Italy"
  AND date BETWEEN '2020-05-01'AND '2020-05-30'

  --Result (JSON):
{  "total_confirmed_cases": "19630147",  "total_deaths": "1880340",  "case_fatality_ratio": "9.5788381003973111"}

--------------------------------------------------------------------------------------------------------------------

  --Query 5: Identifying specific day
  --"On what day did the total number of deaths cross 15000 count in Italy in Italy?"
  --Result: 2020-04-04

SELECT
  date
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name="Italy"
  AND cumulative_deceased>15000
ORDER BY
  date ASC
LIMIT
  1

--------------------------------------------------------------------------------------------------------------------

  --Query 6: Finding days with zero net new cases
  --"Identify the number of days between 2020-02-15 and 2020-03-15 in India when there were zero increases in the number of confirmed cases."
  --Result: 13
  
WITH
  india_cases_by_date AS (
  SELECT
    date,
    SUM( cumulative_confirmed ) AS cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name ="India"
    AND date BETWEEN '2020-02-15'
    AND '2020-03-15'
  GROUP BY
    date
  ORDER BY
    date ASC ),
  india_previous_day_comparison AS (
  SELECT
    date,
    cases,
    LAG(cases) OVER(ORDER BY date) AS previous_day,
    cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
  FROM
    india_cases_by_date )
SELECT
  COUNT(*)
FROM
  india_previous_day_comparison
WHERE
  net_new_cases=0

--------------------------------------------------------------------------------------------------------------------

  --Query 7: Doubling rate
  --"Find out the dates on which the confirmed cases increased by more than Limit Value of 15 % compared to the previous day (indicating doubling rate of ~ 7 days) in the US between the dates March 20, 2020 and April 20, 2020. "

WITH
  us_cases_by_date AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="United States of America"
    AND date BETWEEN '2020-03-20'
    AND '2020-04-20'
  GROUP BY
    date
  ORDER BY
    date ASC ),
  us_previous_day_comparison AS (
  SELECT
    date,
    cases,
    LAG(cases) OVER(ORDER BY date) AS previous_day,
    cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases,
    (cases - LAG(cases) OVER(ORDER BY date))*100/LAG(cases) OVER(ORDER BY date) AS percentage_increase
  FROM
    us_cases_by_date )
SELECT
  Date,
  cases AS Confirmed_Cases_On_Day,
  previous_day AS Confirmed_Cases_Previous_Day,
  percentage_increase AS Percentage_Increase_In_Cases
FROM
  us_previous_day_comparison
WHERE
  percentage_increase > 15

  --Result (JSON):
{  "Date": "2020-03-21",  "Confirmed_Cases_On_Day": "117843",  "Confirmed_Cases_Previous_Day": "95633",  "Percentage_Increase_In_Cases": "23.224200851170622"}
{  "Date": "2020-03-23",  "Confirmed_Cases_On_Day": "177976",  "Confirmed_Cases_Previous_Day": "144696",  "Percentage_Increase_In_Cases": "22.999944711671365"}
{  "Date": "2020-03-25",  "Confirmed_Cases_On_Day": "257642",  "Confirmed_Cases_Previous_Day": "215096",  "Percentage_Increase_In_Cases": "19.78000520697735"}
{  "Date": "2020-03-27",  "Confirmed_Cases_On_Day": "372082",  "Confirmed_Cases_Previous_Day": "312642",  "Percentage_Increase_In_Cases": "19.012160874098811"}
{  "Date": "2020-03-28",  "Confirmed_Cases_On_Day": "439869",  "Confirmed_Cases_Previous_Day": "372082",  "Percentage_Increase_In_Cases": "18.218295967018022"}
{  "Date": "2020-03-24",  "Confirmed_Cases_On_Day": "215096",  "Confirmed_Cases_Previous_Day": "177976",  "Percentage_Increase_In_Cases": "20.856744729626467"}
{  "Date": "2020-03-22",  "Confirmed_Cases_On_Day": "144696",  "Confirmed_Cases_Previous_Day": "117843",  "Percentage_Increase_In_Cases": "22.787098088134211"}
{  "Date": "2020-03-26",  "Confirmed_Cases_On_Day": "312642",  "Confirmed_Cases_Previous_Day": "257642",  "Percentage_Increase_In_Cases": "21.347451114336948"}

--------------------------------------------------------------------------------------------------------------------

  --Query 8: Recovery rate
  --Build a query to list the recovery rates of countries arranged in descending order (limit to 5 ) upto the date May 10, 2020.
  
WITH
  cases_by_country AS (
  SELECT
    country_name AS country,
    SUM(cumulative_confirmed) AS cases,
    SUM(cumulative_recovered) AS recovered_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    date = '2020-05-10'
  GROUP BY
    country_name ),
  recovered_rate AS (
  SELECT
    country,
    cases,
    recovered_cases,
    (recovered_cases * 100)/cases AS recovery_rate
  FROM
    cases_by_country )
SELECT
  country,
  cases AS confirmed_cases,
  recovered_cases,
  recovery_rate
FROM
  recovered_rate
WHERE
  cases > 50000
ORDER BY
  recovery_rate DESC
LIMIT
  5

  --Result (JSON):
{  "country": "France",  "confirmed_cases": "216220",  "recovered_cases": "4566869",  "recovery_rate": "2112.1399500508742"}
{  "country": "China",  "confirmed_cases": "156251",  "recovered_cases": "146636",  "recovery_rate": "93.846439382787949"}
{  "country": "Germany",  "confirmed_cases": "424364",  "recovered_cases": "240082",  "recovery_rate": "56.574544494820486"}
{  "country": "Italy",  "confirmed_cases": "643471",  "recovered_cases": "210372",  "recovery_rate": "32.69331485024189"}
{  "country": "Philippines",  "confirmed_cases": "51314",  "recovered_cases": "16305",  "recovery_rate": "31.774954203531202"}


--------------------------------------------------------------------------------------------------------------------

  --Query 9: CDGR - Cumulative Daily Growth Rate
  --Calculate the CDGR on May 10, 2020 (Cumulative Daily Growth Rate) for France since the day the first case was reported. The first case was reported on Jan 24, 2020.

WITH
  france_cases AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS total_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="France"
    AND date IN ('2020-01-24',
      '2020-05-10')
  GROUP BY
    date
  ORDER BY
    date),
  summary AS (
  SELECT
    total_cases AS first_day_cases,
    LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
    DATE_DIFF(LEAD(date) OVER(ORDER BY date),date, day) AS days_diff
  FROM
    france_cases
  LIMIT
    1 )
SELECT
  first_day_cases,
  last_day_cases,
  days_diff,
  POW((last_day_cases/first_day_cases),(1/days_diff))-1 AS cdgr
FROM
  summary

  --Result (JSON):
{  "first_day_cases": "3",  "last_day_cases": "216220",  "days_diff": "107",  "cdgr": "0.11019626699372975"}

--------------------------------------------------------------------------------------------------------------------

  --Task 10 : Create a Datastudio report
  --Create a Google Data Studio report that plots the following for the United States:
  
  --Number of Confirmed Cases
  --Number of Deaths
  --Date range : between 2020-03-15 and 2020-04-30

SELECT
  date,
  SUM(cumulative_confirmed) AS country_cases,
  SUM(cumulative_deceased) AS country_deaths
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date BETWEEN '2020-03-15'
  AND '2020-04-30'
  AND country_name ="United States of America"
GROUP BY
  date
