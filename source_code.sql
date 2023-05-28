
-- Data Overview: The follwoing dataset presents the whoe jouney of clients (i.e clients, youtubers) for sales from outreacing to the final singning of the contract with the potential clients. The source of dataset is from a company where help creators to edit their video conent on their Youtube channels.With investigation of the sales journey of the potenail target clients, it would be expected to gain meaningful sales insights to improve the current sales methods, plus, what specific profiles of creator have better chance to sign than others.



-- Research Questions:
-- * Q1. How many deals are successfully won and how different by region and sales person, vertical/genre, business potential
-- * Q2. Stages, funnel analysis for each stages
-- * Q3. How many emails exhanged with creators while in touch.




-- 1. Data cleaning

-- 1) Understanding fields

-- client_id:assigned unique token per client
-- deal_created:the date of deal created before outreaching, outreaching date can be known with 'last_stage_change'
-- sales_business_unit:countries of target clients
-- business_potential:business potential from 1~5 rated by operation team. Each business potential indicate the estimated value of clients that potentiaally generated the revenues when working with us 5 = Highest value client (monthly estimated value 40k+ usd), 4=High value client (monthly 30k+), 3 = Middle value client (20k+), 2 = Low value client (monthly 15k+), 1 = No value client (0) 
-- status:Lost, Won, Open. Lost=Failed to sign the client, Won = Succesfully signed the client, Open = on going process to sign
-- lost_time: lost time being disconnected with the potential client.
-- genre: big genres of channel
-- vertical: specific content of channel in the assinged genre
-- sales_owner:Initial of sales person who's in charge of saling on target clients. 
-- stage: Sales stages from outreaching to singing - Outreaching (contact client by email) > Discussing (introducing about the selling product) > Testing (Test launch with a company's version of product) > Negotiating (Profit sharing) > Preparing Offer (Specific Offer term suggested by the company to the creator) > Redlining ()
-- last_stage_change:
-- won_time:the singed date with the client
-- last_email_received:date of last email received from the client
-- last_email_sent:date of lst email sent to the client by the sales person
-- deal_closed_time: the terminating of the deals in the sales process for some reasons noarmlly its status either won, lost
-- total_email_messages_count:the total number of email exchanged between the sales person and client




-- 1) Identify Null values in the "main" table



SELECT * FROM `personal-projects-382818.project1_sales_journey.main`
  WHERE client_id IS NULL
  OR deal_created IS NULL
  OR sales_business_unit IS NULL
  OR business_potential IS NULL
  OR status IS NULL
  OR lost_time IS NULL
  OR genre IS NULL
  OR vertical IS NULL
  OR sales_owner IS NULL
  OR stage IS NULL
  OR last_stage_change IS NULL
  OR won_time IS NULL
  OR last_email_received IS NULL
  OR last_email_sent IS NULL
  OR deal_closed_time IS NULL
  OR total_email_messages_count IS NULL

-- According to the query results, there are many empty cells with null > Let's check in detail how many null values contained in each columns

SELECT COUNT(*) AS client_id FROM `personal-projects-382818.project1_sales_journey.main` WHERE client_id IS NULL

SELECT COUNT(*) AS deal_created FROM `personal-projects-382818.project1_sales_journey.main` WHERE deal_created IS NULL

SELECT COUNT(*) AS sales_business_unit FROM `personal-projects-382818.project1_sales_journey.main` WHERE sales_business_unit IS NULL

SELECT COUNT(*) AS business_potential FROM `personal-projects-382818.project1_sales_journey.main` WHERE business_potential IS NULL

SELECT COUNT(*) AS genre FROM `personal-projects-382818.project1_sales_journey.main` WHERE genre IS NULL

SELECT COUNT(*) AS vertical FROM `personal-projects-382818.project1_sales_journey.main` WHERE vertical IS NULL

SELECT COUNT(*) AS sales_owner FROM `personal-projects-382818.project1_sales_journey.main` WHERE sales_owner IS NULL

SELECT COUNT(*) AS status FROM `personal-projects-382818.project1_sales_journey.main` WHERE status IS NULL

SELECT COUNT(*) AS lost_time FROM `personal-projects-382818.project1_sales_journey.main` WHERE lost_time IS NULL

SELECT COUNT(*) AS stage FROM `personal-projects-382818.project1_sales_journey.main` WHERE stage IS NULL

SELECT COUNT(*) AS last_stage_change FROM `personal-projects-382818.project1_sales_journey.main` WHERE last_stage_change IS NULL

SELECT COUNT(*) AS won_time FROM `personal-projects-382818.project1_sales_journey.main` WHERE won_time IS NULL

SELECT COUNT(*) AS last_email_received FROM `personal-projects-382818.project1_sales_journey.main` WHERE last_email_received IS NULL

SELECT COUNT(*) AS last_email_sent FROM `personal-projects-382818.project1_sales_journey.main` WHERE last_email_sent IS NULL

SELECT COUNT(*) AS deal_closed_time FROM `personal-projects-382818.project1_sales_journey.main` WHERE deal_closed_time IS NULL

SELECT COUNT(*) AS total_email_messages_count FROM `personal-projects-382818.project1_sales_journey.main` WHERE total_email_messages_count IS NULL

-- the followings are the total null counts in each columns
-- client_id null count: 136
-- deal_created null count: 0
-- sales_business_unit null count: 0 
-- business_potential null count:  212
-- status null count: 0
-- lost_time null count: 1763 
-- genre null count: 0
-- vertical null count: 1049 
-- sales_owner null count: 0 
-- stage null count: 0 
-- last_stage_change null count: 40 
-- won_time null count: 9096
-- last_email_received null count: 5324 
-- last_email_sent null count: 1356
-- deal_closed_time null count: 1115
-- total_email_messages_count null count: 0 



-- In order to understand the dataset properly, I investigated why some columns have a lot of Null values than others > After the consultaion with operation & sales team, I was informed that some of the info given in a deal are not required mandatory input data (i.e fileds) > This is specificities of why some columns have null values and some doesn't > the null values will be treated distinctively depending on the research questions to be answered (e.g. why no total email numbers are 0 for Won creators? )




-- 2) Identify duplicates
-- Let's check if any duplicates for client_id



WITH a AS (
SELECT client_id, COUNT(*) AS duplicate_count FROM `personal-projects-382818.project1_sales_journey.main`
WHERE client_id IS NOT NULL
GROUP BY client_id
ORDER BY duplicate_count DESC
) SELECT * FROM a
WHERE duplicate_count >=2


-- according to the query total 42 clients_id have more than 2 duplicates > we need to investigate which should be removed from the analysis > after talk with the operation team, the deal created later has to be removed because those deals were created by mistake.

-- The following queries shows the result that excluded the duplicated client id which created later than the same deal already created earlier + new column added "yearly_est_values" calculated based on the business potential (sum of 12 months per business_potential)

WITH 
duplicate_clients_list_count AS (
  SELECT client_id, COUNT(*) AS duplicate_count FROM `personal-projects-382818.project1_sales_journey.main`
  WHERE client_id IS NOT NULL
  GROUP BY client_id
  ORDER BY duplicate_count DESC 
), 
duplicate_clients_list AS (
  SELECT * FROM duplicate_clients_list_count 
  WHERE duplicate_count >=2
), 
duplicate_client_list_with_deal_created AS (
  SELECT client_id, deal_created FROM `personal-projects-382818.project1_sales_journey.main`
  WHERE client_id 
  IN (
    SELECT client_id FROM duplicate_clients_list
    )
), 
duplicated_client_tobe_removed AS (
  SELECT client_id, MAX(deal_created) AS deal_created FROM duplicate_client_list_with_deal_created
  GROUP BY client_id
),
dupplicated_client_removed AS (
SELECT * FROM `personal-projects-382818.project1_sales_journey.main`
  WHERE client_id 
  NOT IN (
    SELECT client_id FROM duplicated_client_tobe_removed
    )
),
new_column_est_values AS (
  SELECT *,
    CASE business_potential
        WHEN 5 THEN 480000
        WHEN 4 THEN 360000
        WHEN 3 THEN 240000
        WHEN 2 THEN 180000
        WHEN 1 THEN 0
    END AS yearly_est_revenues
  FROM dupplicated_client_removed
)
SELECT * FROM new_column_est_values


-- Valdity of values in certain columns (sales_business_unit, business_potential, status, genre, vertical, stage) > the values assinged in each columns are valid. No syntax errors identified


SELECT DISTINCT(vertical) FROM `personal-projects-382818.project1_sales_journey.main_cleaned`

-- Status of data cleaning? > the datssets are ready for analysis. Let's start analysis and the answer the questions!




-- * Q1. How many deals are successfully won and how different by region and sales person, vertical/genre, business potential


SELECT status, COUNT(*) AS count, ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
GROUP BY status
ORDER BY count DESC



-- The followings are the total number of deals according to its status
-- Won: 639 deals (6.71%)
-- Open: 1075 deals (11.29%)
-- Lost: 7810 deals (82%)
-- Globally, the chances to get Won deals are 6.71% > Let's investigate the features of Won deals in dept in order to see if there are any useful insights that the won deals have

WITH a AS (
SELECT status, FORMAT_DATE('%b %Y', won_time) as won_time
FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE status = 'Won'
) SELECT won_time, COUNT(*) as count  FROM a
GROUP BY won_time






-- Q1-1. What is the distrubtion by sales-business-unit?

-- In this query I additionally add Country_code just in case for the data viz in the world map

SELECT 
  sales_business_unit, 
  COUNT(*) AS count, 
  CONCAT(ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(), 2), '%') AS percentage,
  CASE
    WHEN sales_business_unit = 'USA' THEN 'USA'
    WHEN sales_business_unit = 'France' THEN 'FRA'
    WHEN sales_business_unit = 'UK' THEN 'GBR'
    WHEN sales_business_unit = 'Brazil' THEN 'BRA'
    WHEN sales_business_unit = 'India' THEN 'IND'
    WHEN sales_business_unit = 'ANZ' THEN 'OCN' -- Replace 'OCN' with the appropriate code if necessary
    WHEN sales_business_unit = 'Spanish Latam' THEN 'LAM' -- Replace 'LAM' with the appropriate code if necessary
    WHEN sales_business_unit = 'South Korea' THEN 'KOR'
    WHEN sales_business_unit = 'Spain' THEN 'ESP'
    ELSE NULL
  END AS country_code
FROM 
  `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE 
  status = "Won"
GROUP BY 
  sales_business_unit
ORDER BY 
  count DESC

-- Accordering to the result of the query, it reveals that USA is the most succescul countries, France, Brasil, India, UK, Spanish Latam, ANZ, South KOrea, Spain follow

-- USA: 406(63.54%)
-- France: 87 (13.62%)
-- Brasil: 36 (5.63%)
-- India: 30 (4.69%)

-- The Won deal distribution by region by sheer count does not show much dynamic info > let's further check how difficult market by region considering the distribution of status of their deals by regions

With status_region_distribution AS (
SELECT 
    sales_business_unit, 
    status, 
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY sales_business_unit), 2) AS percentage
FROM 
    `personal-projects-382818.project1_sales_journey.main_cleaned`
GROUP BY 
    sales_business_unit, 
    status
ORDER BY 
    sales_business_unit, 
    status
)
SELECT sales_business_unit, status,count, CONCAT(percentage, "%") AS won_percentage FROM status_region_distribution
WHERE status = 'Won'
ORDER BY percentage DESC

-- By the propertion of won deal, USA still has the highest chance of having won deal, France, UK, Brasil, India followed up > based on this, we can conclude that Spain is the hardedst market to get Won deals. 

-- USA : 10.77%
-- France: 10.08%
-- UK: 5.19%
-- Brasil: 3.84%
-- India: 3.39%.

-- Q1-2. Who is the best sales in each month? > The best sales month is in DEC 2021, the won deal is 90 deals in total. Nov 2021, Sep 2021, Oct 2021 follows.

WITH sales_month AS (
  SELECT sales_owner, sales_business_unit, won_time, FORMAT_DATE('%b %Y',won_time) AS month_year, yearly_est_revenues
  FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
  WHERE status = "Won"
)
SELECT month_year, COUNT(*) AS count, SUM(yearly_est_revenues) AS total_est_revenue FROM sales_month
GROUP BY month_year
ORDER BY count DESC


-- Q1-3. Who is the best sales person in each month?

WITH a AS (
SELECT sales_owner, sales_business_unit, won_time, FORMAT_DATE('%b %Y',won_time) AS month_year, yearly_est_revenues
FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE status = "Won"
),
b AS (
SELECT month_year, sales_owner, COUNT(*) AS count FROM a
GROUP BY month_year, sales_owner
ORDER BY month_year DESC
),
c AS (
SELECT month_year, sales_owner, count, RANK() OVER (PARTITION BY month_year ORDER BY count DESC) AS rank FROM b
) SELECT month_year,sales_owner, count FROM c
WHERE rank = 1
ORDER BY month_year ASC


-- Q1-4, Wht is the days of won time?

-- Draw histogram in python to see the distribution of won_time > result: 0~200 days is the range where most of won_days values concentrated on. 

SELECT DATE_DIFF(won_time, deal_created, day) as won_days FROM `personal-projects-382818.project1_sales_journey.main_cleaned` 
WHERE status = 'Won'


-- The following query shows the max, min, avg days of won since the deal created by each countries. 

SELECT sales_business_unit,MAX(DATE_DIFF(won_time, deal_created, day)) AS max ,MIN(DATE_DIFF(won_time, deal_created, day)) AS min, ROUND(AVG((DATE_DIFF(won_time, deal_created, day))),2) AS avg FROM `personal-projects-382818.project1_sales_journey.main_cleaned` 
WHERE status = 'Won'
GROUP BY sales_business_unit


-- Q1-5. What genre/vertical among all deals and their avg/sum-est-rev?
SELECT genre, COUNT(*) AS count, SUM(yearly_est_revenues) AS sum_rev, ROUND(AVG(yearly_est_revenues),2) AS avg_rev FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE yearly_est_revenues IS NOT NULL
GROUP BY genre
ORDER BY count DESC



-- Q1-6. The distribution of business potential

-- business_potential
SELECT business_potential, COUNT(*) FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
GROUP BY business_potential
ORDER BY business_potential DESC


-- Distirbution by genre and Business potential


WITH source_data AS (
  SELECT business_potential, genre, COUNT(*) AS count
  FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
  WHERE business_potential IS NOT NULL
  GROUP BY business_potential, genre
),
genre_totals AS (
  SELECT genre, SUM(count) AS total_count
  FROM source_data
  GROUP BY genre
)
SELECT 
  sd.genre,
  ROUND(SUM(CASE WHEN sd.business_potential = 1 THEN sd.count ELSE 0 END) / gt.total_count * 100, 2) AS `1`,
  ROUND(SUM(CASE WHEN sd.business_potential = 2 THEN sd.count ELSE 0 END) / gt.total_count * 100, 2) AS `2`,
  ROUND(SUM(CASE WHEN sd.business_potential = 3 THEN sd.count ELSE 0 END) / gt.total_count * 100, 2) AS `3`,
  ROUND(SUM(CASE WHEN sd.business_potential = 4 THEN sd.count ELSE 0 END) / gt.total_count * 100, 2) AS `4`,
  ROUND(SUM(CASE WHEN sd.business_potential = 5 THEN sd.count ELSE 0 END) / gt.total_count * 100, 2) AS `5`
FROM source_data sd
JOIN genre_totals gt ON sd.genre = gt.genre
GROUP BY sd.genre, gt.total_count
ORDER BY sd.genre


-- * Q2. Stages, funnel analysis for each stages

-- The stages order: 1. Outreaching > 2. Discussing > 3. Testing > 4. Preparing Offer > 5.Negotiating > 6.Redlining

-- 1) what is the % to get each stages from outreaching?

-- Followings are the method to obtain the % to be positively moved from one stage to another
-- Outreaching > Discussing (%). : (Discussing + Testing + Preparing Offer + Negotiating + Redlining)/(Total Deal counts) * 100
-- Discussing > Testing: (%) ; (Testing + Preparing Offer + Negotiating + Redlining)/(Discussing + Testing + Preparing Offer + Negotiating + Redlining) * 100
-- Testing > Preparing Offer (%) : (Preparing Offer + Negotiating + Redlining)/(Testing + Preparing Offer + Negotiating + Redlining) * 100
-- Preparing offer > Negotiating (%) : (Negotiating + Redlining)/(Preparing Offer + Negotiating + Redlining) * 100
-- Negotiating > Redlining (%) : (Redlining)/(Negotiating + Redlining) * 100

-- Let's first check how many deal counts currently exist in each stages.

 -- how different by country? USA, UK, France,Brasil


WITH stage_count AS (
  SELECT
    CASE 
      WHEN stage = 'Outreaching' THEN '1-Outreaching'
      WHEN stage = 'Discussing' THEN '2-Discussing'
      WHEN stage = 'Testing' THEN '3-Testing'
      WHEN stage = 'Preparing Offer' THEN '4-Preparing Offer'
      WHEN stage = 'Negotiating' THEN '5-Negotiating'
      WHEN stage = 'Redlining' THEN '6-Redlining'
      ELSE 'Unknown'
    END AS stage,
    sales_business_unit AS country,
    COUNT(*) AS count
  FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
  GROUP BY stage, country
),
funnel_metrics AS (
  SELECT
    country,
    ROUND(SUM(IF(stage NOT IN ('1-Outreaching'), count, 0)) / SUM(count) * 100, 2) AS out_dis,
    ROUND(SUM(IF(stage NOT IN ('1-Outreaching', '2-Discussing'), count, 0)) / SUM(IF(stage NOT IN ('1-Outreaching'), count, 0)) * 100, 2) AS dis_test,
    ROUND(SUM(IF(stage NOT IN ('1-Outreaching', '2-Discussing', '3-Testing'), count, 0)) / SUM(IF(stage NOT IN ('1-Outreaching', '2-Discussing'), count, 0)) * 100, 2) AS test_offer,
    ROUND(SUM(IF(stage NOT IN ('1-Outreaching', '2-Discussing', '3-Testing', '4-Preparing Offer'), count, 0)) / SUM(IF(stage NOT IN ('1-Outreaching', '2-Discussing', '3-Testing'), count, 0)) * 100, 2) AS offer_nego,
    ROUND(SUM(IF(stage IN ('6-Redlining'), count, 0)) / SUM(IF(stage IN ('5-Negotiating', '6-Redlining'), count, 0)) * 100, 2) AS nego_red
  FROM stage_count
  GROUP BY country
)
SELECT * FROM funnel_metrics



-- * Q3. How many emails exhanged with creators while in touch.

-- What is the implication of the question? > the number of total email exchanged could be one of the indicators to see how the client interest in our product + how the sales team engage with the client.

-- I noticed that 'total_email_messages_conunt' is 0 despite it's been contacted, this should be data missing by accident or contacted by phone etc, so those rows will be excluded from the analysis to answer the question


-- How often the emails exchanged with Won deals? > Acording to the histogram graphs, most concentrated range is 30~35. Impliying that 30~35 emailes should be enough number of exchange to succeccfully onboard creators. > At the same time, we might throw a question that "Any more efficient way to minimize the number of email exchange (i.e. minimizing contact leading to the faster on-boarding process)"

-- Case 1: total_email_messages_count > 0 - The most concentrated range 0~50

WITH a AS (
SELECT total_email_messages_count FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE total_email_messages_count <=50  AND total_email_messages_count >0 AND status = 'Won'
) SELECT AVG(total_email_messages_count) FROM a


-- Case 2: 1<total_email_messages_count < 50 - The most concentrated area: 30~35

SELECT total_email_messages_count FROM `personal-projects-382818.project1_sales_journey.main_cleaned`
WHERE total_email_messages_count <50 AND total_email_messages_count >0  AND status = 'Won'








    
