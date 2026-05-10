@echo off
chcp 936 >nul 2>&1
title Harmony Health - Backend Server Launcher
color 0A

echo.
echo ============================================================
echo           Harmony Health System - Backend Launcher v1.0
echo ============================================================
echo.

:: Step 1: Check Java Environment
echo [1/5] Checking Java environment...
java -version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Java not found!
    echo.
    echo Please install JDK 8 or higher:
    echo   Download: https://adoptium.net/
    echo   After installation, please restart this script
    echo.
    pause
    exit /b 1
)
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
    set JAVA_VERSION=%%v
)
echo [OK] Java version: %JAVA_VERSION%

:: Step 2: Check Maven Environment
echo.
echo [2/5] Checking Maven...
mvn -version >nul 2>&1
if errorlevel 1 (
    echo [WARN] Maven not found, trying mvnw wrapper...
    if not exist mvnw (
        echo [ERROR] Neither Maven nor mvnw found!
        echo.
        echo Please install Apache Maven:
        echo   Download: https://maven.apache.org/download.cgi
        pause
        exit /b 1
    )
) else (
    for /f "tokens=3" %%v in ('mvn -version 2^>^&1 ^| findstr /i "Apache Maven"') do (
        set MVN_VERSION=%%v
    )
    echo [OK] Apache Maven: %MVN_VERSION%
)

:: Step 3: Check MySQL Connection
echo.
echo [3/5] Checking MySQL database connection...
mysql -u root -p123456 -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [WARN] Cannot connect to MySQL database!
    echo.
    echo Please confirm:
    echo   - MySQL service is running (services.msc -> MySQL -> Start)
    echo   - Database config is correct (application.yml)
    echo     Host: localhost:3306/medical_health
    echo     User: root, Password: 123456
    echo.
    set /p CONTINUE="Continue to start backend? (Y/N): "
    if /i not "%CONTINUE%"=="Y" exit /b 1
) else (
    for /f %%c in ('mysql -u root -p123456 -N -s -e "SELECT COUNT(*) FROM medical_health.health_food"') do (
        set FOOD_COUNT=%%c
    )
    echo [OK] MySQL connected! health_food table: %FOOD_COUNT% records
)

:: Step 4: Check Port 8080
echo.
echo [4/5] Checking port 8080...
netstat -ano | findstr ":8080.*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo [WARN] Port 8080 is already in use!
    echo.
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080.*LISTENING"') do (
        echo    Process PID: %%a
        tasklist /FI "PID eq %%a" 2>nul | findstr /I "java"
    )
    echo.
    set /p KILL_PROCESS="Kill the process and continue? (Y/N): "
    if /i "%KILL_PROCESS%"=="Y" (
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080.*LISTENING"') do (
            echo Killing process %%a ...
            taskkill /F /PID %%a >nul 2>&1
        )
        timeout /t 2 >nul
        echo [OK] Process killed
    ) else (
        echo [ERROR] Cannot start. Please release port 8080 first.
        pause
        exit /b 1
    )
) else (
    echo [OK] Port 8080 is available
)

:: Step 5: Start Spring Boot Backend
echo.
echo [5/5] Starting Spring Boot backend server...
echo.
echo ============================================================
echo   Compiling and starting Harmony Health backend...
echo ============================================================
echo.
echo   First launch may take 2-5 minutes to download dependencies
echo   Please wait for: "Started MedicalApplication in x.x seconds"
echo.
echo   Press Ctrl+C to stop the server
echo.
echo ============================================================

cd /d %~dp0

if exist mvnw (
    call mvnw spring-boot:run
) else (
    call mvn spring-boot:run
)

if errorlevel 1 (
    echo.
    echo [ERROR] Backend startup failed!
    echo.
    echo Common solutions:
    echo   1. Compilation error - check Java code syntax
    echo   2. Missing dependencies - delete .m2/repository and rebuild
    echo   3. Port conflict - use: mvn spring-boot:run -Dserver.port=8081
    echo.
    pause
    exit /b 1
)

echo.
echo Backend server stopped.
pause
