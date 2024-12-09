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

:: Look for UninstallString entries and extract uninstall commands dynamically
echo Looking for uninstall commands...

for /f "tokens=2,* delims==" %%I in ('findstr /i "UninstallString" temp_registry.txt') do (
    set uninstallCmd=%%J
    echo Found uninstall command: !uninstallCmd!
    if defined uninstallCmd (
        echo Uninstalling Oracle Java...
        start /wait "" !uninstallCmd!
        echo Oracle Java has been uninstalled.
    )
)

:: Fallback if UninstallString is not found, attempt to uninstall via msiexec using dynamic GUIDs from the registry
echo If uninstall string is missing, attempting to uninstall via msiexec...

:: Extract GUIDs from the registry dynamically and use them with msiexec
for /f "tokens=3" %%A in ('findstr /i "Uninstall" temp_registry.txt') do (
    echo Trying to uninstall Java using GUID: %%A
    msiexec /x %%A /quiet /norestart
)

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed.
pause
