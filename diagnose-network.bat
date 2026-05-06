@echo off
echo ========================================
echo   Network Diagnosis Tool
echo ========================================
echo.

echo [Step 1] Check backend service
echo ----------------------------------------
netstat -ano | findstr :8080
if %errorlevel% neq 0 (
    echo ERROR: Backend service is not running on port 8080
    pause
    exit /b 1
) else (
    echo OK: Backend is listening on port 8080
)
echo.

echo [Step 2] Test localhost connection
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://localhost:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5; Write-Host 'Status:' $r.StatusCode; Write-Host 'Response:' $r.Content } catch { Write-Host 'Error:' $_.Exception.Message }"
echo.

echo [Step 3] Test IP 10.0.9.202 connection
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://10.0.9.202:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5; Write-Host 'Status:' $r.StatusCode; Write-Host 'Response:' $r.Content } catch { Write-Host 'Error:' $_.Exception.Message }"
echo.

echo [Step 4] Test other IP addresses
echo ----------------------------------------
echo Testing 192.168.137.1...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://192.168.137.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5; Write-Host 'Status:' $r.StatusCode } catch { Write-Host 'Error:' $_.Exception.Message }"
echo.

echo Testing 192.168.66.1...
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://192.168.66.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5; Write-Host 'Status:' $r.StatusCode } catch { Write-Host 'Error:' $_.Exception.Message }"
echo.

echo ========================================
echo   Diagnosis Complete
echo ========================================
echo.
echo Please check which IP address works above.
echo Then update ApiConstants.ets with the working IP.
echo.
pause
