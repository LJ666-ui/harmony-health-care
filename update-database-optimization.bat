@echo off
echo ========================================
echo 星云医疗助手项目优化 - 数据库更新
echo ========================================
echo.

REM 设置数据库连接信息
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=
set DB_NAME=medical_health

REM 检查MySQL是否可用
echo [1/3] 检查MySQL连接...
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

REM 备份数据库
echo [2/3] 备份数据库...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set BACKUP_FILE=backup_%datetime:~0,8%_%datetime:~8,6%.sql
mysqldump -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% > %BACKUP_FILE%
if errorlevel 1 (
    echo [错误] 数据库备份失败
    pause
    exit /b 1
)
echo [成功] 数据库备份完成: %BACKUP_FILE%
echo.

REM 执行更新脚本
echo [3/3] 执行数据库更新脚本...
mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% < update-database-optimization.sql
if errorlevel 1 (
    echo [错误] 数据库更新失败
    echo 正在恢复数据库备份...
    mysql -h%DB_HOST% -P%DB_PORT% -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% < %BACKUP_FILE%
    if errorlevel 1 (
        echo [严重错误] 数据库恢复也失败了！请手动处理！
    ) else (
        echo [成功] 数据库已恢复到更新前的状态
    )
    pause
    exit /b 1
)
echo [成功] 数据库更新完成
echo.

echo ========================================
echo 数据库更新成功！
echo ========================================
echo.
echo 下一步：
echo   1. 验证新表是否创建成功
echo   2. 验证索引是否添加成功
echo   3. 验证测试数据是否插入成功
echo   4. 开始后端接口开发
echo.
pause
