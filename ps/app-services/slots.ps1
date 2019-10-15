
Login-AzAccount


$rg = "app-service"
$site = "peterliltest"

Get-AzWebAppSlot -ResourceGroupName $rg -name $site `
    | Format-Table Name, Kind, Type, DefaultHostName, State, UsageState, Enabled, Reserved


5 .. 20 | ForEach-Object {
    New-AzWebAppSlot -ResourceGroupName $rg -name $site -slot ('staging' + $_.ToString())
}



19 .. 1 | ForEach-Object {
    Remove-AzWebAppSlot -ResourceGroupName $rg -name $site -slot ('staging' + $_.ToString()) -Force
}

