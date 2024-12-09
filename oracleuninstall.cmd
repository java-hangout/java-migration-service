@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Step 1: Check if Java is installed
echo Checking if Java is installed...Veeresh

:: Check if java is available in the path
where java > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Java is not installed on your system.
    goto end
)

:: Step 2: Get Java version
echo Checking Java version...
java -version 2>&1 | findstr "version" > temp_version.txt
set /p java_version=<temp_version.txt

:: Output the Java version found
echo Java Version Found: %java_version%

:: Step 3: Check if Oracle JDK is installed via registry lookup
echo Checking if Oracle JDK is installed...

:: Search for "Oracle" in the registry to identify Oracle JDK installations
for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle JDK" ^| findstr "DisplayName"') do (
    set oracle_installed=%%a
)

:: Search in the 32-bit registry path for Oracle JDK installations on 64-bit systems
for /f "tokens=3" %%c in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle JDK" ^| findstr "DisplayName"') do (
    set oracle_installed=%%c
)

:: Check if Oracle JDK was found in the registry
IF DEFINED oracle_installed (
    echo Oracle JDK detected in the registry. Proceeding to uninstall Oracle JDK...

    :: Search for the Oracle JDK uninstaller in the registry
    for /f "tokens=3" %%b in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle JDK" ^| findstr "UninstallString"') do (
        set uninstall_command=%%b
    )

    :: Check the 32-bit registry path for the uninstaller
    for /f "tokens=3" %%d in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle JDK" ^| findstr "UninstallString"') do (
        set uninstall_command=%%d
    )

    IF NOT "!uninstall_command!"=="" (
        echo Uninstalling Oracle JDK using: !uninstall_command!
        "!uninstall_command!" /quiet /norestart
        echo Oracle JDK has been uninstalled.
    ) ELSE (
        echo Oracle JDK uninstaller not found in the registry. Please uninstall Oracle JDK manually.
    )
) ELSE (
    echo Oracle JDK not found in the registry or Java version output. This may be OpenJDK or another variant.
)

:end
echo Script completed.
pause
