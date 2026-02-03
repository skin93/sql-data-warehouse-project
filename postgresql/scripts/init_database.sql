/*

==========================================
Create Database and Schemas
==========================================

Script Purpose:

    This script creates a new database named "datawarehouse" after checking if it already exists.
    If the database exists, it is dropped an recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver' and 'gold'.

WARNING:

    Ruining this script will drop the entire "datawarehouse" database if it exists.
    All data in the database will be permanently deleted. Proceed with caution and ensure you have proper backups before running this script.

	Before creating schemas, you need to be connected with "datawarehouse" database.
    
*/



DO $$ 
BEGIN
   IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'datawarehouse') THEN
      PERFORM pg_terminate_backend(pid) 
      FROM pg_stat_activity 
      WHERE datname = 'datawarehouse' AND pid <> pg_backend_pid();
      
      DROP DATABASE datawarehouse;
   END IF;
END $$;

CREATE DATABASE datawarehouse;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;