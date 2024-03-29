# Settings and Control Panel commands

## Table of commands

Control Panel Item                                 | Commands
---------------------------------------------------|---------
Accounts - Access Work or School                   | start ms-settings:workplace
Add a Device wizard                                | %windir%\System32\DevicePairingWizard.exe
Add Hardware wizaCommand line table from TenForums | %windir%\System32\hdwwiz.exe
Add a Printer wizard | rundll32.exe shell32.dll,SHHelpShortcuts_RunDLL AddPrinter
Additional Clocks | rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,,1
Administrative Tools | control /name Microsoft.AdministrativeTools <br/> OR <br/> control admintools
AutoPlay | control /name Microsoft.AutoPlay
Backup and Restore (Windows 7) | control /name Microsoft.BackupAndRestoreCenter
BitLocker Drive Encryption | control /name Microsoft.BitLockerDriveEncryption
Color and Appearance | explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\pageColorization
Color Management | control /name Microsoft.ColorManagement
Credential Manager | control /name Microsoft.CredentialManager
Date and Time (Date and Time) | control /name Microsoft.DateAndTime <br/> OR <br/> control timedate.cpl <br/> OR <br/> control date/time <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,,0
Date and Time (Additional Clocks) | rundll32.exe shell32.dll,Control_RunDLL timedate.cpl,,1
Default Programs | control /name Microsoft.DefaultPrograms
Desktop Background | explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921} -Microsoft.Personalization\pageWallpaper
Desktop Icon Settings | rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,0
Device Manager | control /name Microsoft.DeviceManager <br/> OR <br/> control hdwwiz.cpl <br/> OR <br/> devmgmt.msc
Devices and Printers | control /name Microsoft.DevicesAndPrinters <br/> OR <br/> control printers
Ease of Access Center | control /name Microsoft.EaseOfAccessCenter <br/> OR <br/> control access.cpl
File Explorer Options (General tab) | control /name Microsoft.FolderOptions <br/> OR <br/> control folders <br/> OR <br/> rundll32.exe shell32.dll,Options_RunDLL 0
File Explorer Options (View tab) | rundll32.exe shell32.dll,Options_RunDLL 7
File Explorer Options (Search tab) | rundll32.exe shell32.dll,Options_RunDLL 2
File History | control /name Microsoft.FileHistory
Fonts | control /name Microsoft.Fonts <br/> OR <br/> control fonts
Game Controllers | control /name Microsoft.GameControllers <br/> OR <br/> control joy.cpl
Get Programs | control /name Microsoft.GetPrograms <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,1
HomeGroup | control /name Microsoft.HomeGroup
Indexing Options | control /name Microsoft.IndexingOptions <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL srchadmin.dll
Infrared | control /name Microsoft.Infrared <br/> OR <br/> control irprops.cpl <br/> OR <br/> control /name Microsoft.InfraredOptions
Internet Properties (General tab) | control /name Microsoft.InternetOptions <br/> OR <br/> control inetcpl.cpl <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,0
Internet Properties (Security tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,1
Internet Properties (Privacy tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,2
Internet Properties (Content tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,3
Internet Properties (Connections tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,4
Internet Properties (Programs tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,5
Internet Properties (Advanced tab) | rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,6
iSCSI Initiator | control /name Microsoft.iSCSIInitiator
Keyboard | control /name Microsoft.Keyboard <br/> OR <br/> control keyboard
Language | control /name Microsoft.Language
Mouse Properties (Buttons tab 0) | control /name Microsoft.Mouse <br/> OR <br/> control main.cpl <br/> OR <br/> control mouse <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL main.cpl,,0
Mouse Properties (Pointers tab 1) | control main.cpl,,1 <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL main.cpl,,1
Mouse Properties (Pointer Options tab 2) | control main.cpl,,2 <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL main.cpl,,2
Mouse Properties (Wheel tab 3) | control main.cpl,,3 <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL main.cpl,,3
Mouse Properties (Hardware tab 4) | control main.cpl,,4 <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL main.cpl,,4
Network and Sharing Center | control /name Microsoft.NetworkAndSharingCenter
Network Connections | control ncpa.cpl <br/> OR <br/> control netconnections
Network Setup Wizard | control netsetup.cpl
Notification Area Icons | explorer shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}
ODBC Data Source Administrator | control odbccp32.cpl
Offline Files | control /name Microsoft.OfflineFiles
Performance Options (Visual Effects) | %windir%\system32\SystemPropertiesPerformance.exe
Performance Options (Data Execution Prevention) | %windir%\system32\SystemPropertiesDataExecutionPrevention.exe
Personalization | explorer shell:::{ED834ED6-4B5A-4bfe-8F11-A626DCB6A921}
Phone and Modem | control /name Microsoft.PhoneAndModem <br/> OR <br/> control telephon.cpl
Power Options | control /name Microsoft.PowerOptions <br/> OR <br/> control powercfg.cpl
Power Options - Advanced settings | control powercfg.cpl,,1
Power Options - Create a Power Plan | control /name Microsoft.PowerOptions /page pageCreateNewPlan
Power Options - Edit Plan Settings | control /name Microsoft.PowerOptions /page pagePlanSettings
Power Options - System Settings | control /name Microsoft.PowerOptions /page pageGlobalSettings
Presentation Settings | %windir%\system32\PresentationSettings.exe
Programs and Features | control /name Microsoft.ProgramsAndFeatures <br/> OR <br/> control appwiz.cpl
Recovery | control /name Microsoft.Recovery
Region (Formats tab) | control /name Microsoft.RegionAndLanguage <br/> OR <br/> control /name Microsoft.RegionalAndLanguageOptions /page /p:"Formats" <br/> OR <br/> control intl.cpl <br/> OR <br/> control international
Region (Location tab) | control /name Microsoft.RegionalAndLanguageOptions /page /p:"Location"
Region (Administrative tab) | control /name Microsoft.RegionalAndLanguageOptions /page /p:"Administrative"
RemoteApp and Desktop Connections | control /name Microsoft.RemoteAppAndDesktopConnections
Scanners and Cameras | control /name Microsoft.ScannersAndCameras <br/> OR <br/> control sticpl.cpl
Screen Saver Settings | rundll32.exe shell32.dll,Control_RunDLL desk.cpl,,1
Security and Maintenance | control /name Microsoft.ActionCenter <br/> OR <br/> control wscui.cpl
Set Associations | control /name Microsoft.DefaultPrograms /page pageFileAssoc
Set Default Programs | control /name Microsoft.DefaultPrograms /page pageDefaultProgram
Set Program Access and Computer Defaults | rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,3
Settings | start ms-settings:
Sound (Playback tab) | control /name Microsoft.Sound <br/> OR <br/> control mmsys.cpl <br/> OR <br/> %windir%\System32\rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,0
Sound (Recording tab) | %windir%\System32\rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,1
Sound (Sounds tab) | %windir%\System32\rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,2
Sound (Communications tab) | %windir%\System32\rundll32.exe shell32.dll,Control_RunDLL mmsys.cpl,,3
Speech Recognition | control /name Microsoft.SpeechRecognition
Storage Spaces | control /name Microsoft.StorageSpaces
Sync Center | control /name Microsoft.SyncCenter
System | control /name Microsoft.System <br/> OR <br/> control sysdm.cpl
System Icons | explorer shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9} \SystemIcons,,0
System Properties (Computer Name) | %windir%\System32\SystemPropertiesComputerName.exe
System Properties (Hardware) | %windir%\System32\SystemPropertiesHardware.exe
System Properties (Advanced) | %windir%\System32\SystemPropertiesAdvanced.exe
System Properties (System Protection) | %windir%\System32\SystemPropertiesProtection.exe
System Properties (Remote) | %windir%\System32\SystemPropertiesRemote.exe
Tablet PC Settings | control /name Microsoft.TabletPCSettings
Text to Speech | control /name Microsoft.TextToSpeech
Troubleshooting | explorer shell:::{26EE0668-A00A-44D7-9371-BEB064C98683}\0\::{C58C4893-3BE0-4B45-ABB5-A63E4B8C8651}
User Accounts | control /name Microsoft.UserAccounts <br/> OR <br/> control userpasswords
User Accounts (netplwiz) | netplwiz <br/> OR <br/> control userpasswords2
Windows Defender Firewall | control /name Microsoft.WindowsFirewall <br/> OR <br/> control firewall.cpl
Windows Defender Firewall Allowed apps | explorer shell:::{4026492F-2F69-46B8-B9BF-5654FC07E423} -Microsoft.WindowsFirewall\pageConfigureApps
Windows Defender Firewall with Advanced Security | %WinDir%\System32\WF.msc
Windows Features | %windir%\System32\OptionalFeatures.exe <br/> OR <br/> rundll32.exe shell32.dll,Control_RunDLL appwiz.cpl,,2
Windows Mobility Center | control /name Microsoft.MobilityCenter
Windows Update | control update
Work Folders | %windir%\System32\WorkFolders.exe



## References
[Command line table from TenForums](https://www.tenforums.com/tutorials/86339-list-commands-open-control-panel-items-windows-10-a.html)
[List of ms-settings uri commands](https://4sysops.com/wiki/list-of-ms-settings-uri-commands-to-open-specific-settings-in-windows-10/history/?revision=1558411)
