DECLARE @dependencies TABLE
  (entity_type     VARCHAR(128),
   entity_name     VARCHAR(128),
   dependency_type VARCHAR(128),
   dependency_name VARCHAR(128),
   checked         BIT)
DECLARE @parent_name VARCHAR(128)
DECLARE @parent_type VARCHAR(128)
DECLARE @count       INT
--
SET @parent_name = 'Sales Ops - Copy Documents'
SET @parent_type = 'process'
SET @count = 0
--
WHILE @parent_name IS NOT NULL
BEGIN
   --
   -- Add new dependencies to the table, marking as unchecked
   INSERT INTO @dependencies
   SELECT DISTINCT t.type                          AS entity_type,
          t.name                                   AS entity_name,
          'object'                                 AS dependency_type,
          Tab.Col.value('@object', 'VARCHAR(MAX)') AS dependency_name,
          0                                        AS checked
   FROM   (SELECT name,
                  CASE processtype WHEN 'P' THEN 'process' WHEN 'O' THEN 'object' END type,
                  CAST(CAST(processxml AS NTEXT) AS XML) processxml
           FROM   dbo.BPAProcess
           WHERE  name = @parent_name) t
   CROSS APPLY t.processxml.nodes('(//stage/resource)') AS Tab(Col)
   --
   --
   -- add check to only insert rows that do not already exist
   --
   --
   --
   -- Mark this dependency as checked for dependents
   UPDATE @dependencies
   SET    checked = 1
   WHERE  dependency_name = @parent_name
   AND    dependency_type = @parent_type
   --
   -- Get the next unchecked dependent
   SELECT TOP(1)
          @parent_name = dependency_name,
          @parent_type = dependency_type
   FROM   @dependencies
   WHERE  dependency_type IN ('process','object')
   AND    checked          = 0
   --
   -- Stop when all dependents have been checked
   IF @@ROWCOUNT = 0
   OR @count     = 100
   BEGIN
      --
      SET @parent_name = NULL
      SET @parent_type = NULL
   --
   END
   --
   SET @count = @count+1
--
END
--
-- Output results
SELECT *
FROM   @dependencies


-- Add name/type to temp table

-- Loop table for unchecked entries

-- Get XML of unchecked entry

-- Look for depenencies in XML

-- Add dependencies to temp table, if not already present
-- and if process or object, mark as unchecked

-- Continue loop