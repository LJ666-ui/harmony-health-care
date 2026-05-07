-- 完整的数据库修复脚本
-- 执行此脚本前请先备份数据

-- ==================== article_comment表修复 ====================
-- 1. 确保user_id字段存在
ALTER TABLE `article_comment` 
ADD COLUMN IF NOT EXISTS `user_id` bigint NOT NULL COMMENT '用户ID' AFTER `id`;

-- 2. 确保parent_id字段存在
ALTER TABLE `article_comment` 
ADD COLUMN IF NOT EXISTS `parent_id` bigint NULL DEFAULT 0 COMMENT '父评论ID（0为顶级评论）' AFTER `article_id`;

-- 3. 确保索引存在
CREATE INDEX IF NOT EXISTS `idx_user_id` ON `article_comment`(`user_id`);
CREATE INDEX IF NOT EXISTS `idx_article_id` ON `article_comment`(`article_id`);
CREATE INDEX IF NOT EXISTS `idx_parent_id` ON `article_comment`(`parent_id`);

-- ==================== article_collect表修复 ====================
-- 确保article_collect表有所有必要字段
ALTER TABLE `article_collect` 
ADD COLUMN IF NOT EXISTS `user_id` bigint NOT NULL COMMENT '用户ID' AFTER `id`;

ALTER TABLE `article_collect` 
ADD COLUMN IF NOT EXISTS `article_id` bigint NOT NULL COMMENT '文章ID' AFTER `user_id`;

ALTER TABLE `article_collect` 
ADD COLUMN IF NOT EXISTS `collect_time` datetime NULL COMMENT '收藏时间' AFTER `article_id`;

-- ==================== 验证修复结果 ====================
SELECT '========== article_comment表结构 ==========' AS '';
SHOW COLUMNS FROM `article_comment`;

SELECT '========== article_collect表结构 ==========' AS '';
SHOW COLUMNS FROM `article_collect`;

SELECT '========== 验证user_id字段 ==========' AS '';
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME IN ('article_comment', 'article_collect')
  AND COLUMN_NAME = 'user_id';
