#!/bin/bash

echo "========================================="
echo "医院缓存功能 - 快速测试指南"
echo "========================================="
echo

echo "📋 测试步骤："
echo "-----------------------------------------"
echo

echo "【步骤1】首次加载测试"
echo "  1. 清除缓存（可选）"
echo "     代码：await hospitalCacheManager.clearCache();"
echo "  2. 打开医院列表页面"
echo "  3. 观察HiLog控制台"
echo "  预期输出："
echo "    [HospitalPage] 缓存无效，从服务器获取数据"
echo "    [HospitalCacheManager] Saved 381 hospitals to cache"
echo "    [HospitalPage] 已保存到缓存，数量：381"
echo "  ✅ 验证：页面显示381家医院，控制台显示已保存缓存"
echo

echo "【步骤2】缓存命中测试"
echo "  1. 返回上一页"
echo "  2. 再次打开医院列表页面"
echo "  预期输出："
echo "    [HospitalPage] 使用缓存数据，数量：381"
echo "  ✅ 验证："
echo "    - 页面快速显示（< 100ms）"
echo "    - 控制台显示'使用缓存数据'"
echo "    - 无网络请求日志"
echo

echo "【步骤3】分类筛选测试"
echo "  1. 点击'三级甲等'"
echo "  预期：显示116家医院，使用缓存"
echo "  2. 点击'综合医院'"
echo "  预期：显示121家医院，使用缓存"
echo "  3. 点击'社区医院'"
echo "  预期：显示87家医院，使用缓存"
echo "  ✅ 验证：所有筛选使用缓存，无网络请求"
echo

echo "【步骤4】离线访问测试"
echo "  1. 断开网络连接（关闭WiFi/移动数据）"
echo "  2. 打开医院列表页面"
echo "  3. 测试分类筛选"
echo "  ✅ 验证：离线状态下仍能正常显示和筛选"
echo

echo "【步骤5】查看SQLite数据库"
echo "  1. 找到数据库文件："
echo "     - 位置：应用沙箱/databases/local.db"
echo "     - 或：项目根目录/sqlite/harmony_medical.db"
echo "  2. 使用SQLite工具打开（推荐SQLiteStudio）"
echo "  3. 执行查询："
echo "     SELECT COUNT(*) FROM local_hospital_cache;"
echo "     SELECT level, COUNT(*) FROM local_hospital_cache GROUP BY level;"
echo "  ✅ 验证：表已创建，数据已保存，统计正确"
echo

echo "========================================="
echo "🔍 验证命令："
echo "-----------------------------------------"
echo

echo "查看数据库表结构："
echo "  sqlite3 harmony_medical.db"
echo "  .schema local_hospital_cache"
echo

echo "查看缓存数据："
echo "  SELECT COUNT(*) FROM local_hospital_cache;"
echo "  SELECT level, COUNT(*) FROM local_hospital_cache GROUP BY level;"
echo

echo "查看前10条数据："
echo "  SELECT id, name, level FROM local_hospital_cache LIMIT 10;"
echo

echo "========================================="
echo "📊 预期数据统计："
echo "-----------------------------------------"
echo "缓存总数：381"
echo "三级甲等：116"
echo "综合医院：121"
echo "社区医院：87"
echo "专科医院：25"
echo "卫生院：5"
echo "保健机构：18"
echo "诊所：9"
echo

echo "========================================="
echo "⚡ 性能指标："
echo "-----------------------------------------"
echo "首次加载时间：2-3秒（网络请求）"
echo "缓存加载时间：< 100ms"
echo "性能提升：20-30倍"
echo "流量节省：95%以上"
echo

echo "========================================="
echo "✅ 快速验证清单："
echo "-----------------------------------------"
echo "[ ] 首次加载：控制台显示'已保存到缓存'"
echo "[ ] 再次加载：控制台显示'使用缓存数据'"
echo "[ ] 加载速度：明显更快"
echo "[ ] 分类筛选：全部正常"
echo "[ ] 离线访问：功能可用"
echo "[ ] 数据库：数据已保存"
echo "========================================="
