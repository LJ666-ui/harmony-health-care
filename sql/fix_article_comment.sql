-- 修复article_comment表缺少user_id字段的问题
-- 执行此脚本前请先备份数据

-- 检查并添加user_id字段
ALTER TABLE `article_comment` ADD COLUMN IF NOT EXISTS `user_id` bigint NOT NULL COMMENT '用户ID' AFTER `id`;

-- 添加索引（如果不存在）
CREATE INDEX IF NOT EXISTS `idx_user_id` ON `article_comment`(`user_id`);

-- 验证字段是否添加成功
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'article_comment' 
  AND COLUMN_NAME = 'user_id';
