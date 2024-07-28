

------------------------  CASE 1 ------------------------------------------


SELECT [asOfDate]
      ,[mandateId]
      ,SUM([marketValueCad]) AS 'Total Asset'     
	   FROM [IPR].[dbo].[clientPositions] 
	   group by [asOfDate]
			   ,[mandateId]




------------------------  CASE 2 ------------------------------------------


SELECT [asOfDate]
      ,mandateId
	  ,accountID 
      ,SUM([marketValueCad]) AS 'Total Asset'    
	   FROM [IPR].[dbo].[clientPositions] 
         WHERE implementationType = 'segregated'
         group by [asOfDate],[mandateId],accountID





------------------------  CASE 3 ------------------------------------------

SELECT DISTINCT 
	  [asOfDate]
	 ,[mandateId]   
	 ,SUM(CASE WHEN implementationType = 'segregated' THEN [marketValueCad] ELSE 0 END) OVER (PARTITION BY [mandateId] ORDER BY asofDate) 
	 -SUM(CASE WHEN implementationType = 'segregated' THEN [bookValueCad] ELSE 0 END) OVER (PARTITION BY [mandateId] ORDER BY asofDate) as 'Capital gains'
	  FROM [IPR].[dbo].[clientPositions]






------------------------  CASE 4 ------------------------------------------

SELECT DISTINCT 
	   [asOfDate]
	  ,mandateId
	  ,accountId
      ,securityName
	  ,marketValueCad/ sum(marketValueCad) 
		over (PARTITION BY [mandateId] ORDER BY [asOfDate]) as 'mandate weights' 
	  ,marketValueCad/ sum(marketValueCad) 
		over (PARTITION BY [accountId] ORDER BY [mandateId],[asOfDate]) as 'Account weights' 
	  FROM [IPR].[dbo].[clientPositions]






------------------------  CASE 5 ------------------------------------------

SELECT DISTINCT 
				   CP.asOfDate 
				  ,CP.mandateId
				  ,CP.AccountId
				  ,CP.securityName
				  ,CP.marketValueCad/ sum(CP.marketValueCad) over (PARTITION BY CP.modelID ORDER BY CP.[asOfDate])  - MW.modelWeight as 'Weight deviation'
				  ,CP.marketValueCad - CP.bookValueCad as 'Dollar Deviation'
				  from [IPR].[dbo].[clientPositions] CP  JOIN [IPR].[dbo].[modelWeights] MW ON Cp.asOfDate = MW.asOfDate and CP.modelID = MW.modelID AND CP.fmcSecurityId = MW.fmcSecurityId
				  where CP.implementationType = 'segregated'