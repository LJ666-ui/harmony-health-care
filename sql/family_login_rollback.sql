-- ============================================================
-- 家属登录功能 - 数据库回滚脚本
-- 生成时间：2026-05-08
-- 说明：回滚家属登录功能的数据库变更
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

SELECT '========================================' AS message;
SELECT '开始回滚家属登录功能...' AS message;
SELECT '========================================' AS message;

-- ============================================================
-- 第一步：删除新增的表
-- ============================================================

DROP TABLE IF EXISTS `family_auth_log`;
SELECT '✓ family_auth_log表已删除' AS message;

DROP TABLE IF EXISTS `migration_log`;
SELECT '✓ migration_log表已删除' AS message;

-- ============================================================
-- 第二步：恢复family_member表
-- ============================================================

-- 方案A：从备份表恢复（推荐）
-- 删除当前表
DROP TABLE IF EXISTS `family_member`;

-- 从备份表恢复
RENAME TABLE `family_member_backup` TO `family_member`;

SELECT '✓ family_member表已从备份恢复' AS message;

-- ============================================================
-- 第三步：验证恢复结果
-- ============================================================

SELECT '========== 验证恢复结果 ==========' AS message;

-- 查看family_member表结构
SHOW COLUMNS FROM `family_member`;

-- 统计数据
SELECT
  '家属总数' AS item,
  COUNT(*) AS count
FROM `family_member`;

-- ============================================================
-- 完成
-- ============================================================

SET FOREIGN_KEY_CHECKS = 1;

SELECT '========================================' AS message;
SELECT '✓✓✓ 回滚完成！' AS message;
SELECT '========================================' AS message;
SELECT '家属登录功能已完全移除' AS message;
SELECT '数据已恢复到升级前状态' AS message;
SELECT '========================================' AS message;
