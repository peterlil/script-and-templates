# PowerShell Profiles

I used the following articles as references:
* [How to use a PowerShell Profile to simplify tasks](https://www.techrepublic.com/blog/data-center/how-to-use-a-powershell-profile-to-simplify-tasks/)

Check if a profile exists with `Test-Path $profile`. If it returns `false`, no profile exists.

To create a new profile, run this command `New-item -path $profile -type file -force`. To open the newly created profile, run  `code $profile`.

