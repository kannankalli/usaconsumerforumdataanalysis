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

-- filter compliants raised year 2015 with product debt collection
DEBT_COLLECTION_STAGING = filter CONSUMER_COMPLAINTS by (GetYear(ToDate(datereceived,'MM/dd/yyyy')) == 2015) AND 
(product == 'Debt collection');

-- grouping by product 
DEBT_COLLECTION_GROUP = GROUP DEBT_COLLECTION_STAGING by product;

-- count debt collection with year 2015
DEBT_COLLECTION = foreach DEBT_COLLECTION_GROUP generate group as product, COUNT(DEBT_COLLECTION_STAGING);

-- dumping result
dump DEBT_COLLECTION;

--store the result
store DEBT_COLLECTION into '/flume_data/debtcollection';
