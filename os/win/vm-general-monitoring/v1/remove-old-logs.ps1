param([string] $FileSearch, [int] $DaysOld)

Get-ChildItem $FileSearch | where {$_.Lastwritetime -lt (date).adddays(-1 * $DaysOld)} | Remove-Item
