```kql
// failed request count by name
let start=datetime("2023-02-20T15:53:00.000Z");
let end=datetime("2023-02-20T23:00:00.000Z");
let timeGrain=1m;

let dataset=requests
    // additional filters can be applied here
    | where timestamp > start and timestamp < end
    | where client_Type != "Browser"
    //| where url startswith 'https://gcp-ew1.api.hmgroup.tech'
;// calculate failed request count for all requests
dataset
| summarize failedCount=sumif(itemCount, success == false) by bin(timestamp, timeGrain)
| extend ["request"]='Overall'
// render result in a chart
| render timechart


let start=datetime("2023-02-20T12:53:00.000Z");
let end=datetime("2023-02-20T23:00:00.000Z");
let timeGrain=1m;
requests
    // additional filters can be applied here
    | where timestamp > start and timestamp < end
    | where client_Type != "Browser"
    | where success == false
    | where url startswith 'https://gcp-ew1.api.hmgroup.tech'
    | where resultCode != 401
    | take 100


// Response time trend 
// Chart request duration over the last 12 hours. 
// To create an alert for this query, click '+ New alert rule'
requests
| where timestamp > ago(30m) 
| where client_Type != "Browser"
| where url startswith 'https://gcp-ew1.api.hmgroup.tech'
| summarize avgRequestDuration=avg(duration) by bin(timestamp, 5s) 
| render timechart


requests
| take 1


// Request count trend 
// Chart Request count over the last day. 
// To create an alert for this query, click '+ New alert rule'
requests
| where timestamp > ago(30m)
| summarize totalCount=sum(itemCount) by bin(timestamp, 1s)
| render timechart



// Request count trend 
// Chart Request count over the last day. 
// To create an alert for this query, click '+ New alert rule'
let start=datetime("2023-02-20T14:35:00.000Z");
let end=datetime("2023-02-20T14:42:00.000Z");
requests
| where timestamp > start and timestamp < end
//| where timestamp > ago(30m)
| where url startswith 'https://gcp-ew1.api.hmgroup.tech'
| summarize totalCount=sum(itemCount) by bin(timestamp, 1s)
| render timechart


let start=datetime("2023-02-21T09:00:00.000Z");
let end=datetime("2023-02-21T17:00:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url !startswith 'https://gcp'
| summarize avg=round((count(itemCount)/28800.0))

// 1/2  43 tps
// 2/2  73 tps
// 3/2  44 tps
// 4/2  64 tps
// 5/2  33 tps
// 6/2  81 tps
// 7/2  94 tps
// 8/2  139 tps
// 9/2  340 tps - 461 tps peak minute
// 10/2 68 tps
// 11/2 30 tps
// 12/2 15 tps
// 13/2 43 tps
// 14/2 43 tps
// 15/2 109 tps
// 16/2 44 tps
// 17/2 224 tps
// 18/2 109 tps
// 19/2 32 tps
// 20/2 276 tps
// 21/2 48 tps



let start=datetime("2023-02-16T10:31:00.000Z");
let end=datetime("2023-02-16T10:41:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
| summarize tpsHeyTest=sum(itemCount), avgDur=avg(duration) by bin(timestamp, 1s)
| join (
    requests
    | where timestamp > start and timestamp < end
    | where url !startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
    | summarize tpsBackgroundNoice=sum(itemCount) by bin(timestamp, 1s) 
) on timestamp
| project timestamp, tpsHeyTest, tpsBackgroundNoice, avgDur
| render timechart



let start=datetime("2023-02-16T10:31:00.000Z");
let end=datetime("2023-02-16T10:41:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
| extend cm=parse_json(customMeasurements)
| summarize tpsHeyTest=sum(itemCount), totHeyTestRequesSize=sum(toint(cm.['Request Size'])) by bin(timestamp, 1s)
| join (
    requests
    | where timestamp > start and timestamp < end
    | where url !startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
    | extend cm=parse_json(customMeasurements)
    | summarize tpsBackgroundNoice=sum(itemCount), totBackgroundRequesSize=sum(toint(cm.['Request Size'])) by bin(timestamp, 1s)
) on timestamp
| project timestamp, tpsHeyTest, tpsBackgroundNoice, totHeyTestRequesSize, totBackgroundRequesSize
| render timechart

let start=datetime("2023-02-16T10:31:00.000Z");
let end=datetime("2023-02-16T10:41:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
| extend cm=parse_json(customMeasurements)
| summarize totHeyTestRequesSize=sum(toint(cm.['Request Size'])) by bin(timestamp, 1s)
| join (
    requests
    | where timestamp > start and timestamp < end
    | where url !startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
    | extend cm=parse_json(customMeasurements)
    | summarize totBackgroundRequesSize=sum(toint(cm.['Request Size'])) by bin(timestamp, 1s)
) on timestamp
| project timestamp, totHeyTestRequesSize, totBackgroundRequesSize
| render timechart



let start=datetime("2023-02-16T10:31:00.000Z");
let end=datetime("2023-02-16T10:41:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
| extend cm=parse_json(customMeasurements)
| summarize totHeyTestResponeSize=avg(toint(cm.['Request Size']))



let start=datetime("2023-02-16T10:31:00.000Z");
let end=datetime("2023-02-16T10:41:00.000Z");
requests
| where timestamp > start and timestamp < end
| where url !startswith 'https://gateway-test.hapi.hmgroup.com/syntheticapiipwhitelistedonly/api/TestObjects'
| extend cm=parse_json(customMeasurements)
| summarize totBackgroundResponseSize=avg(toint(cm.['Request Size']))



```