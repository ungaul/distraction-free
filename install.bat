@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM Ensure this script runs as Administrator
net session >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo This script requires administrative privileges.
    powershell -Command "Start-Process cmd -ArgumentList '/c, %~dp0%~nx0' -Verb runAs"
    exit /b
)

echo Running with administrative privileges.
echo ********************************************
echo *         HOSTS FILE BLOCKING SCRIPT       *
echo ********************************************

REM Modify DNS Client service startup to manual
echo Changing DNS Client service to manual startup...
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache" /v Start /t REG_DWORD /d 3 /f
if %errorlevel% neq 0 (
    echo Failed to modify the DNS Client service startup setting.
) else (
    echo DNS Client service startup successfully changed to manual.
)

REM Check if Python is installed
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Downloading Python...
    start "" "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
    pause
    exit /b
)

REM Install pip if not available
python -m ensurepip >nul 2>&1
python -m pip install requests >nul 2>&1

REM Fetch the full data from Google Sheets
echo Fetching data from Google Sheets...
python -c "import requests, json; url = 'https://script.google.com/macros/s/AKfycbwrJQrVhmVNy7jXBtJsJit5CU6S683O-4ILwkl8WUtEmwkigds9Pdg2nSxWPtn6oY2vJQ/exec'; r = requests.get(url); data = r.json(); open('google_sheets_data.json', 'w', encoding='utf-8').write(json.dumps(data, indent=4))"

REM Ask the user to select sheets
echo.
echo "Select the sheets you want to include (separate choices with commas):"
echo "1) Porn"
echo "2) Gambling"
echo "3) Social"
echo "4) Fake News"
echo "5) Adware/Malware"
set /p sheets="Enter the numbers of the sheets to include (e.g., 1,3,5): "

REM Map numbers to sheet names using a dictionary-like approach
setlocal enabledelayedexpansion
set "sheet_map[1]=Porn"
set "sheet_map[2]=Gambling"
set "sheet_map[3]=Social"
set "sheet_map[4]=Fake News"
set "sheet_map[5]=Adware/Malware"

set selected_sheets=
for %%a in (%sheets%) do (
    set "sheet=!sheet_map[%%a]!"
    set selected_sheets=!selected_sheets!!sheet!,
)
set selected_sheets=%selected_sheets:~0,-1%

REM Filter the JSON data based on selected sheets
python -c "import json; sheets = '%selected_sheets%'.split(','); data = json.load(open('google_sheets_data.json')); filtered_data = {sheet: data[sheet] for sheet in sheets if sheet in data}; open('filtered_data.txt', 'w').write('\n'.join([address for sublist in filtered_data.values() for address in sublist]))"

REM Backup the current hosts file (optional)
copy %SystemRoot%\System32\drivers\etc\hosts %SystemRoot%\System32\drivers\etc\hosts_backup >nul

REM Empty the hosts file
echo. > %SystemRoot%\System32\drivers\etc\hosts

REM Add the filtered addresses to the hosts file
echo Blocking the addresses in the hosts file...
(
    for /f %%A in (filtered_data.txt) do (
        echo 127.0.0.1 %%A
    )
) >> %SystemRoot%\System32\drivers\etc\hosts

echo Addresses have been blocked.

REM Ask the user if they want to hide and lock the hosts file
echo.
set /p choice="Do you want to hide and block the hosts file? (y/n): "
if /i "%choice%"=="y" (
    echo Hiding and blocking the hosts file...
    
    REM Hide the hosts file
    attrib +h %SystemRoot%\System32\drivers\etc\hosts
    
    REM Block the hosts file by removing write permissions
    icacls %SystemRoot%\System32\drivers\etc\hosts /deny *S-1-1-0:W
    
    echo Hosts file has been hidden and blocked.
) else (
    echo Hosts file will not be hidden or blocked.
)

echo Script execution complete.
pause
