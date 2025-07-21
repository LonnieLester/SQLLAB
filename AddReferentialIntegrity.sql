--Lonnie Lester--
--Adds FK to Order Table
ALTER TABLE Orders
ADD FOREIGN KEY (USERID) REFERENCES Userbase(USERID);

--Adds FK to Reviews Table
ALTER TABLE Reviews
ADD FOREIGN KEY (USERID) REFERENCES Userbase(USERID);

--Adds FK to UserLibrary Table
ALTER TABLE UserLibrary
ADD FOREIGN KEY (USERID) REFERENCES Userbase(USERID);

--Finds all users > 18 years old and displays full name.
Select FIRSTNAME ||' ' || LASTNAME AS FULL_NAME FROM USERBASE
WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, BIRTHDAY) / 12) >= 18;

--Finds Average CHARACTER LENGTH FOR USERNAME
SELECT trunc(AVG(LENGTH(USERNAME))) AS avg_length
FROM USERBASE;

--Finds Security Questions starting with "What is" or "What was"
SELECT Question
FROM SECURITYQUESTION
where Question like 'What is%' or Question Like 'What was%';

--Displays Product Code, Total Reviews, and Lowest_rating within the Reviews Table.
SELECT ProductCode, count(review) as total_reviews, MIN(rating) as lowest_rating
FROM Reviews
group by ProductCode
order by total_reviews desc;

--Displays Product Code, Total Wishlist, and Lowest_rating within the Wishlist Table.
SELECT ProductCode, count(position) as number_of_1s
FROM Wishlist
where position = 1
group by productcode;

--Displays UserId and total spent
SELECT USERID, sum(price) as Lifetime_Spent
FROM Orders
group by USERID
order by USERID asc;

--Displays total hours played across playerbase and returns only the TOP 5
SELECT ProductCode, sum(hoursplayed) as Total_time_played
FROM UserLibrary
group by ProductCode, hoursplayed
order by hoursplayed desc
FETCH FIRST 5 ROWS ONLY;


--Creates View displaying total infractions commited from users
Create View InfractionCOunt AS
SELECT UserID, count(infractionID) as Total_Infractions
from infractions
group by USERID;




--Creates View displaying total instances of a specific rule violation commited from users
Create View UniqueInfractionCOunt AS
SELECT UserID, count(RuleNum) as Total_Infractions
from infractions
group by USERID;



--Displays how many times a rule as been violated, what the penalty was, and how many times a penalty was given
SELECT Rulenum, penalty, count(penalty) as times_commited
FROM Infractions
group by rulenum, penalty
order by rulenum asc;


--Average Max and Min turnaround time in days from the USERSUPPORT Table
SELECT 
  trunc(AVG(DATEUPDATED - DATESUBMITTED)) AS avg_turnaround_days,
  MAX(DATEUPDATED - DATESUBMITTED) AS max_turnaround_days,
  MIN(DATEUPDATED - DATESUBMITTED) AS min_turnaround_days
FROM USERSUPPORT
WHERE STATUS = 'CLOSED';


--Shows Tickets with NEW as a status and counts times it has came up
SELECT EMAIL, ISSUE, COUNT(*) AS Issue_Submissions, DATESUBMITTED
FROM UserSupport
WHERE STATUS = 'NEW'
Group By Email, Issue, DateSubmitted;


--Shows Users whos password include their first or last name
SELECT UserID
FROM UserBase
WHERE password like firstname or password like lastname;


--Shows Average price of publisher product
SELECT Publisher, avg(price) as average_price_of_product
FROM ProductList
group by publisher
order by publisher asc;


--Creates View that displays Prouct Name and Price for all products with a release date over 5 years. Also takes 25% off the price.
create view Five_Year_Discount as
SELECT ProductName, Price as Original_Price, trunc(price * .75) as New_Discount_price
FROM ProductList
WHERE ReleaseDate < ADD_MONTHS(SYSDATE, -60);


--Shows Min and Max Prices by Genre
Select Genre, min(price) as Minimum_Price, max(price) as Maximum_Price
from ProductList
Group by Genre
order by Genre asc;


--Creates View showing chats from the last 7 days
CREATE VIEW RecentChatLog AS
SELECT *
FROM CHATLOG
WHERE DateSent BETWEEN SYSDATE - 7 AND SYSDATE;

--Creates View showing infractions from the last month where penalty is not null
CREATE VIEW RecentInfractions AS
SELECT USERID, DATEASSIGNED, PENALTY
FROM Infractions
WHERE PENALTY IS NOT NULL
  AND DATEASSIGNED >= ADD_MONTHS(SYSDATE, -1);

