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

-- filter only datereceived and datesenttocompany
SAMEDATE_RESPONSE_STAGE = foreach CONSUMER_COMPLAINTS generate datereceived, datesenttocompany;

-- filtering data when datereceived equal to datesenttocompany
SAMEDATE_RESPONSE_STAGING = filter SAMEDATE_RESPONSE_STAGE by (ToDate(datereceived,'MM/dd/yyyy') == ToDate(datesenttocompany,'MM/dd/yyyy'));

--- group the result by datereceived
SAMEDATE_RESPONSE_GROUP = GROUP SAMEDATE_RESPONSE_STAGING by datereceived;

-- count the result above groupped
SAMEDATE_RESPONSE = foreach SAMEDATE_RESPONSE_GROUP generate group as datereceived, COUNT(SAMEDATE_RESPONSE_STAGING);

-- dumping the response
dump SAMEDATE_RESPONSE;

-- storing the result
store SAMEDATE_RESPONSE into '/flume_data/samedateresponse';
