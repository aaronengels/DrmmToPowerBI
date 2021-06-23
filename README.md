# About
This contribution is a cooperation between Datto and myself, we both agreed to make this a community project.  The PowerShell scripts will allow you to pull data from Datto RMM and store it in a database, making it possible to create historical dashboards or reports in PowerBI.
# Prerequisites
## SQL
You'll need a Microsoft SQL Server to store the Datto RMM data.  You can download [Microsoft SQL Express](https://www.microsoft.com/en-gb/sql-server/sql-server-downloads) for testing.  Store the SQL credentials in the provide registry import file.
## API
You'll need to create API keys to run the PowerShell scripts.  Find more information how to create API keys in the [Datto Online Help](https://help.aem.autotask.net/en/Content/2SETUP/APIv2.htm).  Store the API keys in the provide registry file.
## PowerShell
You'll need to install the [SqlServer PowerShell Module](https://www.powershellgallery.com/packages/SqlServer) developed and maintained by Microsoft. You need to install it with the `AllowClobber` flag because of overlaps between SQLPS and SqlServer:
```powershell
Install-Module -Name SqlServer -AllowClobber
```
# Scripts
## Set Config
You only need to run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/Set-Config.ps1) once. It is an interactive script that sets registry values for you based on your input. It also allows you to encrypt your SQL password and Datto RMM API Secret Key so it is not stored in plaintext in the registry. If you do opt to encrypt, this script will provide you with the randomly generated encryption key. In order to run the remaining scripts, you will need to provide that key in the form of the variable `$env:DrmmToPowerBICredentialKey` (this is designed so that you can store the key in the Datto RMM system as a masked account variable and run UpdateSQLTables.ps1 as a component).
## Create SQL Tables
You only need to run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLTables.ps1) once.  Alternatively run the [query](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLTables.sql) directly in SQL to create the tables in the database.  I decided to create a simple database [schema](https://github.com/aaronengels/DrmmToPowerBI/blob/main/SQLTables.jpg) that can be used easly to create dashboards and reports in Microsoft PowerBI.
## Create SQL Procedures
You only need to run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLProcedures.ps1) once.  Alternatively run the [query](https://github.com/aaronengels/DrmmToPowerBI/blob/main/CreateSQLProcedures.sql) directly in SQL to create the procedures in the database.  These SQL procedures will be used to update the tables in the database.
## Update SQL Tables
Run this [script](https://github.com/aaronengels/DrmmToPowerBI/blob/main/UpdateSQLTables.ps1) to collect data from Datto RMM and store it in the SQL tables.  It will first load the data into temp tables, and then merge the data with the live data.  This will avoid data corruption or duplication when the script fails to run.  You can create a Datto RMM component to excute the script daily, which is the recommended interval, reducing storage.
# SQL Tables
Documentation comming soon :slightly_smiling_face:




