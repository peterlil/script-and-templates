# Working with DateTime

## Converting Unix timestamp to DateTime

```
$milliSeconds = 1620108900000
(Get-Date -Date "1970-01-01").AddMilliSeconds($milliSeconds).ToLocalTime()
```