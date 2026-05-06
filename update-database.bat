@echo off
chcp 65001 >nul
echo ========================================
echo 鸿蒙健康医疗应用 - 数据库表结构更新
echo ========================================
echo.

echo 正在更新数据库表结构...
echo.

mysql -u root -p123456 medical_health -e "ALTER TABLE user ADD COLUMN real_name varchar(50) DEFAULT NULL COMMENT '真实姓名' AFTER user_type; ALTER TABLE user ADD COLUMN id_card varchar(18) DEFAULT NULL COMMENT '身份证号' AFTER age; ALTER TABLE user ADD COLUMN hospital varchar(100) DEFAULT NULL COMMENT '所属医院' AFTER real_name; ALTER TABLE user ADD COLUMN department varchar(50) DEFAULT NULL COMMENT '科室' AFTER hospital; ALTER TABLE user ADD COLUMN license_number varchar(50) DEFAULT NULL COMMENT '执业证号' AFTER department;"

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo 数据库表结构更新成功！
    echo ========================================
    echo.
    echo 正在验证表结构...
    mysql -u root -p123456 medical_health -e "DESC user;"
    echo.
    echo 请重启后端服务，然后测试注册功能
) else (
    echo.
    echo ========================================
    echo 更新失败！
    echo 可能原因：
    echo 1. MySQL服务未启动
    echo 2. 数据库密码不正确
    echo 3. 字段已存在
    echo ========================================
    echo.
    echo 请手动执行以下SQL：
    echo mysql -u root -p123456 medical_health ^< update-user-table.sql
)

echo.
pause
