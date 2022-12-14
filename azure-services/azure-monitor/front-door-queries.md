```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where ResourceId == "/SUBSCRIPTIONS/7F619149-07DC-42AD-8987-5ED45CA65301/RESOURCEGROUPS/LOADBALANCERSPIKEFRONTDOORSTANDARDGROUP/PROVIDERS/MICROSOFT.CDN/PROFILES/LOADBALANCERSPIKEFRONTDOORSTANDARD"
| where TimeGenerated between (datetime(2022-05-19 14:10:00) .. datetime(2022-05-19 14:11:50))
| summarize  Requests = count(), Duration = avg(timeTaken_d), 
    Percentile95 = percentile(timeTaken_d, 95) by pop_s



AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where ResourceId == "/SUBSCRIPTIONS/7F619149-07DC-42AD-8987-5ED45CA65301/RESOURCEGROUPS/LOADBALANCERSPIKEFRONTDOORSTANDARDGROUP/PROVIDERS/MICROSOFT.CDN/PROFILES/LOADBALANCERSPIKEFRONTDOORSTANDARD"
| where TimeGenerated between (datetime(2022-05-19 14:10:00) .. datetime(2022-05-19 14:11:50))
| summarize  Requests = count(), Duration = avg(timeTaken_d), 
    Percentile95 = percentile(timeTaken_d, 95)


AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| take 10

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| take 10

// WE VM 20.71.86.53

userAgent_s
clientIp_s

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where ResourceId == "/SUBSCRIPTIONS/7F619149-07DC-42AD-8987-5ED45CA65301/RESOURCEGROUPS/LOADBALANCERSPIKEFRONTDOORSTANDARDGROUP/PROVIDERS/MICROSOFT.CDN/PROFILES/LOADBALANCERSPIKEFRONTDOORSTANDARD"
| where TimeGenerated > datetime(2022-05-20 06:56:00)  //ago(2hours) //'2022-05-04 10:03:00'
| where TimeGenerated < datetime(2022-05-20 06:58:30)
| summarize  Requests = count(), Duration = avg(timeTaken_d), 
    Percentile95 = percentile(timeTaken_d, 95) by clientIp_s

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where ResourceId == "/SUBSCRIPTIONS/7F619149-07DC-42AD-8987-5ED45CA65301/RESOURCEGROUPS/LOADBALANCERSPIKEFRONTDOORSTANDARDGROUP/PROVIDERS/MICROSOFT.CDN/PROFILES/LOADBALANCERSPIKEFRONTDOORSTANDARD"
| where TimeGenerated between (datetime(2022-05-20 06:51:30) .. datetime(2022-05-20 06:59:30))
| summarize Requests = count() by bin(TimeGenerated, 5s)
| render timechart

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where ResourceId == "/SUBSCRIPTIONS/7F619149-07DC-42AD-8987-5ED45CA65301/RESOURCEGROUPS/LOADBALANCERSPIKEFRONTDOORSTANDARDGROUP/PROVIDERS/MICROSOFT.CDN/PROFILES/LOADBALANCERSPIKEFRONTDOORSTANDARD"
| where TimeGenerated between (datetime(2022-05-20 07:00:00) .. datetime(2022-05-20 07:01:10))

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where TimeGenerated > datetime(2022-12-07 16:32:00)
| summarize Requests = count(), AvgDuration = avg(timeTaken_d), 
    Percentile95 = percentile(timeTaken_d, 95) by pop_s

AzureDiagnostics
| where ResourceProvider == "MICROSOFT.CDN" and Category == "FrontDoorAccessLog"
| where TimeGenerated > datetime(2022-12-07 16:32:00)
| summarize Requests = count(), AvgDuration = avg(timeTaken_d), 
    Percentile95 = percentile(timeTaken_d, 95) by httpStatusCode_d, pop_s


```
