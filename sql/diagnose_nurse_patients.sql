-- ============================================
-- 护士端患者列表数据诊断与修复脚本
-- 在 Navicat Premium 或 MySQL 客户端中执行
-- ============================================

-- 第1步：检查当前登录护士的信息
SELECT '=== 护士表数据 ===' AS step;
SELECT id, user_id, name, job_number, phone, department, is_deleted 
FROM nurse 
WHERE job_number = 'N20230001' OR id = 1;

-- 第2步：检查护士对应的用户账号
SELECT '=== 用户表-护士账号 ===' AS step;
SELECT id, username, real_name, phone, user_type, is_deleted 
FROM user 
WHERE phone = '13800138001' 
   OR id IN (SELECT user_id FROM nurse WHERE id = 1);

-- 第3步：检查护士患者关联关系
SELECT '=== 护士患者关联关系 ===' AS step;
SELECT npr.id, npr.nurse_id, npr.patient_id, npr.is_deleted,
       n.name AS nurse_name,
       u.real_name AS patient_name,
       u.user_type,
       u.is_deleted AS patient_is_deleted
FROM nurse_patient_relation npr
LEFT JOIN nurse n ON npr.nurse_id = n.id
LEFT JOIN user u ON npr.patient_id = u.id
WHERE npr.is_deleted = 0;

-- 第4步：检查所有患者用户（user_type=0）
SELECT '=== 患者用户列表 ===' AS step;
SELECT id, username, real_name, phone, user_type, age, gender, is_deleted, create_time
FROM user 
WHERE user_type = 0 AND is_deleted = 0
ORDER BY id DESC
LIMIT 20;

-- 第5步：检查ID为21、22、25的用户是否存在
SELECT '=== 目标患者详情 ===' AS step;
SELECT id, username, real_name, phone, user_type, age, gender, is_deleted, create_time
FROM user 
WHERE id IN (21, 22, 25);

-- ============================================
-- 如果上述查询发现数据缺失，执行以下修复语句
-- ============================================

-- 修复1：如果nurse表没有数据，插入测试护士
-- INSERT INTO nurse (id, user_id, name, job_number, phone, department, password, create_time)
-- VALUES (1, 1, '测试护士', 'N20230001', '13800138001', '内科', '$2a$10$加密密码', NOW());

-- 修复2：如果user表没有护士账号，插入
-- INSERT INTO user (id, username, password, real_name, phone, user_type, age, gender, is_deleted, create_time)
-- VALUES (1, 'nurse001', '$2a$10$加密密码', '测试护士', '13800138001', 2, 35, 1, 0, NOW());
-- 注意：user_type=2 表示护士

-- 修复3：如果user表没有患者数据，插入测试患者
-- INSERT INTO user (id, username, password, real_name, phone, user_type, age, gender, is_deleted, create_time) VALUES
-- (21, 'patient21', '$2a$10$加密密码', '张三', '13900139000', 0, 45, 1, 0, NOW()),
-- (22, 'patient22', '$2a$10$加密密码', '李四', '13900139001', 0, 52, 2, 0, NOW()),
-- (25, 'patient25', '$2a$10$加密密码', '王五', '13900139002', 0, 38, 1, 0, NOW());
-- 注意：user_type=0 表示患者

-- ============================================
-- 验证修复结果
-- ============================================

-- 最终验证：完整的查询链路
SELECT '=== 最终验证 - 完整数据链路 ===' AS step;
SELECT 
    n.id AS nurse_id,
    n.name AS nurse_name,
    n.job_number,
    npr.patient_id,
    u.real_name AS patient_name,
    u.user_type,
    CASE 
        WHEN u.user_type = 0 THEN '✅ 患者类型正确'
        ELSE '❌ 类型错误'
    END AS type_check,
    CASE 
        WHEN u.is_deleted = 0 THEN '✅ 未删除'
        ELSE '❌ 已删除'
    END AS deleted_check
FROM nurse_patient_relation npr
JOIN nurse n ON npr.nurse_id = n.id AND n.is_deleted = 0
JOIN user u ON npr.patient_id = u.id AND u.is_deleted = 0
WHERE npr.is_deleted = 0
ORDER BY npr.id;
