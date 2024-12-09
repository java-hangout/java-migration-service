@echo off
setlocal

:: Check if Java is installed by looking for java in the system PATH
echo Checking if Java is installed...

where java >nul 2>nul
if %errorlevel% == 0 (
    echo Java is installed. Now checking if it's Oracle Java...
) else (
    echo Java is not installed.
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

:: Look for UninstallString entries
echo Looking for uninstall commands...
findstr /i "UninstallString" temp_registry.txt

:: Extract uninstall commands and uninstall Oracle Java
for /f "tokens=2,* delims==" %%I in ('findstr /i "UninstallString" temp_registry.txt') do (
    set uninstallCmd=%%J
    echo Found uninstall command: %uninstallCmd%
    if defined uninstallCmd (
        echo Uninstalling Oracle Java...
        start /wait "" %uninstallCmd%
        echo Oracle Java has been uninstalled.
    )
)

:: Fallback if UninstallString is not found, try to uninstall using msiexec
echo If uninstall string is missing, attempting to uninstall via msiexec...
msiexec /x {26A24AE4-039D-4CA4-87B4-2F64180191F0} /quiet /norestart
msiexec /x {64A3A4F4-B792-11D6-A78A-00B0D0180191} /quiet /norestart

:: Remove JAVA_HOME from the system environment variables if it exists
echo Checking if JAVA_HOME and PATH variables exist...

:: Remove JAVA_HOME from the user environment variables if it exists
reg query "HKCU\Environment" /f "JAVA_HOME" >nul 2>&1
if %errorlevel% == 0 (
    echo JAVA_HOME found. Removing JAVA_HOME variable...
    reg delete "HKCU\Environment" /f /v "JAVA_HOME"
) else (
    echo JAVA_HOME not found in user variables.
)

:: Clean PATH from JAVA_HOME reference
echo Cleaning PATH environment variable...

:: Get current PATH value for the user (from registry)
for /f "tokens=2,*" %%A in ('reg query "HKCU\Environment" /v "Path" 2^>nul') do set pathVar=%%B

:: Check if PATH contains the JAVA_HOME\bin reference and remove it
echo Checking if PATH contains %JAVA_HOME%\bin...

:: Remove all instances of %JAVA_HOME%\bin from the PATH variable
set newPath=%pathVar%
set changed=true

:removePath
:: Loop until %JAVA_HOME%\bin is no longer found
if "%newPath%" neq "%pathVar%" (
    set pathVar=%newPath%
    set newPath=%newPath:%JAVA_HOME%\bin;=%
    set newPath=%newPath%;%JAVA_HOME%\bin=%
    set newPath=%newPath:%JAVA_HOME%\bin%=%
    goto removePath
)

:: Update the PATH with the cleaned value
setx PATH "%newPath%" >nul
echo %JAVA_HOME%\bin reference removed from PATH.

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed.
pause
