# App Services helper log queries

## Azure Functions

```kql
// Total executions and errors on a timechart
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Category startswith "Function." and Message startswith "Executed ")
    | summarize BigCount = count() by bin(TimeGenerated, 5min)
    | project TimeGenerated, Count=tolong(round(BigCount/10,0)), MetricName="Executions"
| union (
    FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | summarize Count = count() by bin(TimeGenerated, 5min)
    | project TimeGenerated, Count, MetricName="Errors"
)
| project TimeGenerated, Count, MetricName
| render timechart

let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Category startswith "Function." and Message startswith "Executed ")
    | summarize BigCount = count() by bin(TimeGenerated, 5min), FunctionName
    | project TimeGenerated, FunctionName, Count=tolong(round(BigCount/10,0)), MetricName="Executions"
| union (
    FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | summarize Count = count() by bin(TimeGenerated, 5min), FunctionName
    | project TimeGenerated, FunctionName, Count, MetricName="Errors"
)
| project TimeGenerated, Count, FunctionMetric=strcat(FunctionName, ".", MetricName)
| render timechart


// It seems like the only changefeed with issues is the OptionGroupChangeFeed
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName == "OptionGroupChangeFeed"
    | where ExceptionDetails contains "PathNotFoundException"
    | summarize Count=count()
    | project ExceptionName="PathNotFoundException", Count
| union (
    FunctionAppLogs
        | where TimeGenerated > dtStart and TimeGenerated < dtEnd
        | where (Level == "Error")
        | where FunctionName == "OptionGroupChangeFeed"
        | where ExceptionDetails !contains "PathNotFoundException"
        | summarize Count=count()
        | project ExceptionName="Other", Count
    )

let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName !startswith "Functions."
    | summarize Count = count() by FunctionName
    | project FunctionName, Count
    | render columnchart 


// It seems like the only changefeed with issues is the OptionGroupChangeFeed
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName == "OptionGroupChangeFeed"
    | where ExceptionDetails contains "PathNotFoundException"
    | summarize Count=count()
    | project ExceptionName="PathNotFoundException", Count
| union (
    FunctionAppLogs
        | where TimeGenerated > dtStart and TimeGenerated < dtEnd
        | where (Level == "Error")
        | where FunctionName == "OptionGroupChangeFeed"
        | where ExceptionDetails !contains "PathNotFoundException"
        | summarize Count=count()
        | project ExceptionName="Other", Count
    )


// It seems like the only changefeed with issues is the ProductByProductIdSeason
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName == "ProductByProductIdSeason"
    | where ExceptionDetails contains "DocumentClientException : The request rate is too large"
    | summarize Count=count()
    | project ExceptionName="DocumentClientException", Count
| union (
    FunctionAppLogs
        | where TimeGenerated > dtStart and TimeGenerated < dtEnd
        | where (Level == "Error")
        | where FunctionName == "ProductByProductIdSeason"
        | where ExceptionDetails !contains "DocumentClientException : The request rate is too large"
        | summarize Count=count()
        | project ExceptionName="Other", Count
    )


// It seems like the only changefeed with issues is the ProductByProductIdSeason
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName == "ProductById"
    | where ExceptionDetails contains "DocumentClientException : The request rate is too large"
    | summarize Count=count()
    | project ExceptionName="DocumentClientException", Count
| union (
    FunctionAppLogs
        | where TimeGenerated > dtStart and TimeGenerated < dtEnd
        | where (Level == "Error")
        | where FunctionName == "ProductByProductIdSeason"
        | where ExceptionDetails !contains "DocumentClientException : The request rate is too large"
        | summarize Count=count()
        | project ExceptionName="Other", Count
    )

// It seems like the only changefeed with issues is the ProductByProductIdSeason
let dtStart = ago(4d);
let dtEnd = ago(3d);
FunctionAppLogs
    | where TimeGenerated > dtStart and TimeGenerated < dtEnd
    | where (Level == "Error")
    | where FunctionName == "ProductById"
    | where ExceptionDetails contains "DocumentClientException : The request rate is too large"
    | summarize Count=count()
    | project ExceptionName="DocumentClientException", Count
| union (
    FunctionAppLogs
        | where TimeGenerated > dtStart and TimeGenerated < dtEnd
        | where (Level == "Error")
        | where FunctionName == "ProductById"
        | where ExceptionDetails !contains "DocumentClientException : The request rate is too large"
        | summarize Count=count()
        | project ExceptionName="Other", Count
    )



// failed request count by name
let start=datetime("2022-02-10T13:41:00.000Z");
let end=datetime("2022-02-11T13:41:00.000Z");
let timeGrain=5m;
let dataset=requests
    // additional filters can be applied here
    | where timestamp > start and timestamp < end
    | where client_Type != "Browser"
;
dataset
// change 'operation_Name' on the below line to segment by a different property
| summarize
    failedCount=sumif(itemCount, success == false),
    impactedUsers=dcountif(user_Id, success == false),
    totalCount=sum(itemCount)
    by operation_Name
// calculate failed request count for all requests
| union(dataset
    | summarize
        failedCount=sumif(itemCount, success == false),
        impactedUsers=dcountif(user_Id, success == false),
        totalCount=sum(itemCount)
    | extend operation_Name="Overall")
| where failedCount > 0
| order by failedCount desc

```

## Application Insights helper queries

### Queries useful for performance tests

Find a test by looking at the request pattern

```kql
requests
| where timestamp > ago(2h) 
| project timestamp, duration
| render scatterchart
```

Look closer at a test by setting start and end time that can be read from the query above.

```kql
// Request duration 
let start=datetime("2023-03-15T08:39:20.000Z");
let end=datetime("2023-03-15T08:44:30.000Z");
requests
| where timestamp between (start .. end)
| project timestamp, duration
| render scatterchart

// Dependency duration
let start=datetime("2023-03-15T08:39:20.000Z");
let end=datetime("2023-03-15T08:44:30.000Z");
dependencies
| where timestamp between (start .. end)
| project timestamp, duration
| render scatterchart 

// Custom Metrics
let start=datetime("2023-03-15T08:39:20.000Z");
let end=datetime("2023-03-15T08:44:30.000Z");
customMetrics
| where timestamp between (start .. end)
| where name == "DatabaseCalls"
| project timestamp, duration=value
| render scatterchart 

// Dependency duration combined with custom metric
let start=datetime("2023-03-15T08:32:52.000Z");
let end=datetime("2023-03-15T08:37:47.000Z");
dependencies
| where timestamp between (start .. end)
| project timestamp, dbDuration=duration
| union (
    customMetrics
    | where timestamp between (start .. end)
    | where name == "DatabaseCalls"
    | project timestamp, totalDbDuration=value
)
| render scatterchart 

// Response duration together with dependency duration combined with custom metric
let start=datetime("2023-03-15T08:32:52.000Z");
let end=datetime("2023-03-15T08:37:47.000Z");
dependencies
| where timestamp between (start .. end)
| project timestamp, dbDuration=duration
| union (
    customMetrics
    | where timestamp between (start .. end)
    | where name == "DatabaseCalls"
    | project timestamp, totalDbDuration=value
)
| union (
    requests
    | where timestamp between (start .. end)
    | project timestamp, requestDuration=duration
    | render scatterchart
)
| render scatterchart 

```


The inspiration for many of these queries comes from the _Live metrics_ view in Application Insights. 

```kql
// Request count trend 
// Chart Request count over the last day. 
// To create an alert for this query, click '+ New alert rule'
requests
| where timestamp >= ago(30m)
| summarize totalCount=sum(itemCount) by bin(timestamp, 1s)
| render timechart


// Response time trend 
// Chart request duration over the last 12 hours. 
// To create an alert for this query, click '+ New alert rule'
requests
| where timestamp > ago(30m) 
| project timestamp, duration
| render scatterchart


// Failed requests – top 10 
// What are the 3 slowest pages, and how slow are they? 
requests
| where success == false
| summarize failedCount=sum(itemCount) by name
| top 10 by failedCount desc
| render barchart


// Dependency call rate (Needs work, too many and clustered)
dependencies
| where timestamp >= ago(30m)
| where type == 'SQL'
| summarize totalCount=sum(itemCount) by bin(timestamp, 1s)
| render timechart


// Dependency duration
dependencies
| where timestamp >= ago(30m)
| project timestamp, duration
| render scatterchart 

// Dependency call failure
dependencies
| where timestamp >= ago(30m)
| where success  == false

performanceCounters
| where timestamp >= ago(30m)
| where name == 'Private Bytes'
| project  timestamp, GB=(value/(1024*1024*1024))
| render timechart 


performanceCounters
| where timestamp >= ago(30m)
| where name == '% Processor Time Normalized'
| project  timestamp, CPU=value
| render timechart 

performanceCounters
| take 100
```


### CPU by machine's performance counters

Work in progress

```kql
performanceCounters
| where timestamp > ago(10min)
| distinct category

performanceCounters
| where timestamp >= datetime(2023-03-09T10:32:03.207Z) and timestamp < datetime(2023-03-10T10:32:03.207Z)
| where ((category == "Process" and counter == "% Processor Time Normalized") or name == "processCpuPercentage")
| extend performanceCounter_value = iif(itemType == 'performanceCounter', value, todouble(''))
| summarize ['performanceCounters/processCpuPercentage_avg'] = sum(performanceCounter_value) / count() by bin(timestamp, 5m)
| order by timestamp desc

performanceCounters
| where timestamp >= datetime(2023-03-09T10:32:03.207Z) and timestamp < datetime(2023-03-10T10:32:03.207Z)
| where ((category == "Process" and counter == "% Processor Time Normalized") or name == "processCpuPercentage")
| extend performanceCounter_value = iif(itemType == 'performanceCounter', value, todouble(''))
| summarize ['performanceCounters/processCpuPercentage_avg'] = sum(performanceCounter_value) / count() by bin(timestamp, 5m)
innerjoin (
    performanceCounters
    | where timestamp >= datetime(2023-03-09T10:32:03.207Z) and timestamp < datetime(2023-03-10T10:32:03.207Z)
    | where ((category == "Process" and counter == "% Processor Time Normalized") or name == "processCpuPercentage")
    | extend performanceCounter_value = iif(itemType == 'performanceCounter', value, todouble(''))
    | summarize ['performanceCounters/processCpuPercentage_avg'] = sum(performanceCounter_value) / count() by bin(timestamp, 5m)

)
'''






///++++++++ Queries for performance tests from Web App +++++++++
// Response times of requests 
// Avg & 90, 95 and 99 percentile response times (in milliseconds) per App Service. 
AppServiceHTTPLogs 
| summarize avg(TimeTaken), percentiles(TimeTaken, 90, 95, 99) by _ResourceId

AppServiceHTTPLogs
| where CsUriStem startswith "/actuals"
| where TimeGenerated >= ago(4h)
| summarize Requests=count() by bin(TimeGenerated, 4s)
| render timechart 



///++++++++ Queries for performance tests from App Service Plan +++++++++
AzureMetrics 
| distinct MetricName
| take 100 

AzureMetrics 
| where MetricName == "CpuPercentage"
| take 100 

AzureMetrics 
| where MetricName == "MemoryPercentage"
| take 100 

AzureMetrics 
| where MetricName == "BytesSent"
| take 100 

AzureMetrics
| where TimeGenerated >= ago(4h)
| where MetricName == "CpuPercentage"
| project TimeGenerated, AvgCPU=Average
| render timechart 

AzureMetrics
| where TimeGenerated >= ago(4h)
| where MetricName == "MemoryPercentage"
| project TimeGenerated, AvgMemory=Average
| render timechart 

AzureMetrics
| where TimeGenerated >= ago(4h)
| where MetricName == "BytesSent"
| project TimeGenerated, BytesSent=Average
| render timechart 

