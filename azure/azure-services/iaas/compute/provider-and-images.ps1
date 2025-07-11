Login-AzureRmAccount

Get-AzureRmVMImagePublisher -Location "North Europe" | Where-Object {$_.PublisherName -eq 'MicrosoftWindowsServer'}

Get-AzureRmVMImageOffer -Location 'North Europe' -PublisherName 'MicrosoftWindowsServer'

Get-AzureRmVMImageSku -Location 'North Europe' -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer'

Get-AzureRmVMImage -Location 'North Europe' -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2016-Datacenter'





$list = @()
Get-AzureRmVMImageOffer -Location 'North Europe' -PublisherName 'microsoft-ads' | ForEach-Object {
    $offer = $_
    Get-AzureRmVMImageSku -Location $_.Location -PublisherName $_.PublisherName -Offer $_.Offer | ForEach-Object {
        $sku = $_
        Get-AzureRmVMImage -Location $_.Location -PublisherName $_.PublisherName -Offer $_.Offer -Skus $_.Skus | ForEach-Object {
            $listitem = new-Object -typename System.Object 
            $listitem | Add-Member -MemberType noteProperty -Name "Publisher" -Value $offer.PublisherName
            $listitem | Add-Member -MemberType noteProperty -Name "Offer" -Value $offer.Offer
            $listitem | Add-Member -MemberType noteProperty -Name "Skus" -Value $sku.Skus
            $listitem | Add-Member -MemberType noteProperty -Name "Version" -Value $_.Version
            $list += $listitem
        }
    }
}
$list | Format-Table *


Get-AzureRmVMImage -Location 'North Europe' -PublisherName 'microsoft-ads' -Offer 'windows-data-science-vm' -Skus 'windows2016' | 
    ForEach-Object {
        $_ | Format-List *
        $listitem = new-Object -typename System.Object 
        $listitem | Add-Member -MemberType noteProperty -Name "Skus" -Value $_.Skus
        $listitem | Add-Member -MemberType noteProperty -Name "PublishedDate" -Value $_.PublishedDate
        $list += $listitem
    }
$list | Format-Table *


Get-AzureRmVMImage -Location 'North Europe' -PublisherName 'microsoft-ads' -Offer 'windows-data-science-vm' -Skus 'windows2016' | Sort-Object -Descending -Property AliBaba
Get-AzureRmVMImage -Location 'North Europe' -PublisherName 'microsoft-ads' -Offer 'windows-data-science-vm' -Skus 'windows2016' | Sort-Object -Property PublishedDate