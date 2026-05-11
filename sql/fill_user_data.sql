-- =====================================================
-- Harmony Health Care - 数据填充脚本
-- 数据库: medical_health
-- 表名: user
-- 用途: 填充 user 表的空缺字段（real_name, phone, age, id_card, hospital, department 等）
-- 执行时间: 2026-05-11
-- =====================================================

-- =====================================================
-- 第一部分：更新患者数据 (user_type = 0)
-- =====================================================

UPDATE `user` SET 
    `real_name` = CASE `id`
        WHEN 113 THEN '张伟'
        WHEN 114 THEN '李娜'
        WHEN 115 THEN '王强'
        WHEN 116 THEN '刘芳'
        WHEN 117 THEN '陈明'
        WHEN 118 THEN '杨丽'
        WHEN 119 THEN '赵军'
        WHEN 120 THEN '黄敏'
        WHEN 121 THEN '周杰'
        WHEN 122 THEN '吴婷'
        WHEN 123 THEN '徐磊'
        WHEN 124 THEN '孙艳'
        WHEN 125 THEN '马超'
        WHEN 126 THEN '朱静'
        WHEN 127 THEN '胡涛'
        WHEN 128 THEN '郭雪'
        WHEN 129 THEN '林峰'
        WHEN 130 THEN '何颖'
        WHEN 131 THEN '高勇'
        WHEN 132 THEN '罗琳'
        ELSE CONCAT('用户', `id`)
    END,
    `phone` = CASE `id`
        WHEN 113 THEN '13800138001'
        WHEN 114 THEN '13800138002'
        WHEN 115 THEN '13800138003'
        WHEN 116 THEN '13800138004'
        WHEN 117 THEN '13800138005'
        WHEN 118 THEN '13800138006'
        WHEN 119 THEN '13800138007'
        WHEN 120 THEN '13800138008'
        WHEN 121 THEN '13800138009'
        WHEN 122 THEN '13800138010'
        WHEN 123 THEN '13800138011'
        WHEN 124 THEN '13800138012'
        WHEN 125 THEN '13800138013'
        WHEN 126 THEN '13800138014'
        WHEN 127 THEN '13800138015'
        WHEN 128 THEN '13800138016'
        WHEN 129 THEN '13800138017'
        WHEN 130 THEN '13800138018'
        WHEN 131 THEN '13800138019'
        WHEN 132 THEN '13800138020'
        ELSE CONCAT('139', LPAD(FLOOR(RAND() * 100000000), 8, '0'))
    END,
    `age` = CASE `id`
        WHEN 113 THEN 45
        WHEN 114 THEN 38
        WHEN 115 THEN 52
        WHEN 116 THEN 29
        WHEN 117 THEN 61
        WHEN 118 THEN 33
        WHEN 119 THEN 55
        WHEN 120 THEN 42
        WHEN 121 THEN 27
        WHEN 122 THEN 48
        WHEN 123 THEN 36
        WHEN 124 THEN 59
        WHEN 125 THEN 31
        WHEN 126 THEN 44
        WHEN 127 THEN 67
        WHEN 128 THEN 39
        WHEN 129 THEN 51
        WHEN 130 THEN 25
        WHEN 131 THEN 56
        WHEN 132 THEN 34
        ELSE FLOOR(20 + RAND() * 50)
    END,
    `id_card` = CASE `id`
        WHEN 113 THEN '110101197801011234'
        WHEN 114 THEN '110101198502022345'
        WHEN 115 THEN '110101197103033456'
        WHEN 116 THEN '110101199504044567'
        WHEN 117 THEN '110101196305055678'
        WHEN 118 THEN '110101198906066789'
        WHEN 119 THEN '110101196907077890'
        WHEN 120 THEN '110101198008088901'
        WHEN 121 THEN '110101199709099012'
        WHEN 122 THEN '110101197610101123'
        WHEN 123 THEN '110101198811111234'
        WHEN 124 THEN '110101196512122345'
        WHEN 125 THEN '110101199301133456'
        WHEN 126 THEN '110101198002144567'
        WHEN 127 THEN '110101195915155678'
        WHEN 128 THEN '110101198716166789'
        WHEN 129 THEN '110101197317177890'
        WHEN 130 THEN '110101199918188901'
        WHEN 131 THEN '110101197019199012'
        WHEN 132 THEN '110101199220110123'
        ELSE CONCAT('110', LPAD(FLOOR(196000000000 + RAND() * 400000000000), 15, '0'))
    END,
    `hospital` = '北京协和医院',
    `department` = CASE (`id` % 5)
        WHEN 0 THEN '心内科'
        WHEN 1 THEN '神经外科'
        WHEN 2 THEN '骨科'
        WHEN 3 THEN '呼吸科'
        WHEN 4 THEN '消化科'
    END,
    `update_time` = NOW()
WHERE `user_type` = 0 AND `is_deleted` = 0;

-- =====================================================
-- 第二部分：更新医生/护士数据 (user_type = 1)
-- =====================================================

UPDATE `user` SET 
    `real_name` = CASE `id`
        WHEN 1 THEN '王主任'
        WHEN 2 THEN '李医生'
        WHEN 3 THEN '张护士长'
        WHEN 4 THEN '刘医生'
        WHEN 5 THEN '陈护士'
        ELSE CONCAT('医护', `id`)
    END,
    `phone` = CASE `id`
        WHEN 1 THEN '13901010001'
        WHEN 2 THEN '13901010002'
        WHEN 3 THEN '13901010003'
        WHEN 4 THEN '13901010004'
        WHEN 5 THEN '13901010005'
        ELSE CONCAT('1390101', LPAD(`id`, 5, '0'))
    END,
    `age` = CASE `id`
        WHEN 1 THEN 48
        WHEN 2 THEN 35
        WHEN 3 THEN 32
        WHEN 4 THEN 41
        WHEN 5 THEN 28
        ELSE FLOOR(25 + RAND() * 25)
    END,
    `hospital` = '北京协和医院',
    `department` = CASE `id`
        WHEN 1 THEN '心内科'
        WHEN 2 THEN '神经外科'
        WHEN 3 THEN '护理部'
        WHEN 4 THEN '骨科'
        WHEN 5 THEN '呼吸科'
        ELSE '综合科室'
    END,
    `license_number` = CASE `id`
        WHEN 1 THEN 'MD110101199001010001'
        WHEN 2 THEN 'MD110101199002020002'
        WHEN 3 THEN 'NS110101199303030003'
        WHEN 4 THEN 'MD110101199404040004'
        WHEN 5 THEN 'NS110101199505050005'
        ELSE CONCAT('MD', LPAD(`id`, 18, '0'))
    END,
    `update_time` = NOW()
WHERE `user_type` = 1 AND `is_deleted` = 0;

-- =====================================================
-- 第三部分：验证更新结果
-- =====================================================

-- 查看更新后的患者数据
SELECT 
    id,
    username,
    real_name,
    phone,
    age,
    LEFT(id_card, 6) AS id_card_prefix,
    hospital,
    department,
    user_type,
    update_time
FROM `user` 
WHERE `is_deleted` = 0 
ORDER BY `user_type`, `id` 
LIMIT 30;

-- 统计更新情况
SELECT 
    COUNT(*) AS total_users,
    SUM(CASE WHEN real_name IS NOT NULL AND real_name != '' THEN 1 ELSE 0 END) AS has_real_name,
    SUM(CASE WHEN phone IS NOT NULL AND phone != '' THEN 1 ELSE 0 END) AS has_phone,
    SUM(CASE WHEN age IS NOT NULL AND age > 0 THEN 1 ELSE 0 END) AS has_age,
    SUM(CASE WHEN hospital IS NOT NULL AND hospital != '' THEN 1 ELSE 0 END) AS has_hospital,
    SUM(CASE WHEN department IS NOT NULL AND department != '' THEN 1 ELSE 0 END) AS has_department
FROM `user` 
WHERE `is_deleted` = 0;

-- =====================================================
-- 脚本执行完成提示
-- =====================================================
SELECT 
    '✅ 数据填充脚本执行成功！' AS message,
    NOW() AS execution_time;
