@echo off
chcp 65001 >nul
echo ========================================
echo   环境检查脚本
echo ========================================
echo.

echo [1] Java环境检查：
java -version 2>&1
echo.

echo [2] Maven环境检查：
mvn -version 2>&1
echo.

echo [3] 项目目录检查：
if exist "pom.xml" (
    echo ✓ pom.xml 存在
) else (
    echo ❌ pom.xml 不存在
)

if exist "src\main\java\com\example\medical\MedicalApplication.java" (
    echo ✓ MedicalApplication.java 存在
) else (
    echo ❌ MedicalApplication.java 不存在
)

if exist "src\main\resources\application.yml" (
    echo ✓ application.yml 存在
) else (
    echo ❌ application.yml 不存在
)
echo.

echo [4] 端口8080检查：
netstat -ano | findstr :8080 >nul
if %errorlevel% equ 0 (
    echo ⚠ 端口8080已被占用
    netstat -ano | findstr :8080
) else (
    echo ✓ 端口8080可用
)
echo.

echo ========================================
echo   检查完成
echo ========================================
pause
