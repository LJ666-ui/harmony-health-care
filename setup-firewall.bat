@echo off
echo ========================================
echo   Firewall Configuration Tool
echo ========================================
echo.

echo Configuring firewall rules...
echo.

echo [1] Add inbound rule (allow port 8080)
netsh advfirewall firewall add rule name="HealthCare Backend Inbound" dir=in action=allow protocol=tcp localport=8080
if %errorlevel% equ 0 (
    echo Success: Inbound rule added
) else (
    echo Warning: Inbound rule may already exist or need admin rights
)
echo.

echo [2] Add outbound rule (allow port 8080)
netsh advfirewall firewall add rule name="HealthCare Backend Outbound" dir=out action=allow protocol=tcp localport=8080
if %errorlevel% equ 0 (
    echo Success: Outbound rule added
) else (
    echo Warning: Outbound rule may already exist or need admin rights
)
echo.

echo [3] Show firewall rules
echo ----------------------------------------
netsh advfirewall firewall show rule name="HealthCare Backend Inbound"
echo.

echo ========================================
echo   Configuration Complete
echo ========================================
echo.
echo Tips:
echo   - If prompted for admin rights, right-click and run as administrator
echo   - After configuration, please test the application again
echo.
pause
