
DROP TABLE IF EXISTS fraud_data;

CREATE TABLE fraud_data (
    transaction_id         INT,
    region                 VARCHAR(50),  -- Added this to match CSV
    protocol_type             VARCHAR(20),  -- This is 'protocol_type' in CSV
    transaction_value_usd  DOUBLE,
    fraud_detected            TINYINT,      -- This is 'fraud_detected' in CSV
    security_level_score   DOUBLE,
    expected_profit_usd    DOUBLE,
    latency_ms             DOUBLE
);

LOAD DATA LOCAL INFILE 'C:/Users/DELL/Downloads/quantum_vs_classical_fraud_dataset.csv'
INTO TABLE fraud_data
FIELDS TERMINATED BY ',' 
-- Removed ENCLOSED BY because your CSV doesn't use quotes
LINES TERMINATED BY '\n' -- Changed from \r\n to \n based on the file content
IGNORE 1 LINES;

-- Check the count immediately
SELECT COUNT(*) AS total_rows FROM fraud_data;
select * from fraud_data
DROP TABLE IF EXISTS fraud_data_copy;

CREATE TABLE fraud_data_copy (
    transaction_id         INT,
    region                 VARCHAR(50),
    protocol_type          VARCHAR(20),
    transaction_value_usd  DOUBLE,
    fraud_detected         TINYINT,
    security_level_score   DOUBLE,
    expected_profit_usd    DOUBLE,
    latency_ms             DOUBLE
);
INSERT INTO fraud_data_copy (
    transaction_id,
    region,
    protocol_type,
    transaction_value_usd,
    fraud_detected,
    security_level_score,
    expected_profit_usd,
    latency_ms
)
SELECT 
    transaction_id,
    region,
    protocol_type,
    transaction_value_usd,
    fraud_detected,
    security_level_score,
    expected_profit_usd,
    latency_ms
FROM fraud_data;
select *, 
row_number() over (Partition by   transaction_id,
    region,
    protocol_type,
    transaction_value_usd,
    fraud_detected,
    security_level_score,
    expected_profit_usd,
    latency_ms) as row_count from fraud_data_copy;

with duplicates_cte as(select *, 
row_number() over (Partition by   transaction_id,
    region,
    protocol_type,
    transaction_value_usd,
    fraud_detected,
    security_level_score,
    expected_profit_usd,
    latency_ms) as row_count from fraud_data_copy)
    select * from duplicates_cte where row_count>1;
    
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE fraud_data_copy
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;
WITH duplicates_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id,
                            region,
                            protocol_type,
                            transaction_value_usd,
                            fraud_detected,
                            security_level_score,
                            expected_profit_usd,
                            latency_ms
               ORDER BY id
           ) AS row_num
    FROM fraud_data_copy
)
DELETE f
FROM fraud_data_copy f
JOIN duplicates_cte d
  ON f.id = d.id
WHERE d.row_num > 1;
ALTER TABLE fraud_data_copy
DROP COLUMN id;
SELECT transaction_id,
       region,
       protocol_type,
       transaction_value_usd,
       fraud_detected,
       security_level_score,
       expected_profit_usd,
       latency_ms,
       COUNT(*) AS duplicate_count
FROM fraud_data_copy
GROUP BY transaction_id,
         region,
         protocol_type,
         transaction_value_usd,
         fraud_detected,
         security_level_score,
         expected_profit_usd,
         latency_ms
HAVING duplicate_count > 1;
-- Step 1: Compute median and store in variable
SET @median := (
    WITH ranked AS (
        SELECT transaction_value_usd,
               ROW_NUMBER() OVER (ORDER BY transaction_value_usd) AS rn_asc,
               ROW_NUMBER() OVER (ORDER BY transaction_value_usd DESC) AS rn_desc
        FROM fraud_data_copy
        WHERE transaction_value_usd IS NOT NULL
    )
    SELECT AVG(transaction_value_usd) AS median_value
    FROM ranked
    WHERE rn_asc = rn_desc OR rn_asc + 1 = rn_desc OR rn_asc = rn_desc + 1
);
-- security_level_score
SET @median := (
    WITH ranked AS (
        SELECT security_level_score,
               ROW_NUMBER() OVER (ORDER BY security_level_score) AS rn_asc,
               ROW_NUMBER() OVER (ORDER BY security_level_score DESC) AS rn_desc
        FROM fraud_data_copy
        WHERE security_level_score IS NOT NULL
    )
    SELECT AVG(security_level_score) AS median_value
    FROM ranked
    WHERE rn_asc = rn_desc OR rn_asc + 1 = rn_desc OR rn_asc = rn_desc + 1
);
UPDATE fraud_data_copy
SET security_level_score = @median
WHERE security_level_score IS NULL;

-- expected_profit_usd
SET @median := (
    WITH ranked AS (
        SELECT expected_profit_usd,
               ROW_NUMBER() OVER (ORDER BY expected_profit_usd) AS rn_asc,
               ROW_NUMBER() OVER (ORDER BY expected_profit_usd DESC) AS rn_desc
        FROM fraud_data_copy
        WHERE expected_profit_usd IS NOT NULL
    )
    SELECT AVG(expected_profit_usd) AS median_value
    FROM ranked
    WHERE rn_asc = rn_desc OR rn_asc + 1 = rn_desc OR rn_asc = rn_desc + 1
);
UPDATE fraud_data_copy
SET expected_profit_usd = @median
WHERE expected_profit_usd IS NULL;

-- latency_ms
SET @median := (
    WITH ranked AS (
        SELECT latency_ms,
               ROW_NUMBER() OVER (ORDER BY latency_ms) AS rn_asc,
               ROW_NUMBER() OVER (ORDER BY latency_ms DESC) AS rn_desc
        FROM fraud_data_copy
        WHERE latency_ms IS NOT NULL
    )
    SELECT AVG(latency_ms) AS median_value
    FROM ranked
    WHERE rn_asc = rn_desc OR rn_asc + 1 = rn_desc OR rn_asc = rn_desc + 1
);
UPDATE fraud_data_copy
SET latency_ms = @median
WHERE latency_ms IS NULL;

-- Step 2: Update NULLs with the median
UPDATE fraud_data_copy
SET transaction_value_usd = @median
WHERE transaction_value_usd IS NULL;

SELECT COUNT(*) AS transaction_value_usd_nulls
FROM fraud_data_copy
WHERE transaction_value_usd IS NULL;

SELECT COUNT(*) AS security_level_score_nulls
FROM fraud_data_copy
WHERE security_level_score IS NULL;

SELECT COUNT(*) AS expected_profit_usd_nulls
FROM fraud_data_copy
WHERE expected_profit_usd IS NULL;

SELECT COUNT(*) AS latency_ms_nulls
FROM fraud_data_copy
WHERE latency_ms IS NULL;

SELECT region
FROM fraud_data_copy
WHERE region IS NOT NULL AND region <> ''
GROUP BY region
ORDER BY COUNT(*) DESC
LIMIT 1;
SELECT protocol_type
FROM fraud_data_copy
WHERE protocol_type IS NOT NULL AND protocol_type <> ''
GROUP BY protocol_type
ORDER BY COUNT(*) DESC
LIMIT 1;
-- Fill missing or empty region
UPDATE fraud_data_copy
SET region = 'North America'
WHERE region IS NULL OR region = '';

-- Fill missing or empty protocol_type
UPDATE fraud_data_copy
SET protocol_type = 'Classical'
WHERE protocol_type IS NULL OR protocol_type = '';

SELECT 
    *
FROM
    fraud_data_copy;

ALTER TABLE fraud_data_copy
DROP COLUMN transaction_value_usd_z,
DROP COLUMN security_level_score_z,
DROP COLUMN expected_profit_usd_z,
DROP COLUMN latency_ms_z;
