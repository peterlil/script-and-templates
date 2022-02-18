# Protect your webapp and api using Application Gateway

## Sample GitHub action for setting access restrictions on the api
```yaml
# Deployment of the app-gw-multi-tenant-app-service solution

name: deploy-app-gw-multi-tenant-app-service

on: workflow_dispatch

env:
  AZURE_WEBAPP_PACKAGE_PATH: ".\\drop"
  WebAppName: webapp-666
  ApiAppName: apiapp-666
  ResourceGroupName: lab-projects

jobs:
  deploy_apiapp:
    runs-on: windows-latest

    steps:
      - name: Setup Dotnet 6.0.x
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '6.0.x'
      
      - name: Checkout the repo
        uses: actions/checkout@main

      - name: dotnet build and publish
        run: |
          pwd
          dotnet build .\app-gw-multi-tenant-app-service\apiapp\apiapp.csproj --configuration Release
          dotnet publish .\app-gw-multi-tenant-app-service\apiapp\apiapp.csproj -c Release -o '${{ env.AZURE_WEBAPP_PACKAGE_PATH }}\apiapp'

      - name: deploy-apiapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.ApiAppName }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE__APIAPP }}
          package: '${{ env.AZURE_WEBAPP_PACKAGE_PATH }}\apiapp'

  deploy_webapp:
    runs-on: windows-latest

    steps:
      - name: Setup Dotnet 6.0.x
        uses: actions/setup-dotnet@v1
        with:
          dotnet-version: '6.0.x'
      
      - name: Checkout the repo
        uses: actions/checkout@main

      - name: dotnet build and publish
        run: |
          pwd
          dotnet build .\app-gw-multi-tenant-app-service\webapp\webapp.csproj --configuration Release
          dotnet publish .\app-gw-multi-tenant-app-service\webapp\webapp.csproj -c Release -o '${{ env.AZURE_WEBAPP_PACKAGE_PATH }}\webapp'

      - name: log in to azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDS_RG_LAB_PROJECTS }}
          
      - uses: azure/appservice-settings@v1
        with:
          app-name: ${{ env.WebAppName }}
          app-settings-json: '${{ secrets.WEBAPP666_APPSETTING_BACKENDAPI }}' 
        id: settings

      - name: deploy-webapp
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ env.WebAppName }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE__WEBAPP }}
          package: '${{ env.AZURE_WEBAPP_PACKAGE_PATH }}\\webapp'

  api_fw_conf:
    runs-on: windows-latest
    needs: [deploy_apiapp, deploy_webapp]

    steps:
      - name: log in to azure
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDS_RG_LAB_PROJECTS }}

      - name: configure webapi ip restrictions
        run: |
          # Get all ips to allow
          $ipString = az webapp show --resource-group ${{ env.ResourceGroupName }} --name ${{ env.WebAppName }} --query outboundIpAddresses --output tsv
          $ips = $ipString.Split(',')
          # $ips = @()
          # Get all Allow rules
          $rules = az webapp config access-restriction show -g ${{ env.ResourceGroupName }} -n ${{ env.ApiAppName }} --query "ipSecurityRestrictions[?action=='Allow'].{name:name, priority:priority, action:action, ip_address:ip_address, remove:'true'}" -o json | ConvertFrom-Json

          # Remove the rules that are not in the ip-list, and store the remaining priorities
          $prioList = @()
          $rules | ForEach-Object {
              $rule = $_
              $found = $false
              $ips | ForEach-Object {
                  if ($rule.ip_address -eq ("$_/32") -and $found -eq $false) {
                      $found = $true
                      $rule.remove = $false
                      $prioList += $rule.priority
                      Write-Host "Don't remove $_/32"
                  }
              }
              if($rule.remove -eq "true") {
                  Write-Host "Removing $($rule.ip_address)"
                  $result = az webapp config access-restriction remove -g ${{ env.ResourceGroupName }} -n ${{ env.ApiAppName }} --rule-name $rule.name
              }
          }

          # Get all remaining Allow rules
          $rules = az webapp config access-restriction show -g ${{ env.ResourceGroupName }} -n ${{ env.ApiAppName }} --query "ipSecurityRestrictions[?action=='Allow'].{name:name, action:action, ip_address:ip_address, remove:'true'}" -o json | ConvertFrom-Json
          $prio = 100
          $ips | ForEach-Object {
              $ip = $_
              $found = $false
              $rules | ForEach-Object {
                  if($found -eq $false) {
                      if (("$ip/32") -eq $_.ip_address) {
                          $found = $true
                          Write-Host "Don't add $ip/32"
                      }
                  }
              }
              if($found -ne "true") {
                  while ($prioList -contains $prio) {
                      $prio++
                  }
                  Write-Host "Adding rule $ip/32 with priority $prio"
                  $result = az webapp config access-restriction add -g ${{ env.ResourceGroupName }} -n ${{ env.ApiAppName }} --priority $prio --rule-name "ip-$ip" --action Allow --ip-address "$ip/32"
                  $prioList += $prio
              }
          }
```