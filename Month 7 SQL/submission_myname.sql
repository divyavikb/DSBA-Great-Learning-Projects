
use new_wheels1;   /* Using new_wheels database*/


-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
SELECT     STATE                                                AS State
				 ,COUNT(DISTINCT CUSTOMER_ID) AS 'Number of Customers in the State'  /*Count of Customers-*/
FROM CUSTOMER_T
GROUP BY STATE                                                                                                                /*Grouping of customers by state*/
ORDER BY COUNT(CUSTOMER_ID) DESC;                                                                       /*Ordering the COUNT of customers in descending order*/

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. */

WITH RATING AS                                                                                                                 /*Writing a CTE RATING to assign numbers to  the ratings*/
 (
        SELECT QUARTER_NUMBER,                                                                                         
        CASE 
		WHEN CUSTOMER_FEEDBACK = 'Very Bad'        THEN '1'                                            
        WHEN CUSTOMER_FEEDBACK = 'Bad'                THEN '2'
        WHEN CUSTOMER_FEEDBACK = 'Okay'              THEN '3'
        WHEN CUSTOMER_FEEDBACK = 'Good'              THEN '4'
        WHEN CUSTOMER_FEEDBACK = 'Very Good'      THEN '5'
        END AS RATING_COUNT
 FROM
 ORDER_T
)  
SELECT
       QUARTER_NUMBER                           AS 'Quarter Number' ,
       ROUND(AVG(RATING_COUNT),3)   AS 'Average rating per quarter'                          /*Average rating after grouping the quarter */
FROM RATING
GROUP BY QUARTER_NUMBER                                                                     /* grouping BY quarter */
ORDER BY QUARTER_NUMBER;                                                                    /* Ordering  BY quarter */




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.*/
      
WITH  COUNT_FEEDBACK AS                                                                                                         /*Creating a CTE  with name COUNT_FEEDBACK to  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter*/
(
    SELECT       QUARTER_NUMBER            
        ,               CUSTOMER_FEEDBACK         
		,               COUNT(CUSTOMER_FEEDBACK)  AS FEEDBACK_COUNTS_PER_QUARTER
    FROM          ORDER_T 
    GROUP BY  QUARTER_NUMBER,CUSTOMER_FEEDBACK
	ORDER BY  QUARTER_NUMBER
)
SELECT                                                                                                                                          /*Writing a query to find out the percentage of different types of customer feedback in each quarter using above CTE */
         QUARTER_NUMBER  
       , CUSTOMER_FEEDBACK
       , (FEEDBACK_COUNTS_PER_QUARTER/(sum(FEEDBACK_COUNTS_PER_QUARTER) OVER (partition BY QUARTER_NUMBER))*100) AS 'PERCENTAGE OF FEEDBACK'
FROM     COUNT_FEEDBACK;



-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT                                                                                                        /*Writing a query to get count of customers for every vehicle maker by joining orders and product tables */
             PRODUCT_T.VEHICLE_MAKER               AS  VEHICLE_MAKER
		   , COUNT(ORDER_T .CUSTOMER_ID)      AS  COUNT_OF_CUSTOMERS
FROM ORDER_T   
JOIN PRODUCT_T  
WHERE ORDER_T.PRODUCT_ID=PRODUCT_T.PRODUCT_ID
GROUP BY VEHICLE_MAKER                                                                      /*grouping by  vehicle manufacturers */
ORDER BY COUNT_OF_CUSTOMERS DESC limit 5;                                /*listing top 5  vehicle manufacturers */


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT STATE, 
              VEHICLE_COUNT , 
              PREFERRED_VEHICLE 
FROM 
     (SELECT                                                                                                     /*Writing a sub-query to get count of vehicle makers  per state r by joining orders , customers and product tables  */
             STATE 
			,COUNT(VEHICLE_MAKER)     AS VEHICLE_COUNT 
            ,VEHICLE_MAKER                 AS PREFERRED_VEHICLE
			,RANK() OVER (PARTITION BY STATE ORDER BY COUNT(VEHICLE_MAKER) DESC) AS RANKING       /*arranging the each vehicle maker counts for each state by rank, with highest vehicle maker count getting rank 1  */
	  FROM CUSTOMER_T 
      INNER JOIN ORDER_T    ON ORDER_T.CUSTOMER_ID = CUSTOMER_T.CUSTOMER_ID
	  INNER JOIN PRODUCT_T  ON ORDER_T.PRODUCT_ID  = PRODUCT_T.PRODUCT_ID
	  GROUP BY STATE , VEHICLE_MAKER) as COUNT_OF_CARS_PER_STATE
WHERE RANKING=1                                                                                                                                                  /*filtering only those vehicle maker by state  rank 1  */
ORDER BY VEHICLE_COUNT DESC;                                                                                                                           /*odrering by vehicle count in descending order  */
    

-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/
SELECT                                                                         
        QUARTER_NUMBER  AS QUARTER_NUMBER
       ,COUNT(ORDER_ID) AS ORDER_COUNT 
FROM ORDER_T 
GROUP BY QUARTER_NUMBER                                                                                                 /*Grouping by quarter and taking count of orders  */
ORDER BY ORDER_COUNT  DESC;
    


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
WITH REVENUE_PER_QUARTER AS    /*  Using CTE REVENUE_PER_QUARTER to compute Revenue per Quarter.Revenue is calculated by reducing discount frorm vehicle price and multiplying the quantities per order */
(
   SELECT  
      QUARTER_NUMBER , 
     sum((VEHICLE_PRICE*(100-DISCOUNT)/100)*QUANTITY) as REVENUE 
   FROM ORDER_T 
   GROUP BY QUARTER_NUMBER
   ORDER BY QUARTER_NUMBER
)
SELECT                                                                                          /*   using above CTE and LAG function to calculate the QoQ percentage change in revenue*/
         QUARTER_NUMBER                              
       , REVENUE                                     AS REVENUE_PER_QUARTER
       , LAG(revenue) OVER (ORDER BY QUARTER_NUMBER) AS PREVIOUS_QUARTER_REVENUE 
	   , ROUND(((REVENUE - LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER))/LAG(REVENUE) OVER(ORDER BY QUARTER_NUMBER) * 100),2) AS ' % CHANGE IN REVENUE '
FROM REVENUE_PER_QUARTER;
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/
SELECT                                                                                                                       
		 QUARTER_NUMBER,COUNT(ORDER_ID)                       AS ORDERS
		,sum((VEHICLE_PRICE*(100-DISCOUNT)/100)*QUANTITY) as REVENUE 
FROM ORDER_T 
GROUP BY QUARTER_NUMBER                                                                                                     /*Grouping  by quarter and taking count of orders  and total revenue.  */
ORDER BY QUARTER_NUMBER;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/
SELECT
     CREDIT_CARD_TYPE,
     ROUND(AVG(DISCOUNT),2) AS  AVERAGE_DISCOUNT  
FROM ORDER_T  
JOIN CUSTOMER_T  
ON ORDER_T.CUSTOMER_ID= CUSTOMER_T.CUSTOMER_ID
GROUP BY CREDIT_CARD_TYPE                                                                           /*Grouping  by credit card type and getting average discount  by joining customers and order tables  */
ORDER BY 2 DESC ;                                                                                               /*Ordering by Average Discount in descending order  */



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT  
        QUARTER_NUMBER                                AS Quarter_Number
       ,ROUND(AVG(DATEDIFF(SHIP_DATE,ORDER_DATE)),2)  AS Average_Shipment_Days        /*Using DATEDIFF function to get difference of order date and shipment date from orders table  */
FROM ORDER_T 
GROUP BY QUARTER_NUMBER                                                                            /*Grouping  by quarter and taking the average of shipment days by getting difference of order date and shipment date from orders table  */
ORDER BY QUARTER_NUMBER;











/*********************************Additional Business Overview Queries***********************************/

/***********Total Revenue*************/
SELECT  
SUM((VEHICLE_PRICE*(100-DISCOUNT)/100)*QUANTITY) AS  "Total Revenue"          /*********************************calculating total revenue using sum() function**********************************/
FROM ORDER_T ;

/***********Total Revenue for Last Quarter*************/
SELECT  QUARTER_NUMBER AS "Quarter Number", 
SUM((VEHICLE_PRICE*(100-DISCOUNT)/100)*QUANTITY) AS  " Revenue this Quarter "          /*********************************calculating revenue using sum() function  and selecting only quarter 4**********************************/
FROM ORDER_T 
WHERE QUARTER_NUMBER=4
GROUP BY QUARTER_NUMBER;

/***********Total Orders*************/
SELECT  
COUNT(ORDER_ID) AS "Total Orders"                                                      /*********************************Calculating Total orders**********************************/
FROM ORDER_T ;

/***********Total Customers*************/
SELECT DISTINCT COUNT(CUSTOMER_ID) AS 'Total Customers '                /*********************************Calculating Total Customers**********************************/
FROM CUSTOMER_T; 

/***********Average days to ship*************/
SELECT  CEIL(AVG(DATEDIFF(SHIP_DATE,ORDER_date)))  AS  "Average Shipment days"   /*********************************Calculating average shipment days using DATEDIFF function*************************/
FROM ORDER_T;           

/***********% of Good Feedback*************/
WITH  FB AS                                                                                                              /*********************************creating CTE with name FB to calculate counts of each type of  feedback *************************/
(
SELECT CUSTOMER_FEEDBACK,
COUNT(CUSTOMER_FEEDBACK) AS COUNT_PER_FEEDBACK
FROM ORDER_T 
GROUP BY CUSTOMER_FEEDBACK
)
SELECT CUSTOMER_FEEDBACK  AS "Customer Feedback",
SUM(COUNT_PER_FEEDBACK/1000*100) AS "Feedback percentage"                 /*********************************using   FB to calculate feedback % of Good and Very  feedback*************************/
 FROM FB
 WHERE CUSTOMER_FEEDBACK  in ( 'Good',"Very Good")
 GROUP BY CUSTOMER_FEEDBACK;

/***********Last Quarters ORDERs *************/                                         
SELECT COUNT(ORDER_ID)        AS "Number of Orders in Last Quarter"                                                                        /******************************** Getting Count of  Last quarter orders************************/
FROM ORDER_T 
WHERE QUARTER_NUMBER=4;

/**********Average Rating**************/
SELECT
             ROUND(AVG(RATING_COUNT),3)   AS 'Average rating '                                          /*Getting Average rating from the Sub Query  */
 FROM (
        SELECT QUARTER_NUMBER,                                                                                         /*Writing a sub-query  FB_CONVERT to return  the rating in numerical values*/
        CASE 
		WHEN CUSTOMER_FEEDBACK = 'Very Bad'        THEN '1'                                            /*Converting the Feedback from Text to Number */
        WHEN CUSTOMER_FEEDBACK = 'Bad'                THEN '2'
        WHEN CUSTOMER_FEEDBACK = 'Okay'              THEN '3'
        WHEN CUSTOMER_FEEDBACK = 'Good'              THEN '4'
        WHEN CUSTOMER_FEEDBACK = 'Very Good'      THEN '5'
        END AS RATING_COUNT
 FROM
 ORDER_T
)  AS FB_CONVERT

 
