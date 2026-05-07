-- 检查管理员表数据
SELECT id, username, password, real_name, role, status, is_deleted FROM admin WHERE is_deleted = 0;

-- 检查用户表中是否有管理员数据
SELECT id, username, password, user_type, real_name, is_deleted FROM user WHERE username IN ('admin', 'admin2') AND is_deleted = 0;

-- 检查admin表的user_id关联
SELECT a.id AS admin_id, a.username, a.user_id, u.id AS user_table_id, u.username AS user_username
FROM admin a
LEFT JOIN user u ON a.user_id = u.id
WHERE a.is_deleted = 0;
