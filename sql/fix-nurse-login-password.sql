-- ============================================================
-- 修复护士登录：重置密码为 123456
-- 执行时间: 2026-05-13
-- ============================================================

-- 1. 更新护士用户密码（手机号 13800138001）
UPDATE `user` 
SET password = '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv'
WHERE phone = '13800138001' AND user_type IN (2, 3);

-- 验证更新结果
SELECT 
    id,
    username,
    real_name,
    phone,
    user_type,
    CASE WHEN password = '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv' 
        THEN '✓ 密码已重置为 123456' 
        ELSE '✗ 密码异常' 
    END AS password_status,
    status,
    is_deleted
FROM `user` 
WHERE phone = '13800138001';

-- 2. 验证 nurse 表关联
SELECT 
    n.id AS nurse_id,
    n.user_id,
    n.nurse_no,
    u.real_name AS name,
    u.phone AS phone,
    n.department,
    n.status,
    u.id AS user_id_check,
    u.phone AS user_phone_check,
    u.real_name AS user_name,
    CASE 
        WHEN n.user_id = u.id AND n.is_deleted = 0 AND u.is_deleted = 0 AND n.status = 1
        THEN '✓ 护士账号正常可用'
        ELSE '✗ 账号状态异常'
    END AS account_status
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE u.phone = '13800138001';

-- 3. 显示所有护士账号（用于测试）
SELECT 
    n.id,
    n.user_id,
    n.nurse_no,
    u.real_name AS name,
    u.phone AS phone,
    n.department,
    n.status,
    CASE 
        WHEN n.status = 1 AND n.is_deleted = 0 AND u.is_deleted = 0
        THEN '可登录'
        ELSE '不可用'
    END AS login_status
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE n.is_deleted = 0
ORDER BY n.id
LIMIT 20;

-- ============================================================
-- 测试账号信息：
-- 手机号: 13800138001
-- 密码: 123456
-- 姓名: 于护士/张护士
-- 科室: 内科
-- ============================================================
