--Lonnie Lester--

--Displays Username and lowest Rating ever left
select a.username,
min(b.rating) as lowest_rating_given
from userbase a,
    reviews b
    group by a.username;


--Displays UserID, Email, Security Question and Answer.
SELECT 
  a.userID,
  a.email,
  b.question,
  b.answer
FROM userbase a
JOIN securityquestion b ON a.userID = b.userID;

--Displays FirstName, Email, and Walletfunds of users without a wishlist.
SELECT 
  a.FIRSTNAME,
  a.EMAIL,
  a.WALLETFUNDS
FROM USERBASE a
WHERE a.USERID NOT IN (
  SELECT DISTINCT USERID
  FROM WISHLIST
);


--Displays Usernames and total number of ordered products
SELECT 
  a.USERNAME,
  count (b.orderID) as total_orders
FROM USERBASE a
 JOIN ORDERS b on a.userID = b.userID
 group by a.USERNAME;




--Displays Age of Any user who has ordered a product in the last 6 months.
SELECT 
  a.USERID,
  TRUNC(MONTHS_BETWEEN(SYSDATE, a.BIRTHDAY) / 12) AS AGE
FROM USERBASE a
WHERE a.USERID IN (
  SELECT DISTINCT b.USERID
  FROM ORDERS b
  WHERE b.PurchaseDate >= ADD_MONTHS(SYSDATE, -6)
);

--Displays Username and Birthday for Userwith the highest amount of friends
SELECT 
  a.USERNAME,
  a.BIRTHDAY,
  count(b.friendID) as NUMBER_OF_FRIENDS
FROM USERBASE a
JOIN FriendsList b ON a.USERID = b.USERID
group by USERNAME, BIRTHDAY
order by number_of_Friends desc
FETCH FIRST 1 ROWS ONLY;


--Displays ProductName, ReleaseDate, Price, and Description for any product found on a WishList
SELECT 
 DISTINCT a.PRODUCTNAME,
  a.RELEASEDATE,
  a.PRICE,
  a.DESCRIPTION
FROM PRODUCTLIST a
JOIN WISHLIST b ON a.PRODUCTCODE = b.PRODUCTCODE;



--Display the PRODUCTNAME, highest RATING, and number of reviews for each product in the REVIEWS table. Order the results in descending order of the RATING.
SELECT 
 a.PRODUCTNAME,
  max(b.rating) AS MAX_REVIEW_SCORE,
  count(b.review) AS NUMBER_OF_REVIEWS

FROM PRODUCTLIST a
JOIN REVIEWS b ON a.PRODUCTCODE = b.PRODUCTCODE
group by a.PRODUCTNAME
order by MAX_REVIEW_SCORE desc;


--Creates a view that displays the PRODUCTNAME, GENRE, and RATING for every product with a 5 or a 1 RATING. Order the results in ascending order of the RATING.
CREATE OR REPLACE VIEW ProductRatings_View AS
SELECT 
  a.PRODUCTNAME,
  a.GENRE,
  b.RATING
FROM PRODUCTLIST a
JOIN REVIEWS b ON a.PRODUCTCODE = b.PRODUCTCODE
WHERE b.RATING IN (1, 5)
ORDER BY b.RATING ASC;



--Display the count of products ordered, grouped by GENRE. Order the results in alphabetical order of GENRE.
SELECT 
  a.GENRE,
  COUNT(*) AS total_products_ordered
FROM ORDERS b
JOIN PRODUCTLIST a ON b.PRODUCTCODE = a.PRODUCTCODE
GROUP BY a.GENRE
ORDER BY a.GENRE ASC;


--Creates a view that displays each PUBLISHER, the average PRICE, and the sum of HOURSPLAYED for their products.
CREATE OR REPLACE VIEW PublisherStats AS
SELECT
  a.PUBLISHER,
  AVG(a.PRICE) AS average_price,
  SUM(b.HOURSPLAYED) AS total_hours_played
FROM PRODUCTLIST a
JOIN USERLIBRARY b ON a.PRO

--Displays the sum of money spent on products and their corresponding PUBLISHER, from the ORDERS table. 
SELECT 
  a.PUBLISHER,
  SUM(b.PRICE) AS total_spent
FROM ORDERS b
JOIN PRODUCTLIST a ON b.PRODUCTCODE = a.PRODUCTCODE
GROUP BY a.PUBLISHER
ORDER BY total_spent DESC;


--Display the TICKETID, USERNAME, EMAIL, and ISSUE only for tickets with a STATUS of ‘NEW’ or ‘IN PROGRESS’
 SELECT 
  a.TICKETID,
  b.USERNAME,
  b.EMAIL,
  a.ISSUE
FROM USERSUPPORT a
JOIN USERBASE b ON a.email = b.email
WHERE a.STATUS IN ('NEW', 'IN PROGRESS')
ORDER BY a.DATEUPDATED DESC;


--Displays the USERNAME and count of TICKETID that users have submitted for user support.
SELECT 
    b.USERNAME, 
    COUNT(a.TICKETID) AS Ticket_Count
FROM 
    USERSUPPORT a
JOIN 
    USERBASE b ON a.EMAIL = b.EMAIL
GROUP BY 
    b.USERNAME;


--Displays the USERID and EMAIL of any user who has submitted a support ticket that used their FIRSTNAME, LASTNAME, or combination of the two in their EMAIL address.
SELECT DISTINCT b.USERID, b.EMAIL
FROM USERSUPPORT a
JOIN USERBASE b ON a.EMAIL = b.EMAIL
WHERE 
    LOWER(b.EMAIL) LIKE '%' || LOWER(b.FIRSTNAME) || '%'
    OR LOWER(b.EMAIL) LIKE '%' || LOWER(b.LASTNAME) || '%'
    OR LOWER(b.EMAIL) LIKE '%' || LOWER(b.FIRSTNAME || b.LASTNAME) || '%';



--Displays the EMAIL address of any user who has a ‘NEW’ or ‘IN PROGRESS’ support ticket STATUS, where the EMAIL is not currently saved in the USERBASE table.
SELECT DISTINCT a.EMAIL
FROM USERSUPPORT a
WHERE 
    UPPER(a.STATUS) IN ('NEW', 'IN PROGRESS')
    AND a.EMAIL NOT IN (
        SELECT b.EMAIL
        FROM USERBASE b
    );


--Displays the TICKETID, FIRSTNAME, LASTNAME, and USERNAME of any user whose USERNAME is mentioned in the ISSUE of a support ticket.
SELECT 
    a.TICKETID,
    b.FIRSTNAME,
    b.LASTNAME,
    b.USERNAME
FROM 
    USERSUPPORT a
JOIN 
    USERBASE b ON a.EMAIL = b.EMAIL
WHERE 
    LOWER(a.ISSUE) LIKE '%' || LOWER(b.USERNAME) || '%';


    --Displays the USERNAME and PASSWORD associated with the EMAIL address provided in the support tickets.
SELECT 
    b.USERNAME, 
    b.PASSWORD
FROM 
    USERBASE b
JOIN 
    USERSUPPORT a ON b.EMAIL = a.EMAIL;


--Creates a view that displays the USERNAME, DATEASSIGNED, and PENALTY for any user whose PENALTY is not null and the infraction was assigned within the last month.
CREATE OR REPLACE VIEW RecentUserPenalties AS
SELECT 
    b.USERNAME, 
    a.DATEASSIGNED, 
    a.PENALTY
FROM 
    INFRACTIONS a
JOIN 
    USERBASE b ON a.USERID = b.USERID
WHERE 
    a.PENALTY IS NOT NULL
    AND a.DATEASSIGNED >= ADD_MONTHS(SYSDATE, -1);



--Displays the USERNAME and EMAIL of any user who is at least 18 years old and has not received an infraction within the last 4 months.
SELECT a.USERNAME, a.EMAIL
FROM USERBASE a
WHERE 
    TRUNC(MONTHS_BETWEEN(SYSDATE, a.BIRTHDAY) / 12) >= 18
    AND NOT EXISTS (
        SELECT 1 
        FROM INFRACTIONS b
        WHERE b.USERID = a.USERID
          AND b.DATEASSIGNED >= ADD_MONTHS(SYSDATE, -4)
    );



--Displays the USERNAME, DATEASSIGNED, and full guideline name (RULENUM and TITLE with a blank space inbetween) for any user who has violated the community rules.
SELECT 
    a.USERNAME,
    b.DATEASSIGNED,
    b.RULENUM || ' ' || ':' ||  c.TITLE AS FullGuidelineName
FROM 
    INFRACTIONS b
JOIN 
    USERBASE a ON b.USERID = a.USERID
JOIN 
    COMMUNITYRULES c ON b.RULENUM = c.RULENUM;
 
--Displays the USERID, USERNAME, EMAIL, and sum of all SEVERITYPOINTS each user has received.
SELECT 
    a.USERID,
    a.USERNAME,
    a.EMAIL,
    NVL(SUM(c.SEVERITYPOINT), 0) AS TotalSeverityPoints
FROM 
    USERBASE a
LEFT JOIN 
    INFRACTIONS b ON a.USERID = b.USERID
LEFT JOIN 
    COMMUNITYRULES c ON b.RULENUM = c.RULENUM
GROUP BY 
    a.USERID,
    a.USERNAME,
    a.EMAIL;



--Displays the TITLE, DESCRIPTION, and PENALTY for all infractions assigned.
SELECT 
    a.TITLE,
    a.DESCRIPTION,
    b.PENALTY
FROM 
    INFRACTIONS b
JOIN 
    COMMUNITYRULES a ON b.RULENUM = a.RULENUM;


--Displays the USERNAME and count of infractions for users who have violated the community rules at least 15 times.
SELECT 
    a.USERNAME,
    COUNT(*) AS InfractionCount
FROM 
    USERBASE a
JOIN 
    INFRACTIONS b ON a.USERID = b.USERID
GROUP BY 
    a.USERNAME
HAVING 
    COUNT(*) >= 15;






