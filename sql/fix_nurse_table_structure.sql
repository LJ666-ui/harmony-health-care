-- ============================================================
-- 修复护士表结构 - 统一字段名
-- ============================================================

SET NAMES utf8mb4;

-- 1. 检查当前表结构
DESC nurse;

-- 2. 重命名字段以匹配实体类
-- 如果 nurse_number 存在，重命名为 nurse_no
ALTER TABLE nurse CHANGE COLUMN nurse_number nurse_no VARCHAR(20) COMMENT '护士工号';

-- 如果 real_name 存在，重命名为 name
ALTER TABLE nurse CHANGE COLUMN real_name name VARCHAR(50) COMMENT '真实姓名';

-- 3. 验证修改结果
DESC nurse;

-- 4. 查看数据
SELECT * FROM nurse;

SELECT '✓ 护士表结构已修复' AS message;
