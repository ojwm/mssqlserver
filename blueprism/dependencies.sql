-- Find fonts used by objects and/or processes
DECLARE @processXMLs AS TABLE
  (name       varchar(128),
   type       varchar(7),
   processxml xml)
INSERT INTO @processXMLs
  (name,
   type,
   processxml)
  (SELECT name,
          CASE processtype WHEN 'P' THEN 'process' WHEN 'O' THEN 'object' END,
          CAST(CAST(processxml AS ntext) AS xml)
   FROM   dbo.BPAProcess
--   WHERE  name LIKE 'Siebel%')
   WHERE  name LIKE 'GMS - Letter%')

SELECT t.entity_type,
       t.entity_name,
       t.dependency_type,
       CASE LTRIM(RTRIM(t.value)) WHEN '' THEN NULL ELSE t.value END dependency_name
FROM   (SELECT type AS entity_type,
               name AS entity_name,
               'font' AS dependency_type,
               Tab.Col.value('@value', 'varchar(max)') AS value
        FROM   @processXMLs CROSS APPLY processxml.nodes('(//attribute[@name="FontName"]/ProcessValue)') AS Tab(Col)
        UNION
        SELECT type AS entity_type,
               name AS entity_name,
               'font' AS dependency_type,
               Tab.Col.value('@value', 'varchar(max)') AS value
        FROM   @processXMLs CROSS APPLY processxml.nodes('(//argument[id="font"])') AS Tab(Col)
        
        UNION
        SELECT type AS entity_type,
               name AS entity_name,
               'object' AS dependency_type,
               Tab.Col.value('@object', 'varchar(max)') AS value
        FROM   @processXMLs CROSS APPLY processxml.nodes('(//stage/resource)') AS Tab(Col)) t
WHERE  CASE LTRIM(RTRIM(t.value)) WHEN '' THEN NULL ELSE t.value END IS NOT NULL;