@echo off
REM Check if any version of Java is installed (Check if java command is available)
java -version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    echo No version of Java OpenJDK found... Installing Eclipse Adoptium OpenJDK 17...

    REM Set the path to the already downloaded OpenJDK
    SET LOCAL_JDK_PATH=D:\OSBI\OpenJDK\jdk-17

    REM Debug: Print the LOCAL_JDK_PATH to make sure it's correct
    echo LOCAL_JDK_PATH is: "%LOCAL_JDK_PATH%"

    REM Check if the OpenJDK folder exists and contains java.exe
    IF EXIST "%LOCAL_JDK_PATH%\bin\java.exe" (
        echo Found already downloaded OpenJDK at %LOCAL_JDK_PATH%.

        REM Set the install directory (where you want to install OpenJDK)
        SET INSTALL_DIR=C:\Program Files\Adoptium

        REM Debug: Print INSTALL_DIR to make sure it's correct
        echo INSTALL_DIR is: %INSTALL_DIR%

        REM Optionally, create the install directory if it doesn't exist
        IF NOT EXIST "%INSTALL_DIR%" (
            mkdir "%INSTALL_DIR%"
        )

        REM Copy OpenJDK from the local directory to the install directory
        echo Installing OpenJDK from local directory...
        xcopy /E /I /H /Y "%LOCAL_JDK_PATH%" "%INSTALL_DIR%\jdk-17"

        REM Set environment variables using setx to make them persistent across all sessions
        REM Correct the usage of setx for JAVA_HOME
        setx JAVA_HOME "%INSTALL_DIR%\jdk-17"

        REM Fix for PATH variable (append the bin directory to PATH)
        REM Get current PATH value and append the bin directory
        set "CURRENT_PATH=%PATH%"
        set "NEW_PATH=%JAVA_HOME%\bin"
        setx PATH "%CURRENT_PATH%;%NEW_PATH%"

        REM Confirm Java installation
        echo Eclipse Adoptium OpenJDK 17 has been installed from the local directory.
        java -version
    ) ELSE (
        echo OpenJDK 17 was not found in the specified directory: %LOCAL_JDK_PATH%. Please check the path.
    )
) ELSE (
    REM Capture the first line of java -version output (which contains the version number)
    for /f "tokens=1,2 delims= " %%a in ('java -version 2^>^&1') do (
        if "%%a"=="openjdk" set INSTALLED_JAVA_VERSION=%%a %%b
    )

    REM Output the installed Java version
    echo Java OpenJDK is already installed. Installed version: %INSTALLED_JAVA_VERSION%
)

pause
