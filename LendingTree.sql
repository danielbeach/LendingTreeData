CREATE TABLE [dbo].[LendingTree](
	[Loan_Amount] [nvarchar](500) NULL,
	[Funded_Amount] [nvarchar](500) NULL,
	[Funded_Amount_Inv] [nvarchar](500) NULL,
	[Term] [nvarchar](500) NULL,
	[Interest_Rate] [nvarchar](500) NULL,
	[Installment] [nvarchar](500) NULL,
	[Grade] [nvarchar](500) NULL,
	[Home_Ownership] [nvarchar](500) NULL,
	[Annual_Income] [nvarchar](500) NULL,
	[Verification_Status] [nvarchar](500) NULL,
	[Issue_Date] [date] NULL,
	[Loan_Status] [nvarchar](500) NULL,
	[Address_State] [nvarchar](500) NULL,
	[Open_Accounts] [nvarchar](500) NULL,
	[Application_Type] [nvarchar](500) NULL
)

DELETE FROM [Configuration].[dbo].[LendingTree] WHERE Issue_Date = '1900-01-01'
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Loan_Amount BIGINT
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Funded_Amount BIGINT
UPDATE [Configuration].[dbo].[LendingTree]  SET Interest_Rate = REPLACE(Interest_Rate,'%','')
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Interest_Rate DECIMAL(18,2)
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Installment DECIMAL(18,2)
UPDATE [Configuration].[dbo].[LendingTree] SET Annual_Income = 0 WHERE Annual_Income = ''
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Annual_Income DECIMAL(18,2)
ALTER TABLE [Configuration].[dbo].[LendingTree] ALTER COLUMN Open_Accounts Int

CREATE NONCLUSTERED INDEX IDX_LendingTree ON dbo.LendingTree (Issue_Date,Loan_Amount) INCLUDE(Funded_Amount, Interest_Rate,Installment,Home_Ownership,Annual_Income,Address_State,Open_Accounts)

--Loan Amounts by Year
SELECT SUM(Loan_Amount) Total_Loan_Amount,YEAR(Issue_Date) as Year
FROM Configuration.dbo.LendingTree
GROUP BY YEAR(Issue_Date)


--Loan Amounts by Year and Month
SELECT SUM(Loan_Amount) Total_Loan_Amount,YEAR(Issue_Date) as Year,MONTH(Issue_Date) as Month
FROM Configuration.dbo.LendingTree
GROUP BY YEAR(Issue_Date),MONTH(Issue_Date)
ORDER BY YEAR(Issue_Date), MONTH(Issue_Date) ASC

--Running Sum Year over Year by Month
SELECT Year,Month,SUM(Total_Loan_Amount) OVER (PARTITION BY Year ORDER BY Year,Month ASC ROWS UNBOUNDED PRECEDING) as RunningTotalbyYear
FROM (
	SELECT SUM(Loan_Amount) as Total_Loan_Amount,YEAR(Issue_Date) as Year,MONTH(Issue_Date) as Month
	FROM Configuration.dbo.LendingTree
	GROUP BY YEAR(Issue_Date), MONTH(Issue_Date)
	) base
ORDER BY Year,Month

--Avg Loan Size
SELECT AVG(Loan_Amount) Avg_Loan_Amount,YEAR(Issue_Date) Year
FROM [Configuration].[dbo].[LendingTree]
GROUP BY YEAR(Issue_Date)

--Pivot Yr over Yr for Javascript Data Table Consumption
SELECT Month,ISNULL([2007],0)[2017],[2008],[2009],[2010],[2011],[2012],[2013],[2014],[2015],[2016],[2017]
FROM (
	SELECT MONTH(Issue_Date) Month,YEAR(Issue_Date) Year,SUM(Loan_Amount)Loan_Amount
	FROM Configuration.dbo.LendingTree
	GROUP BY MONTH(Issue_Date),YEAR(Issue_Date)
	) pvt
PIVOT (		
		SUM(Loan_Amount) 
		FOR Year IN ([2007],[2008],[2009],[2010],[2011],[2012],[2013],[2014],[2015],[2016],[2017])
	  ) as p


--Rent vs Own
SELECT Home_Ownership, COUNT(*) Number
FROM Configuration.dbo.LendingTree
GROUP BY Home_Ownership
ORDER BY COUNT(*) DESC

--Average Income vs Home Ownership
SELECT Home_Ownership,AVG(Annual_Income) Average_Income
FROM [Configuration].[dbo].[LendingTree]
GROUP BY Home_Ownership
ORDER BY Average_Income DESC

--States with most Total Loans Amounts.
SELECT TOP 10 Address_State,SUM(Loan_Amount) Loan_Amount
FROM [Configuration].[dbo].[LendingTree]
GROUP BY Address_State
ORDER BY Loan_Amount DESC

--States with least Total Loans Amounts.
SELECT TOP 10 Address_State,SUM(Loan_Amount) Loan_Amount
FROM [Configuration].[dbo].[LendingTree]
GROUP BY Address_State
ORDER BY Loan_Amount ASC
