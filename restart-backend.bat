@echo off
chcp 65001 >nul
echo ========================================
echo   重启后端服务
echo ========================================
echo.

echo [步骤1] 停止现有服务...
echo 正在查找Java进程...
for /f "tokens=2" %%i in ('tasklist ^| findstr "java.exe"') do (
    echo 找到Java进程: %%i
    taskkill /F /PID %%i >nul 2>&1
)
echo 等待进程完全停止...
timeout /t 3 /nobreak >nul
echo ✓ 服务已停止
echo.

echo [步骤2] 重新编译项目...
call mvn clean compile -DskipTests
if %errorlevel% neq 0 (
    echo ❌ 编译失败
    pause
    exit /b 1
)
echo ✓ 编译成功
echo.

echo [步骤3] 启动服务...
echo.
echo ========================================
echo   服务启动中...
echo   访问地址：http://localhost:8080/swagger-ui.html
echo   按 Ctrl+C 可停止服务
echo ========================================
echo.
call mvn spring-boot:run
