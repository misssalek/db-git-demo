-- Databricks notebook source
-- MAGIC %md 
-- MAGIC ## Extract Data From the Customers JSON File

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 1. Query Single JSON File

-- COMMAND ----------

-- MAGIC %fs ls /Volumes/gizmobox/landing/operational_data/customers/

-- COMMAND ----------

-- MAGIC %md
-- MAGIC # For all syntax we will have first in SQL and then in Python

-- COMMAND ----------

SELECT * FROM json.`/Volumes/gizmobox/landing/operational_data/customers/customers_2024_10.json`

-- COMMAND ----------

-- MAGIC %python 
-- MAGIC # this is if we have a view already created if not we will use df2=spark.read.json('/Volumes/gizmobox/landing/operational_data/customers').display() or more general spark.read.format('json').load('/Volumes/gizmobox/landing/operational_data/customers')
-- MAGIC
-- MAGIC df=spark.sql('select * from gizmobox.bronze.v_customers')
-- MAGIC df.display()
-- MAGIC

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df=spark.read.format('json').load('/Volumes/gizmobox/landing/operational_data/customers')
-- MAGIC df.display()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 4. Select File Metadata

-- COMMAND ----------

SELECT input_file_name() AS file_path, -- Deprecated from Databricks Runtime 13.3 LTS onwards,
       _metadata.file_path AS file_path,
       * 
  FROM json.`/Volumes/gizmobox/landing/operational_data/customers`

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df_with_metadata=df.select("_metadata.file_path").display()

-- COMMAND ----------

-- MAGIC %python
-- MAGIC df_with_metadata = df.select("_metadata.file_path","*")
-- MAGIC df_with_metadata.display()

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 5. Register Files in Unity Catalog using Views

-- COMMAND ----------

CREATE OR REPLACE VIEW gizmobox.bronze.v_customers
AS
SELECT *,
       _metadata.file_path AS file_path 
  FROM json.`/Volumes/gizmobox/landing/operational_data/customers`

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC df_with_metadata.write.format("delta").mode("overwrite").saveAsTable("gizmobox.bronze.py_customers")

-- COMMAND ----------

SELECT * FROM gizmobox.bronze.v_customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 6. Create Temporary View
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TEMPORARY VIEW tv_customers
AS
SELECT *,
       _metadata.file_path AS file_path 
  FROM json.`/Volumes/gizmobox/landing/operational_data/customers`

-- COMMAND ----------

SELECT * FROM tv_customers;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ### 7. Create Global Temporary View

-- COMMAND ----------

CREATE OR REPLACE GLOBAL TEMPORARY VIEW gtv_customers
AS
SELECT *,
       _metadata.file_path AS file_path 
  FROM json.`/Volumes/gizmobox/landing/operational_data/customers`

-- COMMAND ----------

SELECT * FROM global_temp.gtv_customers
