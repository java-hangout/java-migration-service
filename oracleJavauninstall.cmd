@echo off
setlocal

:: Define variables for registry keys and uninstaller paths
set REGISTRY_KEY_64="HKLM\SOFTWARE\JavaSoft\Java Runtime Environment"
set REGISTRY_KEY_32="HKLM\SOFTWARE\WOW6432Node\JavaSoft\Java Runtime Environment"
set UNINSTALL_KEY="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set JAVA_FOUND=false

:: Check if Oracle Java is installed by searching the registry in both 64-bit and 32-bit locations
echo Checking for Oracle Java installation...

:: Check 64-bit registry location
reg query "%REGISTRY_KEY_64%" >nul 2>&1
if %errorlevel%==0 (
    echo Oracle Java found (64-bit version).
    set JAVA_FOUND=true
)

:: Check 32-bit registry location if not found in 64-bit registry
if %JAVA_FOUND%==false (
    reg query "%REGISTRY_KEY_32%" >nul 2>&1
    if %errorlevel%==0 (
        echo Oracle Java found (32-bit version).
        set JAVA_FOUND=true
    )
)

:: If Java is found, try to find the uninstaller in the registry and uninstall it
if %JAVA_FOUND%==true (
    echo Searching for the uninstaller...
    reg query "%UNINSTALL_KEY%" /s /f "Java" > temp_uninstall.txt

    :: Check if the uninstall command is found
    findstr /i "uninstall" temp_uninstall.txt > nul

    if %errorlevel%==0 (
        for /f "tokens=2,*" %%a in ('findstr /i "uninstall" temp_uninstall.txt') do (
            set UNINSTALL_CMD=%%b
        )
        echo Uninstall command found: %UNINSTALL_CMD%

        :: Run the uninstaller silently
        echo Uninstalling Oracle Java...
        start /wait "" "%UNINSTALL_CMD%" /quiet /norestart
        echo Oracle Java has been uninstalled.
    ) else (
        echo Uninstall command not found in registry.
    )
) else (
    echo No Oracle Java installation detected. No action taken.
)

:: Clean up
del temp_uninstall.txt
endlocal
