@echo off
title Prepfix Church Media Toolkit - keep this window open
cd /d "%~dp0"

rem No "Open File - Security Warning": tell Windows not to ask about files that came from the internet, WhatsApp or a flash disk.
rem (This applies to everything this window starts: the toolkit, the projector window, PowerPoint/PDF helpers.)
set "SEE_MASK_NOZONECHECKS=1"

rem Use node.exe from this folder if it is here (no installation needed), otherwise the installed Node.js
set "NODE=node"
if exist "%~dp0node.exe" set "NODE=%~dp0node.exe"
"%NODE%" -v >nul 2>&1
if errorlevel 1 goto nonode

rem First run on this computer (or the folder was moved): make the START shortcuts with the church icon, and
rem remove the "downloaded from the internet" mark from every file in this folder so Windows never asks again.
set "PF_DIR=%~dp0"
set "PF_TARGET=%~f0"
set "PF_LAST="
if exist "%~dp0.setup-done" set /p PF_LAST=<"%~dp0.setup-done"
if /i "%PF_LAST%"=="%~dp0" goto run
powershell -NoProfile -ExecutionPolicy Bypass -Command "$dir=$env:PF_DIR; $d=[Environment]::GetFolderPath('Desktop'); $ico=Join-Path $dir 'prepfix.ico'; if(-not (Test-Path -LiteralPath $ico)){$ico=$env:SystemRoot+'\System32\imageres.dll,186'}; $w=New-Object -ComObject WScript.Shell; foreach($p in @((Join-Path $d 'Prepfix Church.lnk'),(Join-Path $dir 'START PREPFIX CHURCH.lnk'))){ $s=$w.CreateShortcut($p); $s.TargetPath=$env:PF_TARGET; $s.WorkingDirectory=$dir; $s.IconLocation=$ico; $s.Description='Start the Prepfix Church Media Toolkit'; $s.Save() }; Get-ChildItem -LiteralPath $dir -Recurse -Force -File | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1
>"%~dp0.setup-done" echo %~dp0

:run
"%NODE%" server.js
rem exit code 3 = an update was installed: start again with the new version
if %errorlevel%==3 (
  echo.
  echo  Update installed - starting the new version...
  goto run
)
rem exit code 0 = closed on purpose (this window or the browser tab was closed): close this window too, nothing to read
if %errorlevel%==0 exit
pause
exit /b

:nonode
echo.
echo  Node.js was not found on this computer.
echo.
echo  Fix: copy the file node.exe into this folder:
echo       %~dp0
echo  (or install Node.js LTS from https://nodejs.org), then double-click this file again.
echo.
pause
exit /b
