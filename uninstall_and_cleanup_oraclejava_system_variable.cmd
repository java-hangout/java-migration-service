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

:: Remove JAVA_HOME from the user environment variables if it exists
echo Checking if JAVA_HOME and PATH variables exist in user variables...

:: Remove JAVA_HOME from the user environment variables if it exists
reg query "HKCU\Environment" /f "JAVA_HOME" >nul 2>&1
if %errorlevel% == 0 (
    echo JAVA_HOME found in user variables. Removing JAVA_HOME...
    reg delete "HKCU\Environment" /f /v "JAVA_HOME"
) else (
    echo JAVA_HOME not found in user variables.
)

:: Clean PATH from JAVA_HOME reference in user variables
echo Cleaning user-level PATH environment variable...

:: Get current user-level PATH value
for /f "tokens=2,*" %%A in ('reg query "HKCU\Environment" /v "Path" 2^>nul') do set pathVar=%%B

:: Remove all instances of %JAVA_HOME%\bin from the user-level PATH variable
set newPath=%pathVar%
set changed=true

:removeUserPath
:: Loop until %JAVA_HOME%\bin is no longer found
if "%newPath%" neq "%pathVar%" (
    set pathVar=%newPath%
    set newPath=%newPath:%JAVA_HOME%\bin;=%
    set newPath=%newPath%;%JAVA_HOME%\bin=%
    set newPath=%newPath:%JAVA_HOME%\bin%=%
    goto removeUserPath
)

:: Update the user-level PATH with the cleaned value
setx PATH "%newPath%" >nul
echo %JAVA_HOME%\bin reference removed from user-level PATH.

:: Now, handle system-level JAVA_HOME and PATH variables
echo Checking if JAVA_HOME and PATH variables exist in system variables...

:: Remove JAVA_HOME from the system environment variables if it exists
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f "JAVA_HOME" >nul 2>&1
if %errorlevel% == 0 (
    echo JAVA_HOME found in system variables. Removing JAVA_HOME...
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f /v "JAVA_HOME"
) else (
    echo JAVA_HOME not found in system variables.
)

:: Clean PATH from JAVA_HOME reference in system variables
echo Cleaning system-level PATH environment variable...

:: Get current system-level PATH value
for /f "tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v "Path" 2^>nul') do set pathVar=%%B

:: Remove all instances of %JAVA_HOME%\bin from the system-level PATH variable
set newPath=%pathVar%
set changed=true

:removeSystemPath
:: Loop until %JAVA_HOME%\bin is no longer found
if "%newPath%" neq "%pathVar%" (
    set pathVar=%newPath%
    set newPath=%newPath:%JAVA_HOME%\bin;=%
    set newPath=%newPath%;%JAVA_HOME%\bin=%
    set newPath=%newPath:%JAVA_HOME%\bin%=%
    goto removeSystemPath
)

:: Update the system-level PATH with the cleaned value
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /f /v "Path" /d "%newPath%"
echo %JAVA_HOME%\bin reference removed from system-level PATH.

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed.
pause
