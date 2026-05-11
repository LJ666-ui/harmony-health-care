-- =====================================================
-- 修复 nurse 表结构 - 添加缺失的 gender 列
-- 问题：Nurse实体类定义了gender字段，但数据库表中没有
-- =====================================================

-- 第1步：检查并添加 gender 列
ALTER TABLE nurse 
ADD COLUMN gender INT DEFAULT NULL COMMENT '性别：0-女，1-男' 
AFTER name;

-- 第2步：验证修改结果
SELECT 
    COLUMN_NAME AS 列名,
    COLUMN_TYPE AS 数据类型,
    IS_NULLABLE AS 允许空,
    COLUMN_DEFAULT AS 默认值,
    COLUMN_COMMENT AS 备注
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
AND TABLE_NAME = 'nurse'
ORDER BY ORDINAL_POSITION;

-- 第3步：查看nurse表当前数据
SELECT * FROM nurse LIMIT 5;

-- 第4步：测试查询是否正常
SELECT id, user_id, nurse_no, name, gender, phone, department 
FROM nurse 
WHERE id = 1;
