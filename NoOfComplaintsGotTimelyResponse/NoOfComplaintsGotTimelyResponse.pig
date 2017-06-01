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

-- filter by timely response from relation
TIMELY_RESPONSE_STAGING = filter CONSUMER_COMPLAINTS by timelyresponse == 'Yes';

-- grouping by timelyresponse
TIMELY_RESPONSE_GROUP = GROUP TIMELY_RESPONSE_STAGING by timelyresponse;

-- count all timely response
TIMELY_RESPONSE = foreach TIMELY_RESPONSE_GROUP generate group as timelyresponse, COUNT(TIMELY_RESPONSE_STAGING);

-- dumping result
dump TIMELY_RESPONSE;

-- storing the results
store TIMELY_RESPONSE into '/flume_data/timelyresponse';
