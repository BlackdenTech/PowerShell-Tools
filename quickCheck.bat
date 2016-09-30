@echo off
:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:::::::::::::::::::::::::::::::::::::::::
CLS 
ECHO.
ECHO =============================
ECHO Running Admin shell
ECHO =============================
 
:checkPrivileges 
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 
 
:getPrivileges 
if '%1'=='ELEV' (shift & goto gotPrivileges)  
ECHO. 
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation 
ECHO **************************************
 
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B 
 
@echo off
:gotPrivileges 
::::::::::::::::::::::::::::
:START
::::::::::::::::::::::::::::
ECHO This will reboot the computer unless you press Ctrl + C now
ECHO Run Disk Cleanup
cleanmgr /sagerun:1
ECHO Run Disk Defrag on C Drive
powershell.exe -NoProfile -Command (Optimize-Volume -DriveLetter C -Defrag -Verbose)
ECHO Clear Temp folder
powershell.exe -NoProfile -Command (Get-ChildItem $env:TEMP | Remove-Item -Recurse -Force -Verbose)
ECHO Repair C Drive
powershell.exe -NoProfile -Command (Repair-Volume -DriveLetter C -Scan -Verbose)
ECHO Group Policy Update
gpupdate /Force
ECHO Rebooting now
shutdown -r -f -t 05