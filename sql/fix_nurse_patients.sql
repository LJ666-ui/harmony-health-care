-- ============================================
-- 护士端患者数据修复脚本
-- 在 Navicat Premium 中执行
-- ============================================

-- 第1步：检查ID=21, 22, 25的用户详情
SELECT '=== 第1步：检查目标患者ID ===' AS step;
SELECT id, username, real_name, phone, user_type, age, gender, is_deleted, create_time
FROM user 
WHERE id IN (21, 22, 25);

-- 第2步：查看所有user_type=0的患者（看看有哪些有姓名的）
SELECT '=== 第2步：所有患者类型用户 ===' AS step;
SELECT id, username, real_name, phone, user_type, age, gender, is_deleted
FROM user 
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id DESC
LIMIT 20;

-- 第3步：检查当前最大的user ID
SELECT '=== 第3步：最大用户ID ===' AS step;
SELECT MAX(id) AS max_user_id FROM user;

-- ============================================
-- 根据上面的结果选择执行下面的修复语句
-- ============================================

-- 【情况A】如果ID 21, 22, 25不存在，插入新记录
-- INSERT INTO user (id, username, password, real_name, phone, user_type, age, gender, is_deleted, status, create_time, update_time) VALUES
-- (21, 'patient21', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', '张三', '13900139000', 0, 45, 1, 0, 1, NOW(), NOW()),
-- (22, 'patient22', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', '李四', '13900139001', 0, 52, 2, 0, 1, NOW(), NOW()),
-- (25, 'patient25', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', '王五', '13900139002', 0, 38, 1, 0, 1, NOW(), NOW());

-- 【情况B】如果ID存在但real_name为NULL，更新它们
-- UPDATE user SET 
--     real_name = CASE id
--         WHEN 21 THEN '张三'
--         WHEN 22 THEN '李四'
--         WHEN 25 THEN '王五'
--     END,
--     phone = CASE id
--         WHEN 21 THEN '13900139000'
--         WHEN 22 THEN '13900139001'
--         WHEN 25 THEN '13900139002'
--     END,
--     age = CASE id
--         WHEN 21 THEN 45
--         WHEN 22 THEN 52
--         WHEN 25 THEN 38
--     END,
--     gender = CASE id
--         WHEN 21 THEN 1
--         WHEN 22 THEN 2
--         WHEN 25 THEN 1
--     END
-- WHERE id IN (21, 22, 25) AND (real_name IS NULL OR real_name = '');

-- 【情况C】如果需要使用已存在的患者ID，修改关联关系
-- 先查看哪些患者ID有完整的姓名
-- SELECT id, username, real_name, user_type FROM user WHERE user_type=0 AND real_name IS NOT NULL LIMIT 10;
-- 然后更新nurse_patient_relation表：
-- UPDATE nurse_patient_relation SET patient_id = 已存在的患者ID WHERE id = 17; -- 对应原来的21
-- UPDATE nurse_patient_relation SET patient_id = 已存在的患者ID WHERE id = 18; -- 对应原来的22
-- UPDATE nurse_patient_relation SET patient_id = 已存在的患者ID WHERE id = 19; -- 对应原来的25

-- ============================================
-- 最终验证：执行完修复后运行这条
-- ============================================

SELECT '=== 最终验证 ===' AS step;
SELECT 
    npr.id AS relation_id,
    npr.nurse_id,
    npr.patient_id,
    u.real_name AS patient_name,
    u.username,
    u.user_type,
    u.age,
    u.gender,
    u.is_deleted,
    CASE 
        WHEN u.real_name IS NOT NULL AND u.real_name != '' THEN '✅ 有姓名'
        ELSE '❌ 缺少姓名'
    END AS name_status,
    CASE 
        WHEN u.user_type = 0 THEN '✅ 类型正确(患者)'
        ELSE '❌ 类型错误'
    END AS type_status
FROM nurse_patient_relation npr
LEFT JOIN user u ON npr.patient_id = u.id
WHERE npr.is_deleted = 0
ORDER BY npr.id;
