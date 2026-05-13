-- Harmony Health Care - 护士端患者列表测试数据初始化
-- 用于前后端连接测试

-- 1. 插入测试护士账号（如果不存在）
INSERT IGNORE INTO user (username, password, phone, age, user_type, real_name, is_deleted, create_time)
VALUES ('nurse_test', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13800138000', 30, 1, '测试护士', 0, NOW());

-- 2. 插入护士信息到nurse表（如果不存在）
INSERT IGNORE INTO nurse (user_id, nurse_no, name, gender, phone, department, title, status, is_deleted)
SELECT id, CONCAT('NURSE', LPAD(id, 6, '0')), '测试护士', 1, phone, '内科', '主管护师', 1, 0
FROM user WHERE username = 'nurse_test' AND is_deleted = 0;

-- 3. 插入8个测试患者（user_type=0，如果不存在）
INSERT IGNORE INTO user (username, password, phone, age, user_type, real_name, id_card, is_deleted, create_time) VALUES
('patient_zhangsan', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139001', 45, 0, '张三', '110101199001011234', 0, NOW()),
('patient_lisi', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139002', 52, 0, '李四', '110101199002022345', 0, NOW()),
('patient_wangwu', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139003', 38, 0, '王五', '110101199003033456', 0, NOW()),
('patient_zhaoliu', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139004', 67, 0, '赵六', '110101195604044567', 0, NOW()),
('patient_sunqi', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139005', 29, 0, '孙七', '110101199705055678', 0, NOW()),
('patient_zhouba', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139006', 55, 0, '周八', '110101197006066789', 0, NOW()),
('patient_wujiu', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139007', 41, 0, '吴九', '110101198507077890', 0, NOW()),
('patient_shengshi', '$2a$10$N9qo8uLOickg2ZERZHSOo3MPcVUVDXjz0FvZREuZRzJqHM8Y5z2e', '13900139008', 63, 0, '郑十', '110101196308088901', 0, NOW());

-- 4. 验证插入结果
SELECT '=== 数据验证 ===' AS '';
SELECT '' AS '';
SELECT '📊 用户统计:' AS '';
SELECT
    COUNT(*) AS 总用户数,
    SUM(CASE WHEN user_type=0 THEN 1 ELSE 0 END) AS 患者数,
    SUM(CASE WHEN user_type=1 THEN 1 ELSE 0 END) AS 医护数
FROM user WHERE is_deleted=0;

SELECT '' AS '';
SELECT '👨‍⚕️ 测试护士账号:' AS '';
SELECT n.id, n.name AS 姓名, n.phone AS 手机号, n.department AS 科室
FROM nurse n WHERE n.name = '测试护士';

SELECT '' AS '';
SELECT '👥 患者列表 (user_type=0):' AS '';
SELECT id, real_name AS 姓名, phone AS 手机号, age AS 年龄,
       CASE WHEN id_card IS NOT NULL AND LENGTH(id_card)=18
            THEN CASE MOD(SUBSTRING(id_card,17,1),2) WHEN 1 THEN '男' ELSE '女' END
            ELSE '未知' END AS 性别
FROM user WHERE user_type=0 AND is_deleted=0 AND username LIKE 'patient_%%'
ORDER BY id;

SELECT '' AS '';
SELECT '✅ 测试数据初始化完成！' AS '';
