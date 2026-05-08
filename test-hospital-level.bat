@echo off
chcp 65001 >nul
echo ========================================
echo 测试医院等级筛选功能
echo ========================================
echo.

echo 1. 检查数据库医院等级分布：
mysql -uroot -p123456 medical_health -e "SELECT level, COUNT(*) as count FROM hospital GROUP BY level ORDER BY count DESC;"

echo.
echo 2. 检查三级甲等医院数量：
mysql -uroot -p123456 medical_health -e "SELECT COUNT(*) as count FROM hospital WHERE level = '三级甲等';"

echo.
echo 3. 检查二级甲等医院数量：
mysql -uroot -p123456 medical_health -e "SELECT COUNT(*) as count FROM hospital WHERE level = '二级甲等';"

echo.
echo 4. 查看前5个三级甲等医院：
mysql -uroot -p123456 medical_health -e "SELECT id, name, level FROM hospital WHERE level = '三级甲等' LIMIT 5;"

echo.
echo ========================================
echo 测试完成！
echo ========================================
pause
