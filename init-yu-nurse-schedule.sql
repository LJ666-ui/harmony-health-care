-- ============================================================
-- 于护士专属排班表初始化脚本
-- 执行环境: medical_health 数据库
-- 说明: 所有班次仅分配给"于护士"(ID=202330001)
-- ============================================================

-- 1. 创建护士排班表（如果不存在）
CREATE TABLE IF NOT EXISTS `nurse_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `nurse_id` bigint NOT NULL COMMENT '护士ID',
  `nurse_name` varchar(50) DEFAULT NULL COMMENT '护士姓名',
  `department` varchar(100) DEFAULT NULL COMMENT '科室',
  `schedule_date` date NOT NULL COMMENT '排班日期',
  `shift_type` tinyint NOT NULL DEFAULT 1 COMMENT '班次:1=早班 2=中班 3=夜班',
  `ward_area` varchar(50) DEFAULT NULL COMMENT '病区',
  `bed_count` int DEFAULT 0 COMMENT '床位数量',
  `patient_ids` varchar(500) DEFAULT NULL COMMENT '患者ID列表',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态:0=请假 1=正常 2=替班 3=加班',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_nurse_id` (`nurse_id`),
  INDEX `idx_schedule_date` (`schedule_date`),
  INDEX `idx_shift_type` (`shift_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='护士排班表';

-- 2. 清空旧数据（可选）
-- DELETE FROM nurse_schedule WHERE is_deleted = 0;

-- 3. 插入今日数据 (2026-05-12) - 于护士三个班次
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-12', 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(202330001, '于护士', '内科', '2026-05-12', 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(202330001, '于护士', '内科', '2026-05-12', 3, 'C区', 8, '63,64,65,66,67,68,69,70', 1, '夜班');

-- 4. 插入明天数据 (2026-05-13)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-13', 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(202330001, '于护士', '内科', '2026-05-13', 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(202330001, '于护士', '内科', '2026-05-13', 3, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, '夜班');

-- 5. 插入后天数据 (2026-05-14)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-14', 1, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(202330001, '于护士', '内科', '2026-05-14', 2, 'C区', 8, '71,72,73,74,75,76,77,78,79,80', 1, NULL),
(202330001, '于护士', '内科', '2026-05-14', 3, 'B区', 10, '81,82,83,84,85,86,87,88,89,90,91', 1, '夜班');

-- 6. 插入第4天数据 (2026-05-15)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-15', 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(202330001, '于护士', '内科', '2026-05-15', 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(202330001, '于护士', '内科', '2026-05-15', 3, 'C区', 9, '92,93,94,95,96,97,98,99,100', 1, '夜班');

-- 7. 插入第5天数据 (2026-05-16)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-16', 1, 'C区', 8, '101,102,103,104,105,106,107,108,109,110', 1, NULL),
(202330001, '于护士', '内科', '2026-05-16', 2, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, NULL),
(202330001, '于护士', '内科', '2026-05-16', 3, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, '夜班');

-- 8. 插入第6天数据 (2026-05-17)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-17', 1, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(202330001, '于护士', '内科', '2026-05-17', 2, 'C区', 8, '111,112,113,114,115,116,117,118', 1, NULL),
(202330001, '于护士', '内科', '2026-05-17', 3, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, '夜班');

-- 9. 插入第7天数据 (2026-05-18)
INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
(202330001, '于护士', '内科', '2026-05-18', 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(202330001, '于护士', '内科', '2026-05-18', 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(202330001, '于护士', '内科', '2026-05-18', 3, 'C区', 9, '92,93,94,95,96,97,98,99,100', 1, '夜班');

-- 10. 验证查询
SELECT 
    schedule_date as '日期',
    shift_type as '班次类型',
    ward_area as '病区',
    bed_count as '床位数',
    patient_ids as '负责患者'
FROM nurse_schedule 
WHERE is_deleted = 0 AND nurse_id = 202330001
ORDER BY schedule_date, shift_type;

SELECT CONCAT('于护士总排班记录数: ', COUNT(*)) as '统计' 
FROM nurse_schedule 
WHERE is_deleted = 0 AND nurse_id = 202330001;
