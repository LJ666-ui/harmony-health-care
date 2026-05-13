-- ==========================================
-- 同步user表和doctor表的数据
-- 版本: v1.0
-- 日期: 2026-05-11
-- 说明: 将user表中user_type=1的医生同步到doctor表
-- ==========================================

USE medical_health;

-- ==========================================
-- 查看当前数据
-- ==========================================

SELECT '========================================' AS '';
SELECT '当前user表中的医生（user_type=1）:' AS message;
SELECT '========================================' AS '';
SELECT id, username, real_name, phone, user_type 
FROM user 
WHERE user_type = 1 
LIMIT 10;

SELECT '========================================' AS '';
SELECT '当前doctor表中的记录:' AS message;
SELECT '========================================' AS '';
SELECT id, user_id, real_name, phone 
FROM doctor 
LIMIT 10;

-- ==========================================
-- 同步数据：将user表中user_type=1但doctor表中不存在的记录插入doctor表
-- ==========================================

INSERT INTO doctor (user_id, real_name, phone, hospital, department, license_number, title, specialty, status, create_time, update_time, is_deleted)
SELECT 
    u.id as user_id,
    u.real_name,
    u.phone,
    u.hospital,
    u.department,
    u.license_number,
    u.title,
    u.specialty,
    1 as status,
    NOW() as create_time,
    NOW() as update_time,
    0 as is_deleted
FROM user u
WHERE u.user_type = 1
  AND u.is_deleted = 0
  AND NOT EXISTS (
      SELECT 1 FROM doctor d WHERE d.user_id = u.id
  );

-- ==========================================
-- 验证同步结果
-- ==========================================

SELECT '========================================' AS '';
SELECT '同步完成！验证结果:' AS message;
SELECT '========================================' AS '';

SELECT 'user表中的医生数量:' AS info;
SELECT COUNT(*) as count FROM user WHERE user_type = 1 AND is_deleted = 0;

SELECT 'doctor表中的记录数量:' AS info;
SELECT COUNT(*) as count FROM doctor WHERE is_deleted = 0;

SELECT '========================================' AS '';
SELECT 'doctor表中的医生列表:' AS message;
SELECT '========================================' AS '';
SELECT d.id, d.user_id, d.real_name, d.phone, d.hospital, d.department, u.username
FROM doctor d
LEFT JOIN user u ON d.user_id = u.id
WHERE d.is_deleted = 0
ORDER BY d.id
LIMIT 20;

SELECT '========================================' AS '';
SELECT '测试账号信息:' AS message;
SELECT '========================================' AS '';
SELECT '可以使用以下医生账号登录测试:' AS info;
SELECT '医生ID: 1, 用户名: 王建国' AS info;
SELECT '医生ID: 2, 用户名: 李淑琴' AS info;
SELECT '医生ID: 3, 用户名: 张志强' AS info;
SELECT '========================================' AS '';
