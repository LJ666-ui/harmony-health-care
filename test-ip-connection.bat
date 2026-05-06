@echo off
echo ========================================
echo   IP Connection Test
echo ========================================
echo.
echo Testing different IP addresses to find which one works...
echo.

echo [Test 1] 10.0.9.202
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://10.0.9.202:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 3; Write-Host 'SUCCESS: Status' $r.StatusCode } catch { Write-Host 'FAILED:' $_.Exception.Message }"
echo.

echo [Test 2] 192.168.137.1
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://192.168.137.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 3; Write-Host 'SUCCESS: Status' $r.StatusCode } catch { Write-Host 'FAILED:' $_.Exception.Message }"
echo.

echo [Test 3] 192.168.66.1
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://192.168.66.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 3; Write-Host 'SUCCESS: Status' $r.StatusCode } catch { Write-Host 'FAILED:' $_.Exception.Message }"
echo.

echo [Test 4] 192.168.108.1
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://192.168.108.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 3; Write-Host 'SUCCESS: Status' $r.StatusCode } catch { Write-Host 'FAILED:' $_.Exception.Message }"
echo.

echo [Test 5] localhost (127.0.0.1)
echo ----------------------------------------
powershell -Command "try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/user/send-code' -Method POST -Body '{\"phone\":\"13948999643\"}' -ContentType 'application/json' -UseBasicParsing -TimeoutSec 3; Write-Host 'SUCCESS: Status' $r.StatusCode } catch { Write-Host 'FAILED:' $_.Exception.Message }"
echo.

echo ========================================
echo   Test Complete
echo ========================================
echo.
echo Look for the IP address that shows "SUCCESS" above.
echo That's the IP you should use in ApiConstants.ets
echo.
pause
