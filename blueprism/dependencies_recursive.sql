WITH dependencies AS
  (SELECT parent.name,
          CAST(CASE parent.processtype WHEN 'P' THEN 'process' WHEN 'O' THEN 'object' END AS varchar) type,
          1 AS level
   FROM   dbo.BPAProcess AS parent
   WHERE  parent.name = 'Sales Ops - Copy Documents'

   UNION ALL

   SELECT child.name,
          child.type,
          dependencies.level+1
   FROM   (SELECT Tab.Col.value('@object', 'varchar(128)') AS name,
                  CAST('object' AS varchar) AS type
           FROM   (SELECT name,
                          CAST(CAST(processxml AS ntext) AS xml) processxml
                   FROM   dbo.BPAProcess
                   -- Problem here! Need to reference the parent, to get the XML,
                   -- but it's hidden in the other UNIONed SELECT.
                   -- Cannot hard code the parent, as that breaks the recursion!
                   WHERE  name = parent.name) t
           CROSS APPLY t.processxml.nodes('(//stage/resource)') AS Tab(Col)) AS child
   
   INNER JOIN dependencies
   ON         child.name = dependencies.name
  )
SELECT *
FROM   dependencies;