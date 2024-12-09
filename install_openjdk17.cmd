@echo off
REM Check if any version of Java is installed (Check if java command is available)
java -version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    echo No version of Java (OpenJDK) found. Installing Eclipse Adoptium OpenJDK 17...

    REM Set the Adoptium version and download URL (Eclipse Temurin OpenJDK 17)
    SET JDK_VERSION=17
    SET JDK_URL=https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17%2B35/OpenJDK17U-jdk_x64_windows_hotspot_17_35.zip
    SET INSTALL_DIR=C:\Program Files\Adoptium

    REM Create the install directory if it doesn't exist
    IF NOT EXIST "%INSTALL_DIR%" (
        mkdir "%INSTALL_DIR%"
    )

    REM Download Eclipse Adoptium OpenJDK 17 zip file
    echo Downloading Eclipse Adoptium OpenJDK 17 from %JDK_URL%
    powershell -Command "Invoke-WebRequest -Uri %JDK_URL% -OutFile %INSTALL_DIR%\openjdk17.zip"

    REM Extract the downloaded zip file
    echo Extracting OpenJDK...
    powershell -Command "Expand-Archive -Path %INSTALL_DIR%\openjdk17.zip -DestinationPath %INSTALL_DIR% -Force"

    REM Remove the zip file after extraction
    del "%INSTALL_DIR%\openjdk17.zip"

    REM Set environment variables (Optional, if you want it globally available)
    setx JAVA_HOME "%INSTALL_DIR%\jdk-17"
    setx PATH "%PATH%;%INSTALL_DIR%\jdk-17\bin"

    REM Confirm Java installation
    echo Eclipse Adoptium OpenJDK 17 has been installed successfully.
    java -version
) ELSE (
    echo Java (OpenJDK) is already installed. No action required.
)

pause
