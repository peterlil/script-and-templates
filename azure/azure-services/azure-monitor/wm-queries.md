## VM SKU size change

```kql
AzureActivity
| where Properties_d.responseBody !~ ''
| project b = parse_json(tostring(parse_json(Properties_d)))
| extend rb = parse_json(tostring(parse_json(b.responseBody)))
| extend p = parse_json(tostring(parse_json(rb.properties)))
| where p.hardwareProfile.vmSize != ''
| summarize dcount(tostring(p.hardwareProfile.vmSize)) by tostring(b.resource)
```