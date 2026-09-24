@echo off
setlocal EnableDelayedExpansion
title Remove Printers

REM ============================================================
REM  Remove printer(s) by port
REM  Uses only: REG (listing) + printui.dll (deletion)
REM  No PowerShell, no WMIC required.
REM  Must be run as Administrator
REM ============================================================

REM ---- Admin check ----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] This script must be run as Administrator.
    echo  Right-click the file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

set "PRNKEY=HKLM\SYSTEM\CurrentControlSet\Control\Print\Printers"

REM ---- Build arrays of printer names and ports from the registry ----
set /a count=0
for /f "delims=" %%K in ('reg query "%PRNKEY%" ^| findstr /r /i "\\Printers\\[^\\]*$"') do (
    set "key=%%K"
    set "name=!key:*\Printers\=!"
    set "port="
    for /f "tokens=2,*" %%A in ('reg query "%%K" /v Port 2^>nul ^| findstr /i "REG_"') do set "port=%%B"
    set "pname[!count!]=!name!"
    set "pport[!count!]=!port!"
    set /a count+=1
)

if %count%==0 (
    echo  No printers found.
    echo.
    pause
    exit /b 0
)

echo.
echo  === Installed Printers ===
echo  Name                                                Port
echo  --------------------------------------------------  ----------------
for /l %%i in (0,1,%count%) do if %%i lss %count% (
    set "n=!pname[%%i]!                                               "
    set "p=!pport[%%i]!                                                "
    echo  !n:~0,50!!p:~0,40!
)
echo.

REM ---- Build unique port list ----
set /a portCount=0
for /l %%i in (0,1,%count%) do if %%i lss %count% (
    set "pt=!pport[%%i]!"
    set "dup=0"
    for /l %%j in (0,1,%portCount%) do if %%j lss %portCount% (
        if /i "!uport[%%j]!"=="!pt!" set "dup=1"
    )
    if !dup!==0 (
        set "uport[!portCount!]=!pt!"
        set /a portCount+=1
    )
)

REM ---- Step 1: select a port ----
echo  === Available Ports ===
for /l %%i in (0,1,%portCount%) do if %%i lss %portCount% (
    if "!uport[%%i]!"=="" (echo  [%%i] ^(no port^)) else (echo  [%%i] !uport[%%i]!)
)
echo.
set /p portSel=Enter the number of the port: 

echo %portSel%|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :invalid
if %portSel% geq %portCount% goto :invalid
goto :step2

:invalid
echo.
echo  Invalid selection.
pause
exit /b 1

REM ---- Step 2: select printer(s) on that port ----
:step2
set "targetPort=!uport[%portSel%]!"
set /a onPort=0
for /l %%i in (0,1,%count%) do if %%i lss %count% (
    if /i "!pport[%%i]!"=="!targetPort!" (
        set "onName[!onPort!]=!pname[%%i]!"
        set /a onPort+=1
    )
)

echo.
echo  Printers on port '!targetPort!':
for /l %%i in (0,1,%onPort%) do if %%i lss %onPort% (
    echo  [%%i] !onName[%%i]!
)
echo  [A] Remove ALL printers on this port
echo.
set /p printerSel=Enter printer number ^(or A for all^): 

if /i "!printerSel!"=="A" goto :removeAll
echo %printerSel%|findstr /r "^[0-9][0-9]*$" >nul
if errorlevel 1 goto :invalid
if %printerSel% geq %onPort% goto :invalid
goto :confirmOne

REM ---- Remove ALL on the port ----
:removeAll
echo.
echo  The following printers will be REMOVED:
for /l %%i in (0,1,%onPort%) do if %%i lss %onPort% echo    - !onName[%%i]!
goto :confirm

REM ---- Remove ONE ----
:confirmOne
echo.
echo  The following printer will be REMOVED:
echo    - !onName[%printerSel%]!

:confirm
echo.
set /p confirm=Type YES to confirm: 
if /i not "!confirm!"=="YES" (
    echo.
    echo  Cancelled.
    pause
    exit /b 0
)

if /i "!printerSel!"=="A" (
    for /l %%i in (0,1,%onPort%) do if %%i lss %onPort% (
        echo  Removing printer: !onName[%%i]! ...
        rundll32 printui.dll,PrintUIEntry /dl /n "!onName[%%i]!" /q
    )
) else (
    echo  Removing printer: !onName[%printerSel%]! ...
    rundll32 printui.dll,PrintUIEntry /dl /n "!onName[%printerSel%]!" /q
)

echo.
echo  Done. If a printer is still listed, restart the PC or run:
echo    net stop spooler ^&^& net start spooler
echo.
pause
endlocal
