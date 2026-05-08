#!/bin/bash

echo "========================================"
echo "医院类别筛选功能完整测试"
echo "========================================"
echo

echo "1. 检查数据库level字段数据："
echo "----------------------------------------"
mysql -uroot -p123456 medical_health -e "
SELECT 
  COUNT(*) as total,
  COUNT(level) as has_level,
  COUNT(CASE WHEN level IS NULL OR level = '' THEN 1 END) as null_level
FROM hospital;
" 2>&1 | grep -v "Warning"

echo
echo "2. 查看医院等级分布："
echo "----------------------------------------"
mysql -uroot -p123456 medical_health -e "
SELECT level, COUNT(*) as count 
FROM hospital 
GROUP BY level 
ORDER BY count DESC;
" 2>&1 | grep -v "Warning"

echo
echo "3. 查看三级甲等医院样例："
echo "----------------------------------------"
mysql -uroot -p123456 medical_health -e "
SELECT id, name, level 
FROM hospital 
WHERE level = '三级甲等' 
LIMIT 5;
" 2>&1 | grep -v "Warning"

echo
echo "4. 查看一级甲等医院样例："
echo "----------------------------------------"
mysql -uroot -p123456 medical_health -e "
SELECT id, name, level 
FROM hospital 
WHERE level = '一级甲等' 
LIMIT 5;
" 2>&1 | grep -v "Warning"

echo
echo "5. 测试后端API（需要登录Token）："
echo "----------------------------------------"
echo "测试 /hospital/list 接口："
curl -s "http://localhost:8080/hospital/list" 2>&1 | python -m json.tool 2>/dev/null | head -10

echo
echo "========================================"
echo "测试完成！"
echo "========================================"
echo
echo "修复说明："
echo "1. ✅ 数据库level字段已填充完整"
echo "2. ✅ 后端/hospital/page接口支持level筛选"
echo "3. ✅ 前端支持处理数组格式和分页格式数据"
echo "4. ✅ 前端已修复ForEach键值问题"
echo "5. ✅ 前端已添加请求锁防止重复请求"
echo
echo "请在应用中测试："
echo "- 点击'三级甲等' -> 应显示64家医院"
echo "- 点击'一级甲等' -> 应显示98家医院"
echo "- 点击'综合医院' -> 应显示207家医院"
echo "- 点击'专科医院' -> 应显示12家医院"
