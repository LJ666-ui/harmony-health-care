@echo off
chcp 65001 >nul
echo ============================================
echo   Harmony Health Care - 编译修复工具
echo ============================================
echo.

REM 查找Corretto JDK 1.8
set "CORRETTO_PATH="
if exist "C:\Program Files\Amazon Corretto\jdk1.8.0_xxx\bin\java.exe" (
    set "CORRETTO_PATH=C:\Program Files\Amazon Corretto\jdk1.8.0_xxx"
)
if exist "D:\.jdks\corretto-1.8\bin\java.exe" (
    set "CORRETTO_PATH=D:\.jdks\corretto-1.8"
)

if not defined CORRETTO_PATH (
    echo [警告] 未找到Amazon Corretto JDK 1.8
    echo.
    echo 请选择操作：
    echo   1. 在IDEA中编译（推荐）
    echo   2. 手动指定JDK路径
    echo   3. 下载并安装JDK 1.8
    echo.
    set /p choice=请输入选项 (1/2/3):

    if "%choice%"=="1" goto idea_compile
    if "%choice%"=="2" goto manual_jdk
    if "%choice%"=="3" goto download_jdk
    goto end
)

echo [信息] 找到JDK路径: %CORRETTO_PATH%
echo.

REM 设置JAVA_HOME并编译
set "JAVA_HOME=%CORRETTO_PATH%"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo [步骤1] 验证Java版本...
java -version
echo.

echo [步骤2] 清理并编译项目...
cd /d e:\harmony-health-care
call mvn clean compile

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo   ✅ 编译成功！
    echo ============================================
) else (
    echo.
    echo ============================================
    echo   ❌ 编译失败，请查看上方错误信息
    echo ============================================
)

goto end

:idea_compile
echo.
echo ============================================
echo   在IDEA中编译的方法：
echo ============================================
echo.
echo   方法1 - 使用Maven工具窗口：
echo     1. 打开 View → Tool Windows → Maven
echo     2. 展开 medical → Lifecycle
echo     3. 双击 clean，然后双击 compile
echo.
echo   方法2 - 使用快捷键：
echo     1. Ctrl+Shift+A 输入 "Reimport All Maven Projects"
echo     2. 等待依赖下载完成
echo     3. Ctrl+F9 (Build Project)
echo.
echo   方法3 - 右键菜单：
echo     1. 右键点击 pom.xml
echo     2. Maven → Reimport
echo     3. 再次右键 pom.xml → Run As → Maven compile
echo.
goto end

:manual_jdk
echo.
set /p JDK_PATH=请输入JDK 1.8的完整路径（如 C:\Program Files\Java\jdk1.8.0_xx）:
if not exist "%JDK_PATH%\bin\java.exe" (
    echo [错误] 路径无效或找不到java.exe
    goto end
)

set "JAVA_HOME=%JDK_PATH%"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo [信息] 使用JDK: %JAVA_HOME%
java -version
echo.

cd /d e:\harmony-health-care
call mvn clean compile
goto end

:download_jdk
echo.
echo ============================================
echo   下载 Amazon Corretto JDK 1.8：
echo ============================================
echo.
echo   访问以下链接下载：
echo   https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html
echo.
echo   选择 Windows x64 Installer (msi)
echo   安装后重新运行此脚本
echo.
start https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html
goto end

:end
echo.
pause
