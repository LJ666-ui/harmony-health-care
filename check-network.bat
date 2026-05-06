@echo off
chcp 65001 >nul
echo ========================================
echo   网络连接诊断工具
echo ========================================
echo.

echo [1] 检查本机IP地址
echo ----------------------------------------
ipconfig | findstr "IPv4"
echo.

echo [2] 检查后端服务端口8080
echo ----------------------------------------
netstat -ano | findstr :8080
if %errorlevel% neq 0 (
    echo ❌ 端口8080未被监听，后端服务可能未启动
) else (
    echo ✓ 端口8080正在监听
)
echo.

echo [3] 测试本地连接
echo ----------------------------------------
echo 正在测试 http://localhost:8080 ...
curl -s -o nul -w "HTTP状态码: %%{http_code}\n" http://localhost:8080/user/info?id=1 2>nul
if %errorlevel% neq 0 (
    echo ❌ 无法连接到后端服务
    echo.
    echo 可能的原因：
    echo   1. 后端服务未启动
    echo   2. 防火墙阻止了连接
    echo   3. 端口被其他程序占用
) else (
    echo ✓ 后端服务响应正常
)
echo.

echo [4] 检查防火墙状态
echo ----------------------------------------
netsh advfirewall show allprofiles state | findstr "状态"
echo.

echo ========================================
echo   诊断完成
echo ========================================
echo.
echo 📝 解决方案：
echo.
echo 如果使用【模拟器】测试：
echo   - API地址应为：http://10.0.2.2:8080
echo   - 当前配置正确，无需修改
echo.
echo 如果使用【真机】测试：
echo   1. 查看上面的IPv4地址（如 192.168.1.100）
echo   2. 修改前端配置文件：
echo      entry/src/main/ets/common/constants/ApiConstants.ets
echo   3. 将 BASE_URL 改为：http://你的IP:8080
echo   4. 确保手机和电脑在同一局域网
echo   5. 关闭电脑防火墙或开放8080端口
echo.
pause
