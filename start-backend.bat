@echo off
chcp 65001 >nul
echo ========================================
echo   鸿蒙健康医疗应用 - 后端服务启动脚本
echo ========================================
echo.

echo [步骤1] 检查Java环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到Java环境，请先安装JDK 8或以上版本
    pause
    exit /b 1
)
echo ✓ Java环境正常
echo.

echo [步骤2] 检查Maven环境...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到Maven，请先安装Maven
    pause
    exit /b 1
)
echo ✓ Maven环境正常
echo.

echo [步骤3] 检查MySQL数据库连接...
echo 提示：请确保MySQL服务已启动
echo 数据库配置：localhost:3306, 用户：root, 密码：123456
echo.
echo 是否需要导入数据库？(Y/N)
set /p import_db=请选择：
if /i "%import_db%"=="Y" (
    echo.
    echo 正在导入数据库...
    mysql -u root -p123456 < "sql\medical_health(13).sql"
    if %errorlevel% neq 0 (
        echo ❌ 数据库导入失败，请手动导入 sql\medical_health(13).sql
        pause
    ) else (
        echo ✓ 数据库导入成功
    )
)
echo.

echo [步骤4] 编译项目...
echo 执行命令：mvn clean install -DskipTests
call mvn clean install -DskipTests
if %errorlevel% neq 0 (
    echo.
    echo ❌ 编译失败，请检查错误信息
    pause
    exit /b 1
)
echo.
echo ✓ 编译成功
echo.

echo [步骤5] 启动后端服务...
echo 执行命令：mvn spring-boot:run
echo.
echo ========================================
echo   服务启动中，请等待...
echo   启动成功后访问：http://localhost:8080/swagger-ui.html
echo   按 Ctrl+C 可停止服务
echo ========================================
echo.
call mvn spring-boot:run
