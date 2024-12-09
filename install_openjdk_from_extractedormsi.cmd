@echo off
REM Check if any version of Java is installed (Check if java command is available)
java -version >nul 2>&1

IF %ERRORLEVEL% NEQ 0 (
    echo No version of Java OpenJDK found... Installing Eclipse Adoptium OpenJDK 17...

    REM Check if the OpenJDK directory exists (local folder installation)
    SET LOCAL_JDK_PATH=D:\OSBI\OpenJDK

    REM Debug: Print the LOCAL_JDK_PATH to make sure it's correct
    echo LOCAL_JDK_PATH is: "%LOCAL_JDK_PATH%"

    REM Check if the local OpenJDK folder contains the required files
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
        setx JAVA_HOME "%INSTALL_DIR%\jdk-17"

        REM Fix for PATH variable (append the bin directory to PATH)
        set "CURRENT_PATH=%PATH%"
        set "NEW_PATH=%JAVA_HOME%\bin"
        setx PATH "%CURRENT_PATH%;%NEW_PATH%"

        REM Confirm Java installation
        echo Eclipse Adoptium OpenJDK 17 has been installed from the local directory.
        java -version

    ) ELSE (
        REM If OpenJDK is not found in the local folder, attempt installation from MSI file
        SET LOCAL_JDK_PATH=D:\OSBI\OpenJDK\msi

        REM Debug: Print the LOCAL_JDK_PATH to make sure it's correct
        echo LOCAL_JDK_PATH is: "%LOCAL_JDK_PATH%"

        REM Check if the MSI installer exists
        IF EXIST "%LOCAL_JDK_PATH%\OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.msi" (
            echo Found OpenJDK 17 .msi installer at %LOCAL_JDK_PATH%.

            REM Set the install directory (where you want to install OpenJDK)
            SET INSTALL_DIR=C:\OpenJDK\Adoptium

            REM Debug: Print INSTALL_DIR to make sure it's correct
            echo INSTALL_DIR is: %INSTALL_DIR%

            REM Optionally, create the install directory if it doesn't exist
            IF NOT EXIST "%INSTALL_DIR%" (
                mkdir "%INSTALL_DIR%"
            )

            REM Run the MSI installer to install OpenJDK
            echo Installing OpenJDK 17 from MSI file...
            msiexec /i "%LOCAL_JDK_PATH%\OpenJDK17U-jdk_x64_windows_hotspot_17.0.13_11.msi" /quiet /norestart

            REM Add some delay to ensure installation is completed
            echo Waiting for installation to complete...
            timeout /t 5 /nobreak >nul

            REM Check if the installation was successful by looking for the JDK folder
            IF EXIST "%INSTALL_DIR%\jdk-17\bin\java.exe" (
                REM Set environment variables using setx to make them persistent across all sessions
                echo Setting environment variables...
                setx JAVA_HOME "%INSTALL_DIR%\jdk-17"
                set "CURRENT_PATH=%PATH%"
                set "NEW_PATH=%INSTALL_DIR%\jdk-17\bin"
                setx PATH "%CURRENT_PATH%;%NEW_PATH%"

                REM Confirm Java installation
                echo Eclipse Adoptium OpenJDK 17 has been installed successfully.
                java -version

            ) ELSE (
                echo Installation failed: Could not find Java after installation. Checking installation location...

                REM Check alternative installation paths
                IF EXIST "C:\Program Files\Adoptium\jdk-17\bin\java.exe" (
                    echo Found Java in the alternative path.
                    setx JAVA_HOME "C:\Program Files\Adoptium\jdk-17"
                    set "CURRENT_PATH=%PATH%"
                    set "NEW_PATH=C:\Program Files\Adoptium\jdk-17\bin"
                    setx PATH "%CURRENT_PATH%;%NEW_PATH%"
                    java -version
                ) ELSE (
                    echo Failed to install Java OpenJDK 17. Please check the installation path manually.
                )
            )
        ) ELSE (
            echo OpenJDK 17 .msi installer not found in the specified directory: %LOCAL_JDK_PATH%. Please check the path.
        )
    )
) ELSE (
    REM Capture the installed Java version
    for /f "tokens=1,2 delims= " %%a in ('java -version 2^>^&1') do (
        if "%%a"=="openjdk" set INSTALLED_JAVA_VERSION=%%a %%b
    )

    REM Output the installed Java version
    echo Java OpenJDK is already installed. Installed version: %INSTALLED_JAVA_VERSION%
)

pause
