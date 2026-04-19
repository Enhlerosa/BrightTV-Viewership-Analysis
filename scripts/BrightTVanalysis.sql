----- Master code ———— 

SELECT 
----- 1. Identity and Base Columns
    COALESCE(A.UserID, B.UserID0) AS Final_UserID, 
    A.GENDER, 
    A.RACE, 
    A.PROVINCE, 
    A.AGE, 
    B.Channel2, 
    B.RecordDate2, 
    B.Duration2,
    B.userid4,

----- 2. Date & Time Analysis (SA Time)
    DAYNAME(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg')) AS Day_name,
    MONTHNAME(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg')) AS Month_name,
    HOUR(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg')) AS Peak_hour,
    
    CASE 
        WHEN DAYNAME(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg')) IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,

    CASE 
        WHEN DATE_FORMAT(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg'), 'HH:mm:ss') BETWEEN '00:00:00' AND '11:59:59' THEN '01. Morning'
        WHEN DATE_FORMAT(FROM_UTC_TIMESTAMP(B.RecordDate2, 'Africa/Johannesburg'), 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN '02. Afternoon'
        ELSE '03. Evening'
    END AS time_buckets,

----- 3. Age Brackets
    CASE 
        WHEN A.AGE < 13 THEN '01. Kids (<13)'
        WHEN A.AGE BETWEEN 13 AND 18 THEN '02. Youth (13-18)'
        WHEN A.AGE > 18 THEN '03. Adult (>18)'
        ELSE '04. Unknown'
    END AS age_classification,

----- 4. Streaming duration 
    COUNT(B.UserID0) AS Total_streams,
    ROUND(SUM(HOUR(B.Duration2) * 3600 + MINUTE(B.Duration2) * 60 + SECOND(B.Duration2)) / 60, 2) AS Total_minutes_watched

FROM userprofiles AS A 
FULL OUTER JOIN viewership AS B ON A.UserID = B.UserID0

GROUP BY 
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
ORDER BY B.RecordDate2 DESC;





——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
----- Top 10 most watched channels 
-------------------------------------------------------------------------------------
SELECT 
    Channel2, 
    COUNT(*) AS Total_Streams
FROM viewership
GROUP BY Channel2
ORDER BY Total_Streams DESC
LIMIT 10;



--------------------------------------------------------------------------------------
-----Performance of different channels in each province and number of minutes watched 
per channel
---------------------------------------------------------------------------------------
SELECT 
    A.PROVINCE, 
    B.Channel2, 
    COUNT(*) AS Stream_Count,
    SUM(hour(B.Duration2) * 60 + minute(B.Duration2)) AS Total_Minutes
FROM userprofiles AS A
JOIN viewership AS B ON A.UserID = B.UserID0
WHERE A.PROVINCE IS NOT NULL
GROUP BY A.PROVINCE, B.Channel2
ORDER BY A.PROVINCE, Stream_Count DESC;



-----------------------------------------------------------------------------------------------
---- Total streams in morning, afternoon, evening and late night/ early morning
------------------------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN DATE_FORMAT(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg'), 'HH:mm') BETWEEN '06:00' AND '11:59' THEN 'Morning'
        WHEN DATE_FORMAT(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg'), 'HH:mm') BETWEEN '12:00' AND '17:59' THEN 'Afternoon'
        WHEN DATE_FORMAT(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg'), 'HH:mm') BETWEEN '18:00' AND '23:59' THEN 'Evening'
        ELSE 'Late Night / Early Morning'
    END AS Time_Bucket,
    COUNT(*) AS Total_Streams
FROM viewership
GROUP BY 1
ORDER BY Total_Streams DESC;


---------------------------------------------------------------------------------
----Total subscribers in each province
----------------------------------------------------------------------------------
SELECT 
    PROVINCE, 
    COUNT(UserID) AS user_countbyprovince
FROM (
    -- This is the joined tables part
    SELECT 
        A.PROVINCE, 
        B.UserID0 AS UserID 
    FROM userprofiles AS A
    JOIN viewership AS B ON A.UserID = B.UserID0
) 
GROUP BY PROVINCE 
ORDER BY user_countbyprovince DESC;


————————————————————————————————————————————————————————————————————————————————
----- Total number of subscribers
-------------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT A.UserID) AS total_subscribers
FROM userprofiles AS A
LEFT JOIN viewership AS B ON A.UserID = B.UserID0;


--------------------------------------------------------------------------------------
----- Total subscribers by gender
---------------------------------------------------------------------------------------
SELECT 
    GENDER, 
    COUNT(UserID) AS Male_Female_count 
FROM userprofiles 
GROUP BY GENDER 
ORDER BY Male_Female_count DESC;



————————————————————————————————————————————————————————————————————————————————————————
---- Viewership date range 
---------------------------------------------------------------------------------------
SELECT 
    MIN(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) AS first_RecordDate,
    MAX(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) AS last_RecordDate 
FROM viewership;



----------------------------------------------------------------------------------------
--- Total unique subscribers by race
----------------------------------------------------------------------------------------
SELECT 
    COALESCE(A.RACE, 'Unknown') AS Race_Bucket,
    COUNT(DISTINCT COALESCE(A.UserID, B.UserID0)) AS Total_Distinct_Subscribers
FROM userprofiles AS A
FULL OUTER JOIN viewership AS B ON A.UserID = B.UserID0
GROUP BY 1
ORDER BY Total_Distinct_Subscribers DESC;



----------------------------------------------------------------------------------------
----- Total streams for the days of the week
----------------------------------------------------------------------------------------

SELECT 
    DAYNAME(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) AS Day_of_Week,
    COUNT(UserID0) AS Total_Streams,
    ROUND(SUM(HOUR(Duration2) * 3600 + MINUTE(Duration2) * 60 + SECOND(Duration2)) / 60, 2) AS Total_Minutes
FROM viewership
GROUP BY 1, DAYOFWEEK(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg'))
ORDER BY DAYOFWEEK(FROM_UTC_TIMESTAMP(RecordDate2, 'Africa/Johannesburg')) ASC;


------------------------------------------------------------------------------------------

