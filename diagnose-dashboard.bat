@echo off
chcp 65001 >nul
echo ========================================
echo 管理仪表盘数据诊断工具
echo ========================================
echo.

echo [1] 检查后端服务状态...
curl -s http://localhost:8080/admin/login -X POST -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ 后端服务正在运行
) else (
    echo ✗ 后端服务未运行或无法访问
    echo.
    echo 请先启动后端服务：
    echo   cd src/main/java
    echo   mvn spring-boot:run
    echo   或运行 start-backend.bat
    pause
    exit /b 1
)

echo.
echo [2] 检查数据库连接和数据...
echo 正在查询数据库...

REM 使用MySQL命令检查数据（需要配置MySQL环境变量）
mysql -uroot -proot123 -e "USE medical_health; SELECT COUNT(*) as user_count FROM user WHERE is_deleted=0; SELECT COUNT(*) as admin_count FROM admin WHERE is_deleted=0; SELECT COUNT(*) as doctor_count FROM doctor WHERE is_deleted=0;" 2>nul
if %errorlevel% neq 0 (
    echo ⚠ 无法直接连接数据库，尝试通过API测试...
)

echo.
echo [3] 测试仪表盘API...
curl -s http://localhost:8080/admin/dashboard/stats -H "Token: test"
echo.
echo.

echo [4] 测试管理员登录并获取数据...
curl -s http://localhost:8080/admin/login -X POST -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}" > temp_token.json
type temp_token.json
echo.
echo.

echo ========================================
echo 诊断完成
echo ========================================
echo.
echo 如果所有计数都为0，说明数据库中没有数据。
echo 解决方案：
echo 1. 导入初始数据：运行 import-database.bat
echo 2. 或手动添加测试用户
echo.
pause
del temp_token.json 2>nul
