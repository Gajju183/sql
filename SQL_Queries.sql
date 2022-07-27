-- Date Format
FORMAT_DATETIME('%F', DATETIME(a.`date_time`, IF (a.`timezone` = 'America/New York', 'America/New_York', a.`timezone`))) AS `timezone_date`,


Last Date of previous month
---------------------------------
Select DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 DAY)

First Date of month
------------------------
Select DATE_TRUNC(CURRENT_DATE(), MONTH)
MY-SQL SELECT DATE_SUB(LAST_DAY(NOW()),INTERVAL DAY(LAST_DAY(NOW()))-1 DAY) AS 'FIRST DAY OF CURRENT MONTH';

Yesterday
----------------------
Select DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)

Last date of previous month 1+N
---------------------------------
Select DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 1 DAY)

---Funnel Query-------------------------------------------------------------------
SELECT * FROM
((SELECT 'Impressions' as Step, sum(section_stats.impressions) AS Value
FROM section_stats 
join outbrain_configuration on section_stats.campaignId = outbrain_configuration.campaignId
where 1=1 [[AND {{Date}}]]
[[AND {{Campaign}}]]
[[AND {{publisherName}}]]
[[AND {{Account}}]]
[[AND {{status}}]]
[[AND {{AM}}]]
[[AND {{SM}}]]
[[AND {{Agency}}]]
[[AND {{BillingEntity}}]]
[[AND {{region}}]]
[[AND {{industry}}]]
UNION ALL
(SELECT 'Conversions' as Step, sum(section_stats.ClickConversions) AS Value
FROM section_stats 
join outbrain_configuration on section_stats.campaignId = outbrain_configuration.campaignId
where 1=1 [[AND {{Date}}]]
[[AND {{Campaign}}]]
[[AND {{publisherName}}]]
[[AND {{Account}}]]
[[AND {{status}}]]
[[AND {{AM}}]]
[[AND {{SM}}]]
[[AND {{Agency}}]]
[[AND {{BillingEntity}}]]
[[AND {{region}}]]
[[AND {{industry}}]]
UNION ALL
(SELECT 'Clicks' as Step, sum(section_stats.Clicks) AS Value
FROM section_stats 
join outbrain_configuration on section_stats.campaignId = outbrain_configuration.campaignId
where 1=1 [[AND {{Date}}]]
[[AND {{Campaign}}]]
[[AND {{publisherName}}]]
[[AND {{Account}}]]
[[AND {{status}}]]
[[AND {{AM}}]]
[[AND {{SM}}]]
[[AND {{Agency}}]]
[[AND {{BillingEntity}}]]
[[AND {{region}}]]
[[AND {{industry}}]]))
ORDER BY 2 DESC

--  Dense_rank----------------------------------------------------------------------
select * from(
select Order_id, Order_date, Cust_name,Order_city,SUM(Order_amount) AMT, dense_rank() 
over(order by SUM(Order_amount) desc)r from `orders` 
WHERE Order_city = 'Agara' group by 1,2,3,4) 
where r=7


Order_id	Order_date	Cust_name	Order_amount	Order_city
1	21-Nov-21	17850	1227	Agara
2	14-Nov-21	13047	1724	Kolkata
3	02-Nov-21	12583	4520	Mumbai
4	24-Nov-21	13748	4573	Agara
5	22-Nov-21	15100	1089	Kolkata
6	22-Nov-21	15291	8538	Mumbai
7	16-Nov-21	14688	5015	Agara
8	26-Nov-21	17809	7880	Kolkata
9	07-Nov-21	15311	1767	Mumbai
10	11-Nov-21	14527	8734	GGN
----Case When-------------------------------------------------------------------
Select (SELECT SUM(booked_spend) as `Booked`FROM `snapchat.spend_forecast` a
JOIN `snapchat.reporting_configuration` b ON a.`tyroo_account_id` = b.`tyroo_account_id`
WHERE ds between CAST("2019-10-01" AS DATE)  and CAST("2019-10-31" AS DATE)
AND b.reporting_entity = 'Vidtech Client Credit') - (SELECT SUM(`Spend`)  as `Spend` FROM
(SELECT a.tyroo_advertiser_name as `Advertiser_name`, a.tyroo_account_id as `Account_id`, 
CASE when a.tyroo_account_id = 2061 then DATE(a.date_time, "Asia/Dubai")
when a.tyroo_account_id = 2063 then DATE(a.date_time, "America/Los_Angeles")
when a.tyroo_account_id = 2195 then DATE(a.date_time, "America/Los_Angeles")
when a.tyroo_account_id = 2211 then DATE(a.date_time, "Asia/Riyadh")
when a.tyroo_account_id = 2213 then DATE(a.date_time, "Asia/Dubai")
when a.tyroo_account_id = 2247 then DATE(a.date_time, "Asia/Dubai")
when a.tyroo_account_id = 2275 then DATE(a.date_time, "America/Los_Angeles")
when a.tyroo_account_id = 2277 then DATE(a.date_time, "Asia/Dubai")
when a.tyroo_account_id = 2287 then DATE(a.date_time, "America/Los_Angeles")
when a.tyroo_account_id = 2289 then DATE(a.date_time, "America/Los_Angeles")
when a.tyroo_account_id = 2291 then DATE(a.date_time, "Asia/Dubai") END as DAY,
sum(`spend`) `Spend` FROM snapchat.hourly_stats a
JOIN `snapchat.reporting_configuration` b ON a.`tyroo_account_id` = b.`tyroo_account_id`
WHERE date between CAST("2019-09-30" AS DATE)  and CAST("2019-10-09" AS DATE)
AND a.swipe_up_attribution_window = '1_DAY'
AND a.view_attribution_window = 'None'
AND b.reporting_entity = 'Vidtech Client Credit'
GROUP BY 1,2,3))

----Multiple ifs-------------------------------------------------------------------

IF ((SELECT Dimension FROM `facebook.dimension_data` WHERE {{Dimension}} LIMIT 1) = 'Region') THEN SELECT Region, sum(Amount_Spent_INR) spend 
FROM `facebook.dimension_data` WHERE DAY = '2020-12-12'AND Region != 'NA'GROUP BY 1; 
ELSEIF 
((SELECT Dimension FROM `facebook.dimension_data` WHERE {{Dimension}} LIMIT 1) = 'Demo') THEN SELECT age , gender, sum(Amount_Spent_INR) spend 
FROM `facebook.dimension_data` WHERE DAY = '2020-12-12'AND Age != 'NA'GROUP BY 1, 2; 
ELSE SELECT Platform , Device_Platform, sum(Amount_Spent_INR) spend FROM `facebook.dimension_data` WHERE DAY = '2020-12-12'AND Age != 'NA'GROUP BY 1, 2; END IF;

-- ROllup
SELECT coalesce(`Campaign`,"Grand_Total") as `Campaign`,coalesce(`Affiliate`,"Sub_Total") as `publisher`
, `Installs`, `Purchases`, `intall_to_Purchase`, `Revenue` FROM
(
SELECT `campaignname`as `Campaign`,`marketplace.affiliates`.`affiliateName`as `Affiliate`,
count(case when `stdEventId` = 127 then `stdEventId` else null end) as `installs`,
count(case when `stdEventId` = 62 then `stdEventId` else null end) as `Purchases`,
SAFE_DIVIDE(count(case when `stdEventId` = 62 then `stdEventId` else null end), count(case when `stdEventId` = 127 then `stdEventId` else null end)) as `intall_to_Purchase`, 
count(case when `stdEventId` = 62 then `stdEventId` else null end)*.72 as `Revenue`
FROM `marketplace.advertiser_events`
LEFT JOIN `marketplace.affiliates` ON `marketplace.affiliates`.`affiliateId` = case when `marketplace.advertiser_events`.`AffiliateId` = 8504
then `marketplace.advertiser_events`.`originalAffiliateId` else  `marketplace.advertiser_events`.`AffiliateId` end
WHERE `campaignId` IN (486821,486825) AND {{date}} AND date(`marketplace.advertiser_events`.`eventDateTime`) < CURRENT_DATE()
AND `marketplace.advertiser_events`.`affiliateId` != 7 
GROUP BY ROLLUP (`Campaign`,`Affiliate`) ORDER BY `Campaign` ASC,`Revenue` DESC
) 
WHERE `Installs` is not NULL OR `Purchases` is not NULL
