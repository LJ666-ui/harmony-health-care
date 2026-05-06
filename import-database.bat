@echo off
chcp 65001 >nul
echo ========================================
echo   数据库导入脚本
echo ========================================
echo.

echo [1] 检查MySQL连接...
mysql -u root -p123456 -e "SELECT 1;" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ MySQL连接失败
    echo 请检查：
    echo   - MySQL服务是否启动
    echo   - 用户名密码是否正确（当前：root/123456）
    echo   - MySQL是否在PATH环境变量中
    pause
    exit /b 1
)
echo ✓ MySQL连接正常
echo.

echo [2] 导入数据库...
echo 源文件：sql\medical_health(13).sql
echo 目标数据库：medical_health
echo.

if not exist "sql\medical_health(13).sql" (
    echo ❌ 数据库文件不存在：sql\medical_health(13).sql
    pause
    exit /b 1
)

echo 开始导入...
mysql -u root -p123456 < "sql\medical_health(13).sql"

if %errorlevel% neq 0 (
    echo.
    echo ❌ 导入失败
    echo.
    echo 请尝试手动导入：
    echo   1. 打开MySQL Workbench或Navicat
    echo   2. 连接到MySQL服务器
    echo   3. 执行 sql\medical_health(13).sql 文件
    pause
    exit /b 1
)

echo.
echo ✓ 数据库导入成功
echo.

echo [3] 验证数据库...
mysql -u root -p123456 -e "USE medical_health; SHOW TABLES;" 2>nul
if %errorlevel% neq 0 (
    echo ⚠ 无法验证数据库表
) else (
    echo ✓ 数据库表已创建
)
echo.

echo ========================================
echo   导入完成
echo ========================================
pause
