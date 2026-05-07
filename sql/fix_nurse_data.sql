-- ============================================================
-- 修复护士数据 - 添加工号和关联用户
-- ============================================================

SET NAMES utf8mb4;

-- 查看当前护士数据
SELECT * FROM nurse;

-- 更新护士数据，添加工号
-- 假设护士表中有数据，更新工号字段
UPDATE nurse SET nurse_no = 'N20230001' WHERE nurse_no IS NULL OR nurse_no = '';

-- 如果护士表中没有数据，插入测试数据
-- 首先创建关联的用户账号
INSERT INTO `user` (`id`, `username`, `password`, `nickname`, `phone`, `gender`, `age`, `user_type`, `real_name`, `status`) 
SELECT 109, 'N20230001', '$2a$10$EqKcp1WFKVQISheBxmXJxeZ7P5K9KQJ5Z5Z5Z55Z5Z5Z5Z5Z5Z5', '张护士', '13800138001', 1, 30, 3, '张护士', 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `user` WHERE id = 109);

-- 插入护士数据
INSERT INTO `nurse` (`id`, `user_id`, `nurse_no`, `name`, `gender`, `phone`, `department`, `title`, `certificate_no`, `work_years`, `avatar`, `status`, `create_time`, `update_time`, `is_deleted`)
SELECT 1, 109, 'N20230001', '张护士', 1, '13800138001', '内科', '护师', 'CERT20230001', 5, NULL, 1, NOW(), NOW(), 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `nurse` WHERE id = 1);

-- 显示更新结果
SELECT '✓ 护士数据已更新' AS message;
SELECT * FROM nurse;
SELECT * FROM user WHERE id = 109;
