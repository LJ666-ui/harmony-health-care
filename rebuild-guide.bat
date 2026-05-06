@echo off
echo ========================================
echo   Application Rebuild Guide
echo ========================================
echo.
echo IMPORTANT: You modified ApiConstants.ets
echo You MUST rebuild the application for changes to take effect!
echo.
echo ========================================
echo   Steps in DevEco Studio
echo ========================================
echo.
echo [Step 1] Clean Project
echo   - Click menu: Build -^> Clean Project
echo   - Wait for cleaning to complete
echo.
echo [Step 2] Rebuild Project
echo   - Click menu: Build -^> Rebuild Project
echo   - Wait for build to complete (may take 1-2 minutes)
echo.
echo [Step 3] Stop Current App
echo   - Click the red Stop button in toolbar
echo   - Or press Ctrl+F2
echo.
echo [Step 4] Run App Again
echo   - Click the green Run button
echo   - Or press Shift+F10
echo.
echo [Step 5] Test Verification Code
echo   - Enter phone number: 13948999643
echo   - Click "Get Verification Code"
echo   - Should see success message
echo.
echo ========================================
echo   Current Configuration
echo ========================================
echo.
echo API Base URL: http://10.0.9.202:8080
echo.
echo If this IP doesn't work, try:
echo   - http://192.168.137.1:8080
echo   - http://192.168.66.1:8080
echo   - http://192.168.108.1:8080
echo.
echo ========================================
echo   Verification
echo ========================================
echo.
echo After rebuilding, check HiLog in DevEco Studio:
echo   - Filter: HttpUtil
echo   - Look for: "POST http://10.0.9.202:8080/user/send-code"
echo   - Check for any errors
echo.
pause
