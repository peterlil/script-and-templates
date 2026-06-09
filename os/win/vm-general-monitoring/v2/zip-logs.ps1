param([string] $FileSearch, [int] $DaysOld)
function Make-Zip
{
	$shellApplication = new-object -com shell.application
	$zipPackage = @();
	foreach($file in $input) 
	{ 
		$ZipFilename = ($file.DirectoryName + "\" + $file.BaseName + ".zip")
		set-content $ZipFilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		(Get-ChildItem $ZipFilename).IsReadOnly = $false		
		$zp = $shellApplication.NameSpace($ZipFilename)
		$zipPackage += $zp;
		$zp.MoveHere($file.FullName)
	}
}

Get-ChildItem $FileSearch | Where-Object {$_.Lastwritetime -lt (Get-Date).adddays(-1 * $DaysOld)} | Make-Zip

Start-Sleep -MilliSeconds 30000