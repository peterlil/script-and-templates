param([string] $FileSearch, [int] $DaysOld)

Get-ChildItem $FileSearch | Where-Object {$_.Lastwritetime -lt (Get-Date).adddays(-1 * $DaysOld)} | Remove-Item
