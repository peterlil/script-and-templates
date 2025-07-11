# Simple cluster management

**Login in PowerShell** is simply performed by giving it the namespace.\
`azdata login --namespace <namespace> --username <username>`

**Login in WSL** did not accept the same command, it required the endpoint even though I gave it the namespace.\
`azdata login --endpoint <endpoint> --username <username>`

Get the **endpoint list** for the BDC.\
`azdata bdc endpoint list -o table`
