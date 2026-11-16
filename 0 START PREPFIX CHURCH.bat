@echo off
title Prepfix Church Media Toolkit - keep this window open
cd /d "%~dp0"
set "SEE_MASK_NOZONECHECKS=1"
rem The toolkit is in the "program" folder; at the top this file only starts it.
for %%I in ("%~dp0.") do set "PF_HERE=%%~nxI"
if /i not "%PF_HERE%"=="program" if exist server.js if not exist ..\maker\maker.js call :tidy
if not exist server.js if exist program\server.js (
  call "%~dp0program\0 START PREPFIX CHURCH.bat"
  exit /b
)
set "NODE=node"
if exist node.exe set "NODE=%~dp0node.exe"
"%NODE%" -v >nul 2>&1
if errorlevel 1 goto nonode
rem First run here: make the START shortcuts and unblock the files.
set "PF_DIR=%~dp0"
set "PF_TOP=%~dp0"
set "PF_TARGET=%~f0"
if /i "%PF_HERE%"=="program" for %%J in ("%~dp0..") do set "PF_TOP=%%~fJ\"
if /i "%PF_HERE%"=="program" set "PF_TARGET=%PF_TOP%0 START PREPFIX CHURCH.bat"
set "PF_LAST="
if exist .setup-done set /p PF_LAST=<.setup-done
if /i "%PF_LAST%"=="%~dp0" goto run
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=$env:PF_TOP; $i=Join-Path $env:PF_DIR 'prepfix.ico'; if(-not (Test-Path -LiteralPath $i)){$i=$env:SystemRoot+'\System32\imageres.dll,186'}; $w=New-Object -ComObject WScript.Shell; foreach($p in @((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Prepfix Church.lnk'),(Join-Path $t 'START PREPFIX CHURCH.lnk'))){ $s=$w.CreateShortcut($p); $s.TargetPath=$env:PF_TARGET; $s.WorkingDirectory=$t; $s.IconLocation=$i; $s.Save() }; Get-ChildItem -LiteralPath $t -Recurse -Force -File | Unblock-File -ErrorAction SilentlyContinue" >nul 2>&1
>.setup-done echo %~dp0
rem .......................................................................................
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

:tidy
rem One time: move everything into the "program" folder so the church folder shows only a few things.
echo  Tidying the toolkit folder (one time)...
set "PF_TOP=%CD%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$d=$env:PF_TOP.TrimEnd('\'); $p=Join-Path $d 'program'; $keep=@('program','0 START PREPFIX CHURCH.bat','START PREPFIX CHURCH.lnk','GUIDE - Prepfix Church Media Toolkit.docx'); $items=@(Get-ChildItem -LiteralPath $d -Force | Where-Object { $keep -notcontains $_.Name }); $n=Join-Path $d 'node.exe'; if(Test-Path -LiteralPath $n){ try { $h=[IO.File]::Open($n,'Open','ReadWrite','None'); $h.Close() } catch { exit 2 } }; $moved=@(); try { New-Item -ItemType Directory -Force -Path $p -ErrorAction Stop | Out-Null; foreach($i in $items){ Move-Item -LiteralPath $i.FullName -Destination (Join-Path $p $i.Name) -ErrorAction Stop; $moved+=$i.Name }; Copy-Item -LiteralPath (Join-Path $d '0 START PREPFIX CHURCH.bat') -Destination $p -Force -ErrorAction Stop } catch { foreach($n in $moved){ Move-Item -LiteralPath (Join-Path $p $n) -Destination (Join-Path $d $n) -Force -ErrorAction SilentlyContinue }; exit 1 }" >nul 2>&1
exit /b 0
