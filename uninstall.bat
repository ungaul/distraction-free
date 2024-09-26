@echo off
chcp 65001 >nul

REM Ensure this script runs as Administrator
net session >nul 2>&1
if '%errorlevel%' NEQ '0' (
    echo This script requires administrative privileges.
    powershell -Command "Start-Process cmd -ArgumentList '/c, %~dp0%~nx0' -Verb runAs"
    exit /b
)

echo Running with administrative privileges.
echo ********************************************
echo *        HOSTS FILE UNBLOCKING SCRIPT      *
echo ********************************************

REM Restore rights to the hosts file
echo Restoring write permissions to the hosts file...
icacls %SystemRoot%\System32\drivers\etc\hosts /grant *S-1-1-0:W
if %errorlevel% neq 0 (
    echo Failed to restore write permissions.
) else (
    echo Write permissions successfully restored.
)

REM Remove the hidden attribute
echo Removing hidden attribute from the hosts file...
attrib -h %SystemRoot%\System32\drivers\etc\hosts
if %errorlevel% neq 0 (
    echo Failed to remove hidden attribute.
) else (
    echo Hidden attribute successfully removed.
)

REM Empty the hosts file
echo Emptying the hosts file...
echo. > %SystemRoot%\System32\drivers\etc\hosts
if %errorlevel% neq 0 (
    echo Failed to empty the hosts file.
) else (
    echo Hosts file successfully emptied.
)

echo Uninstallation complete.
pause
