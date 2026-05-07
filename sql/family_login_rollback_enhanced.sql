-- ============================================================
-- 家属登录功能 - 增强版回滚脚本
-- 生成时间：2026-05-08
-- 说明：回滚增强版升级的所有变更
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

SELECT '========================================' AS message;
SELECT '开始回滚增强版升级...' AS message;
SELECT '========================================' AS message;

-- ============================================================
-- 第一步：删除新增的表
-- ============================================================

DROP TABLE IF EXISTS `family_auth_log`;
SELECT '✓ family_auth_log表已删除' AS message;

DROP TABLE IF EXISTS `migration_log`;
SELECT '✓ migration_log表已删除' AS message;

-- ============================================================
-- 第二步：恢复user表
-- ============================================================

-- 方案A：从备份表恢复（推荐）
DROP TABLE IF EXISTS `user`;
RENAME TABLE `user_backup` TO `user`;
SELECT '✓ user表已从备份恢复' AS message;

-- ============================================================
-- 第三步：恢复family_member表
-- ============================================================

-- 方案A：从备份表恢复（推荐）
DROP TABLE IF EXISTS `family_member`;
RENAME TABLE `family_member_backup` TO `family_member`;
SELECT '✓ family_member表已从备份恢复' AS message;

-- ============================================================
-- 第四步：验证恢复结果
-- ============================================================

SELECT '========================================' AS message;
SELECT '验证恢复结果：' AS message;
SELECT '========================================' AS message;

-- 查看user表数据
SELECT '---------- user表 ----------' AS message;
SELECT
  '用户总数' AS item,
  COUNT(*) AS count
FROM `user`;

-- 查看family_member表数据
SELECT '---------- family_member表 ----------' AS message;
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
SELECT '已恢复内容：' AS message;
SELECT '1. ✓ user表已恢复（密码恢复为明文）' AS message;
SELECT '2. ✓ family_member表已恢复（无登录字段）' AS message;
SELECT '3. ✓ family_auth_log表已删除' AS message;
SELECT '4. ✓ 数据已恢复到升级前状态' AS message;
SELECT '========================================' AS message;
