SELECT DISTINCT t.type AS entity_type,
       t.name AS entity_name,
       'object' AS dependency_type,
       Tab.Col.value('@object', 'varchar(max)') AS dependency_name
FROM   (SELECT name,
               CASE processtype WHEN 'P' THEN 'process' WHEN 'O' THEN 'object' END type,
               CAST(CAST(processxml AS ntext) AS xml) processxml
        FROM   dbo.BPAProcess
        WHERE  name LIKE 'Sales Ops - Copy%') t
CROSS APPLY t.processxml.nodes('(//stage/resource)') AS Tab(Col)