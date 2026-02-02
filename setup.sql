-- Run the following statements to create a database, schema, and a table with data loaded from AWS S3.

CREATE DATABASE IF NOT EXISTS DB_QS_CORTEX_AI_FUNCTIONS;
CREATE SCHEMA IF NOT EXISTS SCHEMA_QS_CORTEX_AI_FUNCTIONS;
CREATE WAREHOUSE IF NOT EXISTS WH_QS_CORTEX_AI_FUNCTIONS WAREHOUSE_SIZE=SMALL;

USE DB_QS_CORTEX_AI_FUNCTIONS.SCHEMA_QS_CORTEX_AI_FUNCTIONS;
USE WAREHOUSE WH_QS_CORTEX_AI_FUNCTIONS;
  
create or replace file format csvformat  
  skip_header = 1  
  field_optionally_enclosed_by = '"'  
  type = 'CSV';  

-- Emails table
CREATE OR REPLACE STAGE emails_data_stage  
  file_format = csvformat  
  url = 's3://sfquickstarts/sfguide_getting_started_with_cortex_ai_functions_ja/emails/';  
  
CREATE OR REPLACE TABLE EMAILS (
	USER_ID NUMBER(38,0),
	TICKET_ID NUMBER(18,0),
	CREATED_AT TIMESTAMP_NTZ(9),
	CONTENT VARCHAR(16777216)
);
  
COPY INTO EMAILS  
  from @emails_data_stage;

-- Solutions Center Articles table

CREATE OR REPLACE STAGE sc_articles_data_stage  
  file_format = csvformat  
  url = 's3://sfquickstarts/sfguide_getting_started_with_cortex_ai_functions_ja/sc_articles/';  

CREATE OR REPLACE TABLE SOLUTION_CENTER_ARTICLES (
	ARTICLE_ID VARCHAR(16777216),
	TITLE VARCHAR(16777216),
	SOLUTION VARCHAR(16777216),
	TAGS VARCHAR(16777216)
);

COPY INTO SOLUTION_CENTER_ARTICLES  
  from @sc_articles_data_stage;

-- Run the following statement to create a Snowflake managed internal stage to store the sample image files.
CREATE OR REPLACE STAGE QS_IMAGE_FILES encryption = (TYPE = 'SNOWFLAKE_SSE') directory = ( ENABLE = true );

-- Run the following statement to create a Snowflake managed internal stage to store the sample audio files.
CREATE OR REPLACE STAGE QS_AUDIO_FILES encryption = (TYPE = 'SNOWFLAKE_SSE') directory = ( ENABLE = true );

-- Enable cross-region inference
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';
