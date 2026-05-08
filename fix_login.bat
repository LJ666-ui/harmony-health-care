@echo off
REM ============================================
REM Login Issue Fix Script
REM ============================================

echo.
echo ============================================
echo Login Issue Fix Script
echo ============================================
echo.
echo This script will fix:
echo 1. Doctor account 13812345001 disabled
echo 2. Admin password verification failed
echo.
echo Requirements:
echo - MySQL service is running
echo - Database name: medical_health
echo - Sufficient permissions to execute UPDATE
echo.
pause

echo.
echo Executing SQL fix script...
echo.

mysql -u root -p medical_health < fix_login_issues.sql

if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo Fix Successful!
    echo ============================================
    echo.
    echo Login Information After Fix:
    echo.
    echo Doctor Login:
    echo   Phone: 13812345001
    echo   Password: 123456
    echo.
    echo Admin Login:
    echo   Username: admin
    echo   Password: 123456
    echo.
) else (
    echo.
    echo ============================================
    echo Fix Failed!
    echo ============================================
    echo.
    echo Possible reasons:
    echo 1. MySQL service not running
    echo 2. Database connection failed
    echo 3. SQL syntax error
    echo.
    echo Please check error message and retry.
    echo.
)

pause
