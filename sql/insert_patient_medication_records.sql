-- ============================================================
-- 插入100条用药记录到 patient_medication_record 表
-- 与患者表(user表 user_type=0)匹配
-- ============================================================

SET NAMES utf8mb4;

-- 查看患者总数（用于验证）
SELECT COUNT(*) AS patient_count FROM `user` WHERE user_type = 0 AND is_deleted = 0;

-- 插入100条用药记录
-- 使用存储过程批量插入，确保与患者表匹配

DELIMITER //

DROP PROCEDURE IF EXISTS insert_medication_records//

CREATE PROCEDURE insert_medication_records()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE patient_count INT DEFAULT 0;
    DECLARE rand_patient_id BIGINT DEFAULT 0;
    DECLARE rand_days INT DEFAULT 0;
    DECLARE drug_index INT DEFAULT 0;
    DECLARE status_val TINYINT DEFAULT 0;
    
    -- 获取患者总数
    SELECT COUNT(*) INTO patient_count FROM `user` WHERE user_type = 0 AND is_deleted = 0;
    
    -- 药品名称数组（20种常见药品）
    -- 频次数组（5种常见频次）
    
    WHILE i <= 100 DO
        -- 随机选择患者ID
        SET rand_patient_id = (
            SELECT id FROM `user` 
            WHERE user_type = 0 AND is_deleted = 0 
            ORDER BY RAND() 
            LIMIT 1
        );
        
        -- 随机天数（1-30天）
        SET rand_days = FLOOR(1 + RAND() * 30);
        
        -- 药品索引
        SET drug_index = ((i - 1) MOD 20) + 1;
        
        -- 随机状态（0-待执行 1-进行中 2-已完成）
        SET status_val = FLOOR(RAND() * 3);
        
        -- 插入用药记录
        INSERT INTO `patient_medication_record` (
            `patient_id`,
            `drug_name`,
            `dosage`,
            `frequency`,
            `start_time`,
            `end_time`,
            `status`,
            `remark`,
            `create_time`,
            `update_time`,
            `is_deleted`
        ) VALUES (
            rand_patient_id,
            CASE drug_index
                WHEN 1 THEN '阿司匹林肠溶片'
                WHEN 2 THEN '硝苯地平控释片'
                WHEN 3 THEN '盐酸二甲双胍片'
                WHEN 4 THEN '阿托伐他汀钙片'
                WHEN 5 THEN '厄贝沙坦片'
                WHEN 6 THEN '美托洛尔缓释片'
                WHEN 7 THEN '氨氯地平片'
                WHEN 8 THEN '格列美脲片'
                WHEN 9 THEN '氯吡格雷片'
                WHEN 10 THEN '辛伐他汀片'
                WHEN 11 THEN '缬沙坦胶囊'
                WHEN 12 THEN '氢氯噻嗪片'
                WHEN 13 THEN '福辛普利钠片'
                WHEN 14 THEN '瑞舒伐他汀钙片'
                WHEN 15 THEN '左旋氨氯地平片'
                WHEN 16 THEN '依那普利片'
                WHEN 17 THEN '吡格列酮片'
                WHEN 18 THEN '非洛地平缓释片'
                WHEN 19 THEN '替米沙坦片'
                ELSE '培哚普利片'
            END,
            CASE drug_index
                WHEN 1 THEN '100mg'
                WHEN 2 THEN '30mg'
                WHEN 3 THEN '500mg'
                WHEN 4 THEN '20mg'
                WHEN 5 THEN '150mg'
                WHEN 6 THEN '47.5mg'
                WHEN 7 THEN '5mg'
                WHEN 8 THEN '2mg'
                WHEN 9 THEN '75mg'
                WHEN 10 THEN '40mg'
                WHEN 11 THEN '80mg'
                WHEN 12 THEN '25mg'
                WHEN 13 THEN '10mg'
                WHEN 14 THEN '10mg'
                WHEN 15 THEN '2.5mg'
                WHEN 16 THEN '10mg'
                WHEN 17 THEN '15mg'
                WHEN 18 THEN '5mg'
                WHEN 19 THEN '80mg'
                ELSE '4mg'
            END,
            CASE (i MOD 5)
                WHEN 0 THEN '每日一次，晨起服用'
                WHEN 1 THEN '每日两次，早晚餐后'
                WHEN 2 THEN '每日三次，饭后服用'
                WHEN 3 THEN '每日一次，睡前服用'
                ELSE '隔日一次，规律服用'
            END,
            DATE_SUB(NOW(), INTERVAL rand_days DAY),
            CASE 
                WHEN status_val = 2 THEN DATE_SUB(NOW(), INTERVAL (rand_days - 7) DAY)
                ELSE NULL
            END,
            status_val,
            CASE 
                WHEN status_val = 0 THEN '新开处方，待开始用药'
                WHEN status_val = 1 THEN '正在服药中，请按时服用'
                ELSE '已完成疗程，疗效良好'
            END,
            DATE_SUB(NOW(), INTERVAL (rand_days + 1) DAY),
            NOW(),
            0
        );
        
        SET i = i + 1;
    END WHILE;
    
    -- 输出结果统计
    SELECT 
        COUNT(*) AS total_records,
        COUNT(DISTINCT patient_id) AS patient_count,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS pending_count,
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS ongoing_count,
        SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) AS completed_count
    FROM patient_medication_record;
    
END//

DELIMITER ;

-- 执行存储过程
CALL insert_medication_records();

-- 删除存储过程
DROP PROCEDURE IF EXISTS insert_medication_records;

-- 验证插入结果
SELECT 
    '插入结果统计' AS summary,
    COUNT(*) AS total_records,
    COUNT(DISTINCT patient_id) AS distinct_patients,
    SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS ongoing,
    SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) AS completed
FROM patient_medication_record;

-- 查看部分数据示例
SELECT 
    pmr.id,
    pmr.patient_id,
    u.real_name AS patient_name,
    pmr.drug_name,
    pmr.dosage,
    pmr.frequency,
    pmr.start_time,
    pmr.status,
    CASE pmr.status
        WHEN 0 THEN '待执行'
        WHEN 1 THEN '进行中'
        WHEN 2 THEN '已完成'
        ELSE '未知'
    END AS status_text
FROM patient_medication_record pmr
LEFT JOIN `user` u ON pmr.patient_id = u.id
ORDER BY pmr.id DESC
LIMIT 20;
