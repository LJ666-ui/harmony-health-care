-- 护士排班表 (nurse_schedule)
-- 用于管理护士的排班信息

CREATE TABLE IF NOT EXISTS `nurse_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '排班ID，主键自增',
  `nurse_id` bigint NOT NULL COMMENT '护士ID，关联nurse表',
  `nurse_name` varchar(50) DEFAULT NULL COMMENT '护士姓名（冗余存储）',
  `department` varchar(100) DEFAULT NULL COMMENT '科室（冗余存储）',
  `schedule_date` date NOT NULL COMMENT '排班日期',
  `shift_type` tinyint NOT NULL DEFAULT 1 COMMENT '班次类型: 1=早班(07:00-15:00) 2=中班(15:00-23:00) 3=夜班(23:00-07:00)',
  `ward_area` varchar(50) DEFAULT NULL COMMENT '负责病区',
  `bed_count` int DEFAULT 0 COMMENT '负责床位数量',
  `patient_ids` varchar(500) DEFAULT NULL COMMENT '负责患者ID列表(逗号分隔)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=请假/调休 1=正常排班 2=替班 3=加班',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_nurse_id` (`nurse_id`),
  INDEX `idx_schedule_date` (`schedule_date`),
  INDEX `idx_shift_type` (`shift_type`),
  INDEX `idx_department` (`department`),
  INDEX `idx_date_shift` (`schedule_date`, `shift_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='护士排班表';

-- 插入测试数据 - 基于现有护士数据生成一周的排班
-- 假设有10名护士 (id: 1-10)

INSERT INTO `nurse_schedule` (`nurse_id`, `nurse_name`, `department`, `schedule_date`, `shift_type`, `ward_area`, `bed_count`, `patient_ids`, `status`, `remark`) VALUES
-- 第一天 (今天)
(1, '张护士', '内科', CURDATE(), 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(2, '李护士', '内科', CURDATE(), 1, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(3, '王护士', '外科', CURDATE(), 1, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, NULL),
(4, '赵护士', '外科', CURDATE(), 2, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(5, '刘护士', '神经科', CURDATE(), 1, 'C区', 8, '63,64,65,66,67,68,69,70', 1, NULL),
(6, '陈护士', '神经科', CURDATE(), 2, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, NULL),
(7, '杨护士', '骨科', CURDATE(), 3, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, '夜班'),
(8, '周护士', '骨科', CURDATE(), 3, 'C区', 9, '92,93,94,95,96,97,98,99,100', 1, '夜班'),
(9, '吴护士', '呼吸科', CURDATE(), 1, 'A区', 10, '101,102,103,104,105,106,107,108,109,110', 1, NULL),
(10, '郑护士', '呼吸科', CURDATE(), 2, 'B区', 8, '111,112,113,114,115,116,117,118', 1, NULL),

-- 第二天 (明天)
(1, '张护士', '内科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(2, '李护士', '内科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, '夜班'),
(3, '王护士', '外科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 'C区', 8, '63,64,65,66,67,68,69,70', 1, NULL),
(4, '赵护士', '外科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, '夜班'),
(5, '刘护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(6, '陈护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 'C区', 8, '63,64,65,66,67,68,69,70', 1, '夜班'),
(7, '杨护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, NULL),
(8, '周护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, NULL),
(9, '吴护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 'C区', 9, '92,93,94,95,96,97,98,99,100', 1, NULL),
(10, '郑护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 'A区', 10, '101,102,103,104,105,106,107,108,109,110', 1, '夜班'),

-- 第三天
(1, '张护士', '内科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 'C区', 8, '119,120,121,122,123,124,125,126', 1, '夜班'),
(2, '李护士', '内科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(3, '王护士', '外科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, '夜班'),
(4, '赵护士', '外科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, NULL),
(5, '刘护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, '夜班'),
(6, '陈护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(7, '杨护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 'C区', 9, '92,93,94,95,96,97,98,99,100', 1, NULL),
(8, '周护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, NULL),
(9, '吴护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 'B区', 8, '111,112,113,114,115,116,117,118', 1, '夜班'),
(10, '郑护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 'A区', 10, '101,102,103,104,105,106,107,108,109,110', 1, NULL),

-- 第四天
(1, '张护士', '内科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 'A区', 12, '21,22,23,24,25,26,27,28,29,30,31,32', 1, NULL),
(2, '李护士', '内科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(3, '王护士', '外科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 'A区', 11, '43,44,45,46,47,48,49,50,51,52,53', 1, NULL),
(4, '赵护士', '外科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(5, '刘护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 'C区', 8, '127,128,129,130,131,132,133,134', 1, NULL),
(6, '陈护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, NULL),
(7, '杨护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 'A区', 10, '135,136,137,138,139,140,141,142,143,144', 1, '夜班'),
(8, '周护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, '夜班'),
(9, '吴护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 1, 'C区', 9, '145,146,147,148,149,150,151,152,153', 1, NULL),
(10, '郑护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 'B区', 8, '154,155,156,157,158,159,160,161', 1, NULL),

-- 第五天
(1, '张护士', '内科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 'B区', 10, '33,34,35,36,37,38,39,40,41,42', 1, NULL),
(2, '李护士', '内科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 3, 'C区', 8, '162,163,164,165,166,167,168,169', 1, '夜班'),
(3, '王护士', '外科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 'C区', 8, '170,171,172,173,174,175,176,177', 1, NULL),
(4, '赵护士', '外科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 3, 'C区', 8, '178,179,180,181,182,183,184,185', 1, '夜班'),
(5, '刘护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 'B区', 9, '54,55,56,57,58,59,60,61,62', 1, NULL),
(6, '陈护士', '神经科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 3, 'C区', 8, '186,187,188,189,190,191,192,193', 1, '夜班'),
(7, '杨护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1, 'A区', 10, '71,72,73,74,75,76,77,78,79,80', 1, NULL),
(8, '周护士', '骨科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1, 'B区', 11, '81,82,83,84,85,86,87,88,89,90,91', 1, NULL),
(9, '吴护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 'A区', 10, '194,195,196,197,198,199,200,201,202,203', 1, NULL),
(10, '郑护士', '呼吸科', DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1, 'C区', 9, '204,205,206,207,208,209,210,211,212', 1, NULL);

-- 查询验证
SELECT 
  ns.*,
  n.nurse_no,
  n.phone,
  n.title
FROM nurse_schedule ns
LEFT JOIN nurse n ON ns.nurse_id = n.id
WHERE ns.is_deleted = 0
ORDER BY ns.schedule_date, ns.shift_type, ns.nurse_id;
