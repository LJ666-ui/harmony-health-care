-- ============================================================
-- 护理记录表（nursing_record）
-- 用于存储护士对患者的护理记录
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for nursing_record
-- ----------------------------
DROP TABLE IF EXISTS `nursing_record`;
CREATE TABLE `nursing_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '护理记录ID，主键自增',
  `patient_id` bigint NOT NULL COMMENT '患者ID，关联user表id (user_type=0)',
  `nurse_id` bigint NULL DEFAULT NULL COMMENT '护士ID，关联nurse表id',
  `record_type` tinyint NOT NULL DEFAULT 1 COMMENT '护理记录类型：1-生命体征监测 2-用药护理 3-伤口护理 4-日常护理 5-术后护理 6-康复护理',
  `record_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '护理记录内容',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
  `vital_signs` json NULL DEFAULT NULL COMMENT '生命体征数据JSON（体温、血压、心率等）',
  `care_time` datetime NULL DEFAULT NULL COMMENT '护理时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-未删除 1-已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_nurse_id`(`nurse_id`) USING BTREE,
  INDEX `idx_record_type`(`record_type`) USING BTREE,
  INDEX `idx_care_time`(`care_time`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '护理记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of nursing_record (示例数据)
-- ----------------------------
-- 插入一些示例护理记录
INSERT INTO `nursing_record` (`patient_id`, `nurse_id`, `record_type`, `record_content`, `remark`, `vital_signs`, `care_time`) 
VALUES 
(21, 1, 1, '今日生命体征监测：体温36.8℃，脉搏78次/分，呼吸18次/分，血压120/80mmHg，各项指标正常。', '患者状态良好', '{"temperature": 36.8, "pulse": 78, "respiration": 18, "bloodPressure": "120/80"}', NOW()),

(22, 1, 2, '遵医嘱给予降压药物治疗，硝苯地平控释片30mg口服，患者服药配合良好。', '服药后观察30分钟无不良反应', NULL, NOW()),

(21, 2, 3, '右侧手臂伤口换药，伤口愈合良好，无红肿渗出，使用碘伏消毒后更换敷料。', '继续观察伤口情况', NULL, NOW()),

(23, 2, 4, '协助患者进行日常生活护理：晨间护理、床单位整理、口腔清洁，患者配合度好。', NULL, NULL, NOW()),

(21, 1, 5, '术后第3天护理观察：切口愈合良好，无明显疼痛，患者可下床活动，饮食恢复良好。', '术后恢复顺利', NULL, NOW()),

(24, 2, 6, '康复训练指导：协助患者进行下肢功能锻炼，踝泵运动10次，直腿抬高练习5次。', '患者配合良好，训练完成度100%', NULL, NOW()),

(22, 1, 1, '午间生命体征监测：体温37.2℃，脉搏82次/分，呼吸20次/分，血压130/85mmHg。', '体温稍高，继续监测', '{"temperature": 37.2, "pulse": 82, "respiration": 20, "bloodPressure": "130/85"}', NOW()),

(23, 2, 2, '遵医嘱给予降糖药物治疗，盐酸二甲双胍片500mg口服，每日两次。', '餐后血糖监测待执行', NULL, NOW());

-- ----------------------------
-- 验证表创建
-- ----------------------------
SELECT 
    COUNT(*) AS record_count,
    COUNT(DISTINCT patient_id) AS patient_count,
    COUNT(DISTINCT nurse_id) AS nurse_count
FROM nursing_record;

-- 查看插入的示例数据
SELECT 
    nr.id,
    nr.patient_id,
    u.real_name AS patient_name,
    nr.nurse_id,
    n.real_name AS nurse_name,
    CASE nr.record_type
        WHEN 1 THEN '生命体征监测'
        WHEN 2 THEN '用药护理'
        WHEN 3 THEN '伤口护理'
        WHEN 4 THEN '日常护理'
        WHEN 5 THEN '术后护理'
        WHEN 6 THEN '康复护理'
        ELSE '其他'
    END AS record_type_text,
    nr.record_content,
    nr.care_time,
    nr.create_time
FROM nursing_record nr
LEFT JOIN `user` u ON nr.patient_id = u.id
LEFT JOIN nurse n ON nr.nurse_id = n.id
WHERE nr.is_deleted = 0
ORDER BY nr.create_time DESC;
