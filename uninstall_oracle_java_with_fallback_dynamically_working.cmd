@echo off
setlocal enabledelayedexpansion

:: Check if Java is installed by looking for java in the system PATH
echo Checking if Java is installed...

where java >nul 2>nul
if %errorlevel% == 0 (
    echo Java is installed. Now checking if it's Oracle Java...
) else (
    echo Oracle Java is not installed.
    goto end
)

:: Check for Oracle Java installation in the 64-bit registry location
echo Checking for Oracle Java installation in the 64-bit registry...

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle" 2>nul > temp_registry_64.txt
echo Checking if Oracle Java is in the 64-bit registry...
type temp_registry_64.txt

:: Check for Oracle Java installation in the 32-bit registry location
echo Checking for Oracle Java installation in the 32-bit registry...

reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle" 2>nul > temp_registry_32.txt
echo Checking if Oracle Java is in the 32-bit registry...
type temp_registry_32.txt

:: Combine both registry outputs into one file for easier processing
type temp_registry_64.txt >> temp_registry.txt
type temp_registry_32.txt >> temp_registry.txt

:: Look for UninstallString entries and extract uninstall commands
echo Looking for uninstall commands...
findstr /i "UninstallString" temp_registry.txt

:: Extract uninstall commands and uninstall Oracle Java
for /f "tokens=2,* delims==" %%I in ('findstr /i "UninstallString" temp_registry.txt') do (
    set uninstallCmd=%%J
    echo Found uninstall command: !uninstallCmd!
    if defined uninstallCmd (
        echo Uninstalling Oracle Java...
        start /wait "" !uninstallCmd!
        echo Oracle Java has been uninstalled.
    )
)

:: Fallback if UninstallString is not found, attempt to uninstall using msiexec with known GUIDs
echo If uninstall string is missing, attempting to uninstall via msiexec...

:: GUIDs from the registry for Oracle Java JDK and JRE
msiexec /x {26A24AE4-039D-4CA4-87B4-2F64180191F0} /quiet /norestart
msiexec /x {64A3A4F4-B792-11D6-A78A-00B0D0180191} /quiet /norestart

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed.
pause
