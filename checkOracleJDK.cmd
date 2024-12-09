@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Step 1: Check if Java is installed and determine its version
echo Checking if Java is installed...

:: Check if java is available in the path
where java > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Java is not installed on your system.
    goto end
)

:: Get the Java version
java -version 2>&1 | findstr "version" > temp_version.txt
set /p java_version=<temp_version.txt

:: Output the Java version found
echo Java Version Found: %java_version%

:: Step 2: Check if Oracle JDK is installed
echo Checking if Oracle JDK is installed...

:: Look for Oracle JDK specific strings in the version output
echo %java_version% | findstr /i "Oracle" > nul
IF %ERRORLEVEL% EQU 0 (
    echo Oracle JDK detected. Proceeding to uninstall Oracle JDK...

    :: Search for the Oracle JDK uninstaller in the registry
    for /f "tokens=3" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Oracle JDK" ^| findstr "UninstallString"') do (
        set uninstall_command=%%a
    )

    IF NOT "!uninstall_command!"=="" (
        echo Uninstalling Oracle JDK using: !uninstall_command!
        "!uninstall_command!" /quiet /norestart
    ) ELSE (
        echo Oracle JDK uninstaller not found. You may need to manually uninstall Oracle JDK.
    )
)

:: Step 3: Check if OpenJDK is already installed
echo Checking if OpenJDK is installed...

:: Search for OpenJDK in the system
where java > nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Java (OpenJDK) is not installed. Proceeding to install OpenJDK...
    goto install_openjdk
)

:: If OpenJDK is already installed, do nothing
echo OpenJDK is already installed. Skipping installation.

goto end

:: Step 4: Install OpenJDK
:install_openjdk
echo Installing OpenJDK...

:: Assuming OpenJDK has already been downloaded (e.g., "openjdk-17_windows-x64_bin.zip").
:: If not, you can automate this download step, or simply extract the downloaded file to the appropriate location.

:: For example, assuming OpenJDK is downloaded as "openjdk-17_windows-x64_bin.zip"
:: and extracted to "C:\OpenJDK" (update with actual OpenJDK download and extraction details).
set OPENJDK_PATH="C:\OpenJDK\jdk-17"

:: Verify that the OpenJDK path exists
IF NOT EXIST %OPENJDK_PATH%\bin\java.exe (
    echo OpenJDK not found at %OPENJDK_PATH%. Please ensure that OpenJDK is downloaded and extracted correctly.
    goto end
)

echo OpenJDK installation path: %OPENJDK_PATH%

:: Step 5: Set JAVA_HOME and update PATH environment variables
echo Setting JAVA_HOME and PATH environment variables...

setx JAVA_HOME "%OPENJDK_PATH%"
setx PATH "%PATH%;%OPENJDK_PATH%\bin"

:: Step 6: Verify Java installation and environment variables
echo Verifying OpenJDK installation...
java -version
echo JAVA_HOME is set to: %JAVA_HOME%
echo PATH is set correctly.

goto end

:end
echo Script completed.
pause
