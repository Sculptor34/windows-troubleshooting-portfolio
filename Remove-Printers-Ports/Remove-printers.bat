@echo off
setlocal EnableDelayedExpansion
title Remove Printers

REM ============================================================
REM  Remove printer(s) by port  (Batch / WMIC version)
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

REM ---- Get a real carriage-return char (strips trailing CR from WMIC output) ----
for /f %%C in ('copy /z "%~f0" nul') do set "CR=%%C"

echo.
echo  === Installed Printers ===
wmic printer get name, portname
echo.

REM ---- Build arrays of printer names and ports ----
set /a count=0
set "curName="
for /f "usebackq delims=" %%L in (`wmic printer get name^,portname /format:list`) do (
    set "line=%%L"
    if /i "!line:~0,9!"=="PortName=" (
        set "val=!line:~9!"
        if "!val:~-1!"=="!CR!" set "val=!val:~0,-1!"
        if defined curName (
            set "pname[!count!]=!curName!"
            set "pport[!count!]=!val!"
            set /a count+=1
            set "curName="
        )
    ) else if /i "!line:~0,5!"=="Name=" (
        set "curName=!line:~5!"
        if "!curName:~-1!"=="!CR!" set "curName=!curName:~0,-1!"
    )
)

if %count%==0 (
    echo  No printers found.
    echo.
    pause
    exit /b 0
)

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
    echo  [%%i] !uport[%%i]!
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
        wmic printer where "name='!onName[%%i]!'" delete | findstr /i "ReturnValue"
    )
) else (
    echo  Removing printer: !onName[%printerSel%]! ...
    wmic printer where "name='!onName[%printerSel%]!'" delete | findstr /i "ReturnValue"
)

echo.
echo  Done.  (ReturnValue = 0 means success)
echo.
pause
endlocal
