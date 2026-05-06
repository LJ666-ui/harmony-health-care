@echo off
echo ========================================
echo   HiLog Check Guide
echo ========================================
echo.
echo Please follow these steps in DevEco Studio:
echo.
echo [Step 1] Open HiLog
echo   - Click "HiLog" tab at the bottom of DevEco Studio
echo   - If not visible, go to View -^> Tool Windows -^> HiLog
echo.
echo [Step 2] Clear old logs
echo   - Click the trash icon (Clear Log) in HiLog toolbar
echo.
echo [Step 3] Set filter
echo   - In the search box, type: HttpUtil
echo   - Or type: Register
echo   - Or type: send-code
echo.
echo [Step 4] Trigger action
echo   - In the app, click "Get Verification Code" button
echo.
echo [Step 5] Check output
echo   - Look for lines like:
echo     [HttpUtil] POST http://10.0.9.202:8080/user/send-code
echo.
echo   - If you see http://10.0.2.2:8080, config didn't take effect
echo   - If you see nothing, request wasn't sent
echo.
echo ========================================
echo   What to look for
echo ========================================
echo.
echo SUCCESS indicators:
echo   - [HttpUtil] POST http://10.0.9.202:8080/user/send-code
echo   - Request body: {"phone":"13948999643"}
echo.
echo FAILURE indicators:
echo   - [HttpUtil] POST http://10.0.2.2:8080/user/send-code
echo     (Config didn't take effect, need to rebuild)
echo.
echo   - No output at all
echo     (Request not sent, check button click handler)
echo.
echo   - Error: Failed to connect
echo     (Network issue, check IP address)
echo.
pause
