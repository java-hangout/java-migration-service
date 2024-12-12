@echo off
setlocal enabledelayedexpansion

:: Define log file
set LOG_FILE=uninstall_log.txt

:: Create/clear the log file and add the current date and time
echo Uninstallation Log > %LOG_FILE%
echo ===================== >> %LOG_FILE%

:: Add current date and time to the log
echo Log generated on: %date% %time% >> %LOG_FILE%
echo ===================== >> %LOG_FILE%

:: Check if Java is installed by looking for java in the system PATH
echo Checking if Java is installed... >> %LOG_FILE%

where java >nul 2>nul
if %errorlevel% == 0 (
    echo Java is installed. Now checking if it's Oracle Java... >> %LOG_FILE%
) else (
    echo Oracle Java is not installed. Exiting script. >> %LOG_FILE%
    goto end
)

:: Check for Oracle Java installation in the 64-bit registry location
echo Checking for Oracle Java installation in the 64-bit registry... >> %LOG_FILE%

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle" 2>nul > temp_registry_64.txt
echo Checking if Oracle Java is in the 64-bit registry... >> %LOG_FILE%
type temp_registry_64.txt >> %LOG_FILE%

:: Check for Oracle Java installation in the 32-bit registry location
echo Checking for Oracle Java installation in the 32-bit registry... >> %LOG_FILE%

reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle" 2>nul > temp_registry_32.txt
echo Checking if Oracle Java is in the 32-bit registry... >> %LOG_FILE%
type temp_registry_32.txt >> %LOG_FILE%

:: Combine both registry outputs into one file for easier processing
type temp_registry_64.txt >> temp_registry.txt
type temp_registry_32.txt >> temp_registry.txt

:: Look for UninstallString entries and dynamically extract uninstall commands
echo Looking for uninstall commands... >> %LOG_FILE%

:: Extract uninstall commands and uninstall Oracle Java
for /f "tokens=2,* delims==" %%I in ('findstr /i "UninstallString" temp_registry.txt') do (
    set uninstallCmd=%%J
    echo Found uninstall command: !uninstallCmd! >> %LOG_FILE%
    if defined uninstallCmd (
        echo Uninstalling Oracle Java using uninstall string... >> %LOG_FILE%
        start /wait "" !uninstallCmd! /quiet /norestart
        if %errorlevel% == 0 (
            echo Oracle Java has been uninstalled successfully using uninstall string. >> %LOG_FILE%
        ) else (
            echo Failed to uninstall Oracle Java using uninstall string. Error code: %errorlevel%. >> %LOG_FILE%
        )
    ) else (
        echo No uninstall string found for Oracle Java. >> %LOG_FILE%
    )
)

:: Fallback if UninstallString is not found, attempt to uninstall using msiexec with dynamic GUIDs
echo If uninstall string is missing, attempting to uninstall via msiexec... >> %LOG_FILE%

:: Extract GUIDs from registry dynamically and use them with msiexec
for /f "tokens=2 delims={}" %%A in ('findstr /r "{[0-9A-F]*-[0-9A-F]*-[0-9A-F]*-[0-9A-F]*-[0-9A-F]*}" temp_registry.txt') do (
    set GUID={%%A}
    echo Trying to uninstall Java using GUID: !GUID! >> %LOG_FILE%
    msiexec /x !GUID! /quiet /norestart
    if %errorlevel% == 0 (
        echo Oracle Java has been uninstalled successfully using GUID: !GUID! >> %LOG_FILE%
    ) else (
        echo Failed to uninstall Oracle Java using GUID: !GUID!. Error code: %errorlevel%. >> %LOG_FILE%
    )
)

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed. >> %LOG_FILE%
echo ===================== >> %LOG_FILE%
echo Log file generated: %LOG_FILE%
pause
