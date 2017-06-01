-- registering piggybank jar to read csv
REGISTER /usr/local/pig/lib/piggybank.jar;

-- load consumer complaints details into relation
CONSUMER_COMPLAINTS = load '/flume_data/Consumer_Complaints.csv' 
using org.apache.pig.piggybank.storage.CSVExcelStorage(',','NO_MULTILINE','NOCHANGE','SKIP_INPUT_HEADER')
AS  
(datereceived:chararray,
product:chararray,
subproduct:chararray,
issue:chararray,
subissue:chararray,
consumercompliantnarrative:chararray,
companypublicresponse:chararray,
company:chararray,
state:chararray,
zipcode:chararray,
submittedvia:chararray,
datesenttocompany:chararray,
companyresponsetocustomer:chararray,
timelyresponse:chararray,
consumerdisputed:chararray,
complaintid:int);

-- group complaints by company
GROUP_COMPANY_STAGING = GROUP CONSUMER_COMPLAINTS by company;

-- count complaints by company
COMPANY_COMPLAINTS = foreach GROUP_COMPANY_STAGING generate group as company, COUNT(CONSUMER_COMPLAINTS) as complaints;

-- order the results
TOP_COMPANY_COMPLAINTS = ORDER COMPANY_COMPLAINTS by complaints DESC;

-- dump the result
dump TOP_COMPANY_COMPLAINTS;

-- store the result
store TOP_COMPANY_COMPLAINTS into '/flume_data/topcompliantscompany';
