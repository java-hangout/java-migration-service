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

:: Remove JAVA_HOME and PATH environment variables if they exist
echo Checking if JAVA_HOME and PATH variables exist...

:: Remove JAVA_HOME from the system environment variables if it exists
reg query "HKCU\Environment" /f "JAVA_HOME" >nul 2>&1
if %errorlevel% == 0 (
    echo JAVA_HOME found. Removing JAVA_HOME variable...
    reg delete "HKCU\Environment" /f /v "JAVA_HOME"
) else (
    echo JAVA_HOME not found.
)

:: Remove any JAVA_HOME references from the PATH variable
echo Removing any JAVA_HOME references from PATH...
set pathStr=%PATH%
echo %pathStr% | findstr /i "JAVA_HOME" >nul
if %errorlevel% == 0 (
    echo JAVA_HOME found in PATH. Removing JAVA_HOME reference from PATH...
    setx PATH "%pathStr:"C:\Program Files\Java\jdk1.8.0_191\bin"=%"
) else (
    echo No JAVA_HOME reference found in PATH.
)

:: Clean up the temporary files
del temp_registry.txt
del temp_registry_64.txt
del temp_registry_32.txt

:end
echo Script execution completed.
pause
