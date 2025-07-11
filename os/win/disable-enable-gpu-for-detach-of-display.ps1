$GtxId = (Get-PnpDevice -FriendlyName "*GTX*").InstanceId
echo "  DeviceID = $GtxId"

echo "Disabling GTX."
Disable-PnpDevice -Confirm:$false -InstanceId $GtxId

# Wait for user to click detach button
Read-Host -Prompt "Safe to detach. Try detach button now. Hit enter to re-enable GTX." 

echo "Enabling GTX."
Enable-PnpDevice -Confirm:$false -InstanceId $GtxId