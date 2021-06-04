# Connection to SF

It is often a case when you have to validate the actual Salesforce (SF) data against the raw data exported from SF, some data discrepancies may arise due to the import process errors, absurd SF logic and etc.

You have a choice of different tools (SoqlX,  RazorSQL have built-in SF drivers and you can create a new connection using those drivers and providing your SF credentials => pretty straightforward):

Salesforce Workbench, SoqlX (recommended), RazorSQL, Dbeaver (my personal favorite)*

Or you can use the SF frontend like any other user from your browser.

### SNF connection from Dbeaver

You can use Dbeaver to connect to Snowflake, all instructions on how to connect are to be found here Snowflake JDBC Driver,  from that page navigate further to Snowflake driver integration and configuration. The process is rather simple and can be extended to the number of SQL clients and IDEs: SQL/J Workbench, SQuirrel, Eclipse and so on.

### SF connection from Dbeaver

Besides that, Dbeaver provides you an option to connect your client to SF, there are different SF driver versions out there: Reliersoft Salesforce Driver (recommended), CData JDBC Driver (finicky and unstable), there are more, haven`t tested those. SF drivers are provided in the form of jar files.

1. Open Dbeaver, go to “Database” expanding menu in the Menu Bar, click “Driver Manager,” in the new window (see screenshot) click “New” - ignore the two SF Driver records in the screenshot, those are SF drivers i have added manually - you should have at least one of them after completing the steps described here.

2. In the Drivers Name field enter any name you wish. Click Add File button and locate the driver you have downloaded (jar file) on your computer. 

3. Click the “Find Class Path” button, and it will be generated automatically. You should see “com.reliersoft.sforce.jdbc.Driver” in the Class Name and Extra Class Name fields.

4. In the “URL Template” field, enter “jdbc:sforce://login.salesforce.com” and click OK. - You have created a new custom driver and now it is in the list of available drivers.

5. Create New connection, select the driver name you have just created, and enter your Salesforce User Name and Password followed by a security token to be found in 1password Salesforce record. The password field should look like <password><security token> without any spaces or colons.

6. Click Test Connection to see if you have succeeded, if  no error messages pop up, click OK to connect to Salesforce. Once successfully connected, Salesforce connection will be shown in the explorer window - double click to start using it.

7. Give yourself a pat on the back - You are incredible!!!

