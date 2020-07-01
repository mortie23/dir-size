-- Author:  Christopher Mortimer
-- Date:    2020-07-01
-- Desc:    Views for getting info on directory usage

-- View for the directories
REPLACE VIEW PRD_ADS_HWD_WDAPGRP_DB.DIR_SIZE_DIR_V AS
SELECT
  ID_COL 
  , DIR_CONCAT 
  , T.JSON_DATA.JSONEXTRACTVALUE('$.dirs') AS dirs
  , T.JSON_DATA.JSONEXTRACTVALUE('$.numsep') AS numsep
  , T.JSON_DATA.JSONEXTRACTVALUE('$.directory') AS directory
  , T.JSON_DATA.JSONEXTRACTVALUE('$.bytes') AS size_bytes
  , T.JSON_DATA.JSONEXTRACTVALUE('$.files') AS files
FROM PRD_ADS_HWD_WDAPGRP_DB.DIR_SIZE T
;

-- View for the files
REPLACE VIEW PRD_ADS_HWD_WDAPGRP_DB.DIR_SIZE_FILE_V AS
SELECT 
  T1.ID_UNIQUE
  , T2.ID_COL
  , T2.DIR_CONCAT
  , TRIM(T1.FILE_NAME) AS FILE_NAME
  , TRIM(T1.FILE_EXT) AS FILE_EXT
  , T1.FILE_SIZE_BYTES
  , T1.FILE_OWNER
  , CAST(T1.FILE_DATETIME AS TIMESTAMP WITH TIME ZONE) AS FILE_DATETIME
FROM 
  JSON_TABLE (
  ON (
    SELECT 
      ID_COL||','||DIR_CONCAT
      , JSON_DATA
    FROM 
      PRD_ADS_HWD_WDAPGRP_DB.DIR_SIZE 
   )
  USING 
    ROWEXPR('$.fileset[*]')
    colexpr('[ 
      { "jsonpath" : "$.name","type" : "CHAR(1000)"}
      , {"jsonpath" : "$.ext","type" : "CHAR(5)"}
      , {"jsonpath" : "$.size","type" : "BIGINT"}
      , {"jsonpath" : "$.owner","type" : "VARCHAR(50)"}
      , {"jsonpath" : "$.datetime","type" : "VARCHAR(100)"
      }]'
    )
) AS T1 (
  ID_UNIQUE
  , FILE_NAME
  , FILE_EXT
  , FILE_SIZE_BYTES
  , FILE_OWNER
  , FILE_DATETIME
)
LEFT JOIN (
	SELECT
	  ID_COL||','||DIR_CONCAT AS ID_UNIQUE
	  , ID_COL
	  , DIR_CONCAT
	FROM
	  PRD_ADS_HWD_WDAPGRP_DB.DIR_SIZE
) AS T2
ON T1.ID_UNIQUE=T2.ID_UNIQUE
;
