Use OnlineShoppers;

Select *
From rates;


ALTER TABLE rates
ADD Revenu Varchar(10);

UPDATE rates
SET Revenu = CASE WHEN Revenue = 1 THEN 'TRUE' ELSE 'FALSE' END;

ALTER TABLE rates
ADD Wknd Varchar(10);

UPDATE rates
SET Wknd = CASE WHEN Weekend = 1 THEN 'TRUE' ELSE 'FALSE' END;

/* Hi Brial,
Can you provide me with: The most viewed pages, sessions to revenue generation and 
average page value,bounce rate, exit rate */

Select rt.Revenu, COUNT(rt.Revenu) as Revenue_Generating_Sessions,
	   SUM(pg.Administrative) as Administrative_views, SUM(pg.Informational) as Informational_views, 
	   SUM(pg.ProductRelated) as ProductRelated_views, Round(AVG(rt.PageValues),4) as AVG_Page_value,
	   Round(AVG(rt.BounceRates),4) as AVG_Bounce_rate, ROund(AVG(rt.ExitRates),4) as AVG_Exit_rate 	     
From pageviews pg
	JOIN rates rt 
		ON rt.CustomerID=pg.CustomerID
Group by rt.Revenu
Order by Revenue_Generating_Sessions ASC;

/* Based on the previous analysis,
can you help me with a Breakdown of pageviews by visitor type. How many visitors visit on weekends? */

Select Distinct(rt.VisitorType),
	   SUM(pg.Administrative) as Administrative_views, SUM(pg.Informational) as Informational_views, 
	   SUM(pg.ProductRelated) as ProductRelated_views,
	   Count(CASE WHEN WKnd= 'TRUE' THEN rt.CustomerID ElSE NULL END) as Weekend_visitors,
	   Count(CASE WHEN WKnd= 'FALSE' THEN rt.CustomerID ELSE NULL END) as Non_Weekend_visitors,
	   Count(CASE WHEN WKnd= 'TRUE' THEN rt.CustomerID ElSE NULL END)  +
	   Count(CASE WHEN WKnd= 'FALSE' THEN rt.CustomerID ELSE NULL END) as Total_visitors
From pageviews pg
	JOIN rates rt 
		ON rt.CustomerID=pg.CustomerID
Group by rt.VisitorType
Order by 4 DESC;


/* Breakdown of Average Duration on the pageviews */

Select rt.Revenu, Round(AVG(pg.ProductRelated_Duration),2) as AVG_ProductR_Duration,
	 Round(AVG (pg.Administrative_Duration),2) as AVG_Admin_Duration, Round(AVG(pg.Informational_Duration),2) as AVG_Info_Duration 
From pageviews pg
	INNER JOIN rates rt ON rt.CustomerID=pg.CustomerID
	--Where rt.Revenu= 'TRUE'
Group by rt.Revenu
Order by 2 DESC;


/* Good day Brial,
Can you help me with a Breakdown of Revenue Sessions by Month and Weekend */

Select Distinct(Month),
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) as Revenue_Generating_Sessions,
	Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) as Non_Revenue_Generating_Sessions,
	Count(CASE WHEN WKnd= 'TRUE' THEN CustomerID ElSE NULL END) as Weekends_Revenue_Sessions,
	Count(CASE WHEN WKnd= 'FALSE' THEN CustomerID ELSE NULL END) as Weekends_Non_Revenue_Sessions,
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) + Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) 
	as Total_Sessions		
From rates 
Group by Month
Order by 2 DESC;


/* View of Revenue by Month and Weekend */

CREATE VIEW  Revenue_by_Months AS
Select Distinct(Month),
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) as Revenue_Generating_Sessions,
	Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) as Non_Revenue_Generating_Sessions,
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) + Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) 
	as Total_Sessions,
	Count(CASE WHEN WKnd= 'TRUE' THEN CustomerID ElSE NULL END) as Weekends_Revenue_Sessions,
	Count(CASE WHEN WKnd= 'FALSE' THEN CustomerID ELSE NULL END) as Weekends_Non_Revenue_Sessions		
From rates 
Group by Month, Wknd
--Order by 2 DESC;

/* Hi Brial,
I would like to see how many visitors do we have by month. 
Would be great if you break the metrics by visitor type */

Select Distinct(Month),
	Count(Distinct Case When VisitorType='Returning_Visitor' Then CustomerID ELSE NULL END) as No_of_ReturningVisitors,
	Count(Distinct Case When VisitorType='New_Visitor' Then CustomerID ELSE NULL END) as No_of_NewVisitors,
	Count(Distinct Case When VisitorType='Other' Then CustomerID ELSE NULL END) as No_of_OtherVisitors
From rates
Group by Month
Order by No_of_ReturningVisitors DESC;

/* Hi Brial,
Can We have a breakdown of  revenue generating sessions by  visitor type. 
Would also want to see the average bounce rate,page value and exit rate if possible */

Select Distinct(VisitorType),
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) as Revenue_Generating_Sessions,
	Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) as Non_Revenue_Generating_Sessions,
	Round(AVG(PageValues),2) as AVG_Page_value,Round(AVG(BounceRates),2) as AVG_Bounce_rate, 
	ROund(AVG(ExitRates),2) as AVG_Exit_rate,
	Count(CASE WHEN Revenu= 'TRUE' THEN CustomerID ElSE NULL END) + Count(CASE WHEN Revenu= 'FALSE' THEN CustomerID ELSE NULL END) 
	as Total_Sessions
From rates
Group by VisitorType;




