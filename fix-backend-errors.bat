@echo off
echo ========================================
echo 后端项目错误修复脚本
echo ========================================
echo.

echo [步骤1] 清理项目构建缓存...
call mvn clean
if %errorlevel% neq 0 (
    echo 清理失败！
    pause
    exit /b 1
)
echo 清理完成！
echo.

echo [步骤2] 更新Maven依赖...
call mvn dependency:resolve
if %errorlevel% neq 0 (
    echo 依赖更新失败！
    pause
    exit /b 1
)
echo 依赖更新完成！
echo.

echo [步骤3] 编译项目...
call mvn compile
if %errorlevel% neq 0 (
    echo 编译失败！请检查错误信息。
    pause
    exit /b 1
)
echo 编译成功！
echo.

echo [步骤4] 打包项目（跳过测试）...
call mvn package -DskipTests
if %errorlevel% neq 0 (
    echo 打包失败！
    pause
    exit /b 1
)
echo 打包成功！
echo.

echo ========================================
echo 所有步骤完成！项目已成功构建。
echo ========================================
echo.
echo 如果IDE仍显示错误，请执行以下操作：
echo 1. 在IDE中：File -^> Invalidate Caches -^> Invalidate and Restart
echo 2. 重新导入Maven项目：右键项目 -^> Maven -^> Reimport
echo.

pause
