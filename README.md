# About
This contribution is a cooperation between Datto and myself, we both agreed to make this a community project.  The PowerShell scripts will allow you to pull data from Datto RMM and store it in a database, making it possible to create historical dashboards or reports in PowerBI.
# Prerequisites
## SQL
You'll need a Microsoft SQL Server to store the Datto RMM data.  You can download [Microsoft SQL Express](https://www.microsoft.com/en-gb/sql-server/sql-server-downloads) for testing.  Store the SQL credentials in the provide registry import file.
## API
You'll need to create API keys to run the PowerShell scripts.  Find more information how to create API keys in the [Datto Online Help](https://help.aem.autotask.net/en/Content/2SETUP/APIv2.htm).  Store the API keys in the provide registry file.
# Scripts
## Create SQL Tables
You only need to run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLTables.ps1) once.  Alternatively run the [query](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLTables.sql) directly in SQL to create the tables in the database. I decided to create a simple database [schema](https://github.com/aaronengels/DrmmToPowerBI/blob/main/SQLTables.jpg) that can be used easly to create dashboards and reports in Microsoft PowerBI.
## Create SQL Procedures
You only need to run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLProcedures.ps1) once.  Alternatively run the [query](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLProcedures.sql) directly in SQL to create the procedures in the database. These SQL procedures will be used to update the tables in the database.
## Update SQL Tables





