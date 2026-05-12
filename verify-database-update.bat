@echo off
echo ========================================
echo 星云医疗助手项目优化 - 数据库更新验证
echo ========================================
echo.

REM 设置数据库连接信息
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=medical_health

REM 检查MySQL是否可用
echo [1/2] 检查MySQL连接...
mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    echo [错误] 无法连接到MySQL数据库
    echo 请检查：
    echo   1. MySQL服务是否已启动
    echo   2. 用户名和密码是否正确
    echo   3. 主机和端口是否正确
    pause
    exit /b 1
)
echo [成功] MySQL连接正常
echo.

REM 执行验证脚本
echo [2/2] 执行数据库验证脚本...
mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% < verify-database-update.sql
if errorlevel 1 (
    echo [错误] 数据库验证失败
    pause
    exit /b 1
)
echo.

echo ========================================
echo 验证完成！
echo ========================================
echo.
echo 如果所有验证项都显示正确，说明数据库更新成功！
echo.
pause
