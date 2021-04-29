SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

WITH XMLNAMESPACES   
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')  
SELECT  
        query_plan AS CompleteQueryPlan, 
        n.value('(@StatementText)[1]', 'VARCHAR(4000)') AS StatementText, 
        n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') AS StatementOptimizationLevel, 
        n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') AS StatementSubTreeCost, 
        n.query('.') AS ParallelSubTreeXML,  
        ecp.usecounts, 
        ecp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS ecp 
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS eqp 
CROSS APPLY query_plan.nodes('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') AS qn(n) 
WHERE  n.query('.').exist('//RelOp[@PhysicalOp="Parallelism"]') = 1 

--I look at the high use count plans, and see if there is a missing index associated with those queries that is driving the cost up.  If I can tune the high execution queries to reduce their cost, I have a win either way.  However, if you run this query, you will note that there are some really high cost queries that you may not get below the five value.  If you can fix the high use plans to reduce their cost, and then increase the ‘cost threshold for parallelism’ based on the cost of your larger queries that may benefit from parallelism, having a couple of low use count plans that use parallelism doesn't have as much of an impact to the server overall, at least based on my own personal experiences. 

