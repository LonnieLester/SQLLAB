--Lonnie Lester--

--Displays the USERID of any users who have not made an order--
SELECT a.USERID
FROM USERBASE a
WHERE NOT EXISTS (
    SELECT 1 
    FROM ORDERS b 
    WHERE b.USERID = a.USERID
);


--Displays the PRODUCTCODE of any products that have no reviews.
SELECT a.PRODUCTCODE
FROM PRODUCTLIST a
WHERE NOT EXISTS (
    SELECT 1 
    FROM REVIEWS b 
    WHERE b.PRODUCTCODE = a.PRODUCTCODE
);

--Display all data in the USERBASE table. Show another column that states “Adult” for any user that is at least 18 years old, and “Minor'' for all other users.
SELECT 
    a.*,
    CASE 
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, a.BIRTHDAY) / 12) >= 18 THEN 'Adult'
        ELSE 'Minor'
    END AS AgeGroup
FROM 
    USERBASE a;


--Display all data in the PRODUCTLIST table. Show another column that states “On Sale” for any product that is priced at $20 or less, and “Base Price” for all other products.
SELECT 
    a.*,
    CASE 
        WHEN a.PRICE <= 20 THEN 'On Sale'
        ELSE 'Base Price'
    END AS PriceCategory
FROM 
    PRODUCTLIST a;


--Displays the USERID of any user who has played the product with a PRODUCTCODE of GAME6 and has a user profile image.
SELECT DISTINCT a.USERID
FROM USERBASE a
JOIN USERPROFILE c ON a.USERID = c.USERID
JOIN USERLIBRARY b ON a.USERID = b.USERID
WHERE 
    b.PRODUCTCODE = 'GAME6'
    AND c.IMAGEFILE IS NOT NULL;



--Displays any PRODUCTCODE from the intersect of the WISHLIST and REVIEWS table, where the product is in POSITION 1 or 2, and has a review RATING of 3 or higher.
SELECT DISTINCT a.PRODUCTCODE
FROM WISHLIST a
JOIN REVIEWS b ON a.PRODUCTCODE = b.PRODUCTCODE
WHERE 
    a.POSITION IN (1, 2)
    AND b.RATING >= 3;



--Displays both user’s USERNAME and BIRTHDAY for any users who share the same BIRTHDAY.
SELECT 
    a.USERNAME AS USERNAME1,
    b.USERNAME AS USERNAME2,
    TO_CHAR(a.BIRTHDAY, 'MM-DD') AS SHARED_BIRTHDAY
FROM 
    USERBASE a
JOIN 
    USERBASE b 
    ON TO_CHAR(a.BIRTHDAY, 'MM-DD') = TO_CHAR(b.BIRTHDAY, 'MM-DD')
    AND a.USERID < b.USERID;



--Displays the Cartesian Product of the USERLIBRARY table cross joined with the WISHLIST table.
SELECT *
FROM USERLIBRARY a
CROSS JOIN WISHLIST b;


--Performs a union all on the USERBASE and PRODUCTLIST tables to generate data on all users and products.
SELECT 
    USERID,
    FIRSTNAME,
    LASTNAME,
    USERNAME,
    PASSWORD,
    EMAIL,
    BIRTHDAY,
    WALLETFUNDS,
    NULL AS PRODUCTCODE,
    NULL AS PRODUCTNAME,
    NULL AS PUBLISHER,
    NULL AS GENRE,
    NULL AS RELEASEDATE,
    NULL AS PRICE,
    NULL AS DESCRIPTION
FROM USERBASE

UNION ALL

SELECT 
    NULL AS USERID,
    NULL AS FIRSTNAME,
    NULL AS LASTNAME,
    NULL AS USERNAME,
    NULL AS PASSWORD,
    NULL AS EMAIL,
    NULL AS BIRTHDAY,
    NULL AS WALLETFUNDS,
    PRODUCTCODE,
    PRODUCTNAME,
    PUBLISHER,
    GENRE,
    RELEASEDATE,
    PRICE,
    DESCRIPTION
FROM PRODUCTLIST;

--PerformS a union all on the CHATLOG and USERPROFILE tables to generate data on user activity.
SELECT 
    CHATID,
    RECEIVERID,
    SENDERID,
    DATESENT,
    CONTENT,
    NULL AS USERID,
    NULL AS IMAGEFILE,
    NULL AS DESCRIPTION
FROM CHATLOG

UNION ALL

SELECT 
    NULL AS CHATID,
    NULL AS RECEIVERID,
    NULL AS SENDERID,
    NULL AS DATESENT,
    NULL AS CONTENT,
    USERID,
    IMAGEFILE,
    DESCRIPTION
FROM USERPROFILE;


--Display the USERNAME of all users who have not received an INFRACTION.
SELECT A.USERNAME
FROM USERBASE A
LEFT JOIN INFRACTIONS B ON A.USERID = B.USERID
WHERE B.USERID IS NULL;



--Displays the TITLE and DESCRIPTION of any COMMUNITYRULES that have not been broken.
SELECT a.TITLE, a.DESCRIPTION
FROM COMMUNITYRULES a
WHERE NOT EXISTS (
    SELECT 1
    FROM INFRACTIONS b
    WHERE b.RULENUM = a.RULENUM
);




--Displays the USERNAME and EMAIL of all users who have received a penalty for their INFRACTION.
SELECT DISTINCT UB.USERNAME, UB.EMAIL
FROM USERBASE UB
JOIN INFRACTIONS I ON UB.USERID = I.USERID
WHERE I.PENALTY IS NOT NULL;



--Displays the dates where an INFRACTION was assigned and a USERSUPPORT ticket was submitted on the same day.
SELECT DISTINCT a.DATEASSIGNED
FROM INFRACTIONS a
JOIN USERSUPPORT b ON TRUNC(a.DATEASSIGNED) = TRUNC(b.DATESUBMITTED);




--Displays every COMMUNITYRULES TITLE and PENALTY.
SELECT 
    a.TITLE,
    b.PENALTY
FROM 
    COMMUNITYRULES a
JOIN 
    INFRACTIONS b ON a.RULENUM = b.RULENUM;



--Displays all data in the COMMUNITYRULES table. Show another column that states “Bannable'' for any rule with a 10 or higher SEVERITYPOINT, and “Appealable” for all other rules.
SELECT 
    a.*,
    CASE 
        WHEN a.SEVERITYPOINT >= 10 THEN 'Bannable'
        ELSE 'Appealable'
    END AS RuleCategory
FROM 
    COMMUNITYRULES a;



--Displays all data in the USERSUPPORT table. Show another column that states “High Priority” for any ticket that is not closed and has not been updated in the past week.
SELECT 
    a.*,
    CASE 
        WHEN a.STATUS <> upper('Closed' )
             AND a.DATEUPDATED < SYSDATE - 7 THEN 'High Priority'
        ELSE NULL
    END AS PRIORITY
FROM 
    USERSUPPORT a;




--Displays the Cartesian Product of the USERSUPPORT table cross joined with the INFRACTIONS table.
SELECT *
FROM USERSUPPORT a
CROSS JOIN INFRACTIONS b;



--Displays both TICKETIDs and DATEUPDATED for any support tickets that are ‘CLOSED’ and the last DATEUPDATED was on the same day.
SELECT DISTINCT a.TICKETID, a.DATEUPDATED
FROM USERSUPPORT a
JOIN USERSUPPORT b 
  ON TRUNC(a.DATEUPDATED) = TRUNC(b.DATEUPDATED)
  AND a.TICKETID <> b.TICKETID
WHERE a.STATUS = 'CLOSED' 
  AND b.STATUS = 'CLOSED';




--Performs a union all on the USERBASE and INFRACTIONS tables to generate data on user activity..
SELECT 
    a.USERID,
    a.USERNAME,
    a.EMAIL,
    a.WALLETFUNDS,
    NULL AS RULENUM,
    NULL AS DATEASSIGNED,
    NULL AS PENALTY
FROM USERBASE a

UNION ALL

SELECT 
    b.USERID,
    NULL AS USERNAME,
    NULL AS EMAIL,
    NULL AS WALLETFUNDS,
    b.RULENUM,
    b.DATEASSIGNED,
    b.PENALTY
FROM INFRACTIONS b;







