@echo off
chcp 65001 >nul 2>&1
echo ============================================
echo   家属端问题一键修复工具 v2.0
echo ============================================
echo.

:: 检查Java环境
echo [1/5] 检查Java环境...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到Java环境，请先安装JDK
    pause
    exit /b 1
)
echo ✅ Java环境正常
echo.

:: 检查Maven环境
echo [2/5] 检查Maven环境...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未找到Maven，请先安装并配置Maven
    pause
    exit /b 1
)
echo ✅ Maven环境正常
echo.

:: 编译项目
echo [3/5] 编译后端代码（这可能需要几分钟）...
call mvn clean compile -DskipTests
if %errorlevel% neq 0 (
    echo.
    echo ❌ 编译失败！请检查上面的错误信息
    echo.
    echo 常见原因：
    echo   1. Java语法错误（请检查修改的.java文件）
    echo   2. Maven依赖下载失败（检查网络连接）
    echo   3. 数据库配置错误（检查application.yml）
    echo.
    pause
    exit /b 1
)
echo ✅ 编译成功！
echo.

:: 提示执行SQL
echo [4/5] 准备执行数据库修复脚本...
echo.
echo ⚠️  即将执行SQL脚本：fix-all-family-issues.sql
echo 该脚本将：
echo   - 为护士表添加缺失字段
echo   - 插入测试护士数据（5条）
echo   - 插入用户ID=1的健康记录（9条）
echo   - 插入医疗记录（2条）
echo   - 插入用药提醒（3条）
echo.
set /p confirm="是否继续？(Y/N): "
if /i not "%confirm%"=="Y" (
    echo 已取消SQL执行
    goto :skip_sql
)

echo 正在执行SQL脚本...
mysql -u root -p123456 medical_health < fix-all-family-issues.sql 2>nul
if %errorlevel% equ 0 (
    echo ✅ SQL脚本执行成功！
) else (
    echo ⚠️  MySQL命令行执行失败，请手动执行以下命令：
    echo.
    echo   mysql -u root -p medical_health ^< fix-all-family-issues.sql
    echo.
    echo 或在MySQL客户端中执行：
    echo   source E:/HMOS6.0/Github/harmony-health-care/fix-all-family-issues.sql
)
echo.

:skip_sql

:: 显示完成信息
echo [5/5] 生成修复报告...
echo.
echo ══════════════════════════════════════════
echo   ✅ 修复完成！请按以下步骤操作：
echo ══════════════════════════════════════════
echo.
echo 📋 下一步操作：
echo.
echo   1️⃣  启动后端服务
echo       方式A：在IDEA中运行主类
echo       方式B：执行 mvn spring-boot:run
echo       方式C：运行 java -jar target\*.jar
echo.
echo   2️⃣  测试家属登录
echo       手机号：13912345001（王秀英）
echo       密码：（需要在患者端设置）
echo.
echo   3️⃣  验证功能
echo       □ 护士列表（应显示5个护士）
echo       □ 健康记录（应显示9条记录）
echo       □ 医疗记录（应显示2条记录）
echo       □ 用药管理（应显示3条提醒）
echo       □ 与护士聊天功能
echo.
echo 📄 详细说明请查看：FIX_GUIDE.md
echo.
echo 🔧 如果仍有问题，请查看：
echo   □ 后端控制台日志
echo   □ 浏览器开发者工具 Network 标签
echo   □ FIX_GUIDE.md 中的"如果仍有问题"章节
echo.
echo ══════════════════════════════════════════
echo.

pause
