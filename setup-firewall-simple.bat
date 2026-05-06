@echo off
echo ========================================
echo   Quick Firewall Setup
echo ========================================
echo.
echo This script will configure Windows Firewall to allow port 8080.
echo.
echo IMPORTANT: Please run this script as Administrator!
echo.
pause

echo.
echo Adding firewall rules...
echo.

netsh advfirewall firewall add rule name="HealthCare-8080-In" dir=in action=allow protocol=tcp localport=8080
netsh advfirewall firewall add rule name="HealthCare-8080-Out" dir=out action=allow protocol=tcp localport=8080

echo.
echo Done! Firewall rules have been added.
echo.
echo You can now test the application.
echo.
pause
