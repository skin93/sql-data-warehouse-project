/*

==========================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==========================================

Script Purpose:

    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncate the bronze tables from loading data.
    - Use the 'COPY' command to load data from csv files to bronze tables.

Parameters:

    This stored procedure does not accept any parameters or return any values.

Usage Example:

    CALL bronze.load_bronze();

*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_start_time TIMESTAMP; 
    v_end_time TIMESTAMP; 
    v_batch_start_time TIMESTAMP; 
    v_batch_end_time TIMESTAMP;
    v_csv_path TEXT := 'YOUR_PATH_TO_THE_FILES'; 
BEGIN
    v_batch_start_time := clock_timestamp();

    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '=============================================';

    ---------------------------------------------
    -- CRM Tables
    ---------------------------------------------
    RAISE NOTICE '---------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '---------------------------------------------';

    -- Table: bronze.crm_cust_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.crm_cust_info';
    EXECUTE format('COPY bronze.crm_cust_info FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'cust_info.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    -- Table: bronze.crm_prd_info
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.crm_prd_info';
    EXECUTE format('COPY bronze.crm_prd_info FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'prd_info.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    -- Table: bronze.crm_sales_details
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.crm_sales_details';
    EXECUTE format('COPY bronze.crm_sales_details FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'sales_details.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    ---------------------------------------------
    -- ERP Tables
    ---------------------------------------------
    RAISE NOTICE '---------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '---------------------------------------------';

    -- Table: bronze.erp_loc_a101
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.erp_loc_a101';
    EXECUTE format('COPY bronze.erp_loc_a101 FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'loc_a101.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    -- Table: bronze.erp_cust_az12
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.erp_cust_az12';
    EXECUTE format('COPY bronze.erp_cust_az12 FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'cust_az12.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    -- Table: bronze.erp_px_cat_g1v2
    v_start_time := clock_timestamp();
    RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    RAISE NOTICE '>> Inserting Data Into Table: bronze.erp_px_cat_g1v2';
    EXECUTE format('COPY bronze.erp_px_cat_g1v2 FROM %L WITH (FORMAT CSV, HEADER true, DELIMITER '','');', v_csv_path || 'px_cat_g1v2.csv');
    
    v_end_time := clock_timestamp();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_batch_end_time := clock_timestamp();
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE '>> Total Load Duration: % seconds', EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time));
    RAISE NOTICE '=============================================';

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
    RAISE NOTICE 'Error Message: %', SQLERRM;
    RAISE NOTICE 'Error Code: %', SQLSTATE;
    RAISE NOTICE '=============================================';
END;
$$;