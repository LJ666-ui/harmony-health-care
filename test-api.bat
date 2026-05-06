@echo off
chcp 65001 >nul
echo ========================================
echo   后端接口测试
echo ========================================
echo.

echo [测试1] 测试用户信息接口
echo ----------------------------------------
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/user/info?id=1' -UseBasicParsing; Write-Host '状态码:' $response.StatusCode; Write-Host '响应内容:' $response.Content } catch { Write-Host '错误:' $_.Exception.Message }"
echo.

echo [测试2] 测试验证码接口
echo ----------------------------------------
powershell -Command "try { $body = @{phone='13948999643'} | ConvertTo-Json; $response = Invoke-WebRequest -Uri 'http://localhost:8080/user/send-code' -Method POST -Body $body -ContentType 'application/json' -UseBasicParsing; Write-Host '状态码:' $response.StatusCode; Write-Host '响应内容:' $response.Content } catch { Write-Host '错误:' $_.Exception.Message }"
echo.

echo [测试3] 测试注册接口
echo ----------------------------------------
powershell -Command "try { $body = @{username='13948999643'; password='123456'; userType=0} | ConvertTo-Json; $response = Invoke-WebRequest -Uri 'http://localhost:8080/user/register' -Method POST -Body $body -ContentType 'application/json' -UseBasicParsing; Write-Host '状态码:' $response.StatusCode; Write-Host '响应内容:' $response.Content } catch { Write-Host '错误:' $_.Exception.Message }"
echo.

echo [测试4] 测试Swagger文档
echo ----------------------------------------
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:8080/swagger-ui.html' -UseBasicParsing; Write-Host '状态码:' $response.StatusCode; Write-Host 'Swagger文档可访问' } catch { Write-Host '错误:' $_.Exception.Message }"
echo.

echo ========================================
echo   测试完成
echo ========================================
pause
