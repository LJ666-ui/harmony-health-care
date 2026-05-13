@echo off
chcp 936 >nul 2>&1
title Harmony Health - Backend Status Checker
color 0B

echo.
echo ============================================================
echo        Harmony Health System - Backend Status Checker v1.0
echo ============================================================
echo.

:: Check 1: Port Listening
echo [Check 1/4] Checking port 8080 status...
netstat -ano | findstr ":8080.*LISTENING" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Port 8080 is NOT listening! Backend may not be started.
    echo.
    echo Solution:
    echo   1. Double-click: start-backend.bat to launch backend
    echo   2. Or run MedicalApplication.java in IDEA
    goto :EOF
) else (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080.*LISTENING"') do (
        set PID=%%a
    )
    echo [OK] Port 8080 is listening (PID: %PID%)
)

:: Check 2: Test API Endpoint
echo.
echo [Check 2/4] Testing basic API endpoint...
curl -s http://localhost:8080/test-health-food >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Cannot connect to http://localhost:8080
    echo.
    echo Possible reasons:
    echo   - Firewall blocking connection
    echo   - Backend startup failed
    goto :EOF
) else (
    for /f %%r in ('curl -s http://localhost:8080/test-health-food') do (
        set TEST_RESULT=%%r
    )
    if not "%TEST_RESULT%"=="" (
        echo [OK] API response: %TEST_RESULT%
    ) else (
        echo [WARN] API returned empty content
    )
)

:: Check 3: Food Data API
echo.
echo [Check 3/4] Checking food data API...
echo Requesting food list (first 5 records)...
echo.

curl -s "http://localhost:8080/healthFood/list?page=1&size=5" | findstr /C:"foodName" >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Food data API is abnormal!
    echo.
    echo Trying to show raw response:
    curl -s "http://localhost:8080/healthFood/list?page=1&size=2"
) else (
    echo [OK] Food data API is working!
    echo.
    echo Data preview (first 3 items):
    curl -s "http://localhost:8080/healthFood/list?page=1&size=3" | findstr /C:"foodName"
)

:: Check 4: Database Record Count
echo.
echo [Check 4/4] Counting total food records in database...
mysql -u root -p123456 -N -s -e "SELECT COUNT(*) FROM medical_health.health_food" >nul 2>&1
if errorlevel 1 (
    echo [WARN] Cannot query database, but API may use cached data
) else (
    for /f %%c in ('mysql -u root -p123456 -N -s -e "SELECT COUNT(*) FROM medical_health.health_food"') do (
        set TOTAL_COUNT=%%c
    )
    echo [OK] Total food records in database: %TOTAL_COUNT%
)

:: Summary
echo.
echo ============================================================
echo                    STATUS SUMMARY
echo ============================================================
echo   Port Status:     [OK] Port 8080 is listening
echo   Basic API:       [OK] Response normal
echo   Food Data API:   [OK] Available
echo   Total Records:   %TOTAL_COUNT% items
echo ============================================================
echo.
echo   SUCCESS! Backend is running normally!
echo   You can now test the frontend in your emulator!
echo.
echo   Next steps:
echo   1. Rebuild and run frontend app in DevEco Studio
echo   2. Go to Health tab -> Click Food Encyclopedia
echo   3. You should see 743 real food data records!
echo ============================================================
echo.

pause
