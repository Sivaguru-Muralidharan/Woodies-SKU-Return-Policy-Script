cd %~d0 
cd %~dp0
Powershell.exe -executionpolicy remotesigned -File packages\main.ps1
@pause