-- =====================================================
-- 创建 follow_up 复诊表并插入测试数据
-- 功能：患者复诊/检查/体检安排管理
-- 执行时间: 2026-05-11
-- =====================================================

-- 1️⃣ 创建 follow_up 复诊表（如果不存在）
CREATE TABLE IF NOT EXISTS `follow_up` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '复诊ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `type` varchar(20) NOT NULL DEFAULT 'FOLLOW_UP' COMMENT '类型：FOLLOW_UP-复诊, CHECKUP-检查, EXAM-体检, SURGERY-手术',
  `title` varchar(200) NOT NULL COMMENT '标题/诊断名称',
  `hospital_name` varchar(200) NULL DEFAULT '' COMMENT '医院名称',
  `department` varchar(100) NULL DEFAULT '' COMMENT '科室名称',
  `doctor_name` varchar(100) NULL DEFAULT '' COMMENT '医生姓名',
  `follow_up_date` date NOT NULL COMMENT '复诊日期',
  `follow_up_time` varchar(10) NULL DEFAULT '' COMMENT '复诊时间（如09:00）',
  `status` varchar(20) NOT NULL DEFAULT 'UPCOMING' COMMENT '状态：UPCOMING-待就诊, COMPLETED-已完成, CANCELLED-已取消, OVERDUE-已过期',
  `notes` text NULL COMMENT '备注说明',
  `reminder_enabled` tinyint NOT NULL DEFAULT 1 COMMENT '是否开启提醒：0-关闭, 1-开启',
  `reminder_days_before` int NOT NULL DEFAULT 1 COMMENT '提前几天提醒',
  `created_by` bigint NULL COMMENT '创建人ID（医生或患者）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '是否删除：0-否, 1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_patient_id` (`patient_id`) USING BTREE,
  INDEX `idx_follow_up_date` (`follow_up_date`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE,
  INDEX `idx_type` (`type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '复诊安排表' ROW_FORMAT = DYNAMIC;

SELECT '✅ 复诊表创建成功！' AS result;

-- 2️⃣ 清空可能存在的旧测试数据
DELETE FROM follow_up WHERE patient_id IN (21, 22, 23, 24, 25);
SELECT '🧹 已清理旧测试数据' AS result;

-- 3️⃣ 插入测试复诊数据
INSERT INTO follow_up (patient_id, type, title, hospital_name, department, doctor_name, follow_up_date, follow_up_time, status, notes, reminder_enabled, reminder_days_before, created_by) VALUES

-- 患者21 马建军 - 高血压患者的复诊安排
(21, 'FOLLOW_UP', '高血压复查', '首都医科大学附属北京同仁医院西院', '心血管内科', '王建国', DATE_ADD(CURDATE(), INTERVAL 7 DAY), '09:00', 'UPCOMING', '请携带上次检查报告，包括心电图和血生化结果', 1, 2, 1),
(21, 'CHECKUP', '血压监测', '社区医院', '全科门诊', '', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '08:30', 'UPCOMING', '每日早晚各测一次血压并记录', 1, 1, 21),

-- 患者22 任桂花 - 糖尿病患者的复诊安排
(22, 'FOLLOW_UP', '糖尿病随访', '首都医科大学附属北京同仁医院西院', '内分泌科', '李医生', DATE_ADD(CURDATE(), INTERVAL 14 DAY), '10:30', 'UPCOMING', '空腹8小时以上，携带血糖记录本', 1, 2, 1),
(22, 'CHECKUP', '糖化血红蛋白检测', '首都医科大学附属北京同仁医院西院', '检验科', '', DATE_ADD(CURDATE(), INTERVAL 14 DAY), '10:00', 'UPCOMING', '无需空腹，与糖尿病随访同日进行', 0, 1, 22),
(22, 'EXAM', '年度体检', '社区医院', '体检中心', '', DATE_ADD(CURDATE(), INTERVAL 30 DAY), '08:00', 'UPCOMING', '包含眼底、肾功能、神经传导等项目', 1, 3, 22),

-- 患者23 谢建强 - 重症高血压+冠心病患者的复诊安排
(23, 'FOLLOW_UP', '心血管专科复诊', '首都医科大学附属北京安贞医院', '心血管内科', '张主任', DATE_ADD(CURDATE(), INTERVAL 5 DAY), '14:00', 'UPCOMING', '带好近期心电图、心脏超声报告，提前半小时到达', 1, 2, 1),
(23, 'CHECKUP', '凝血功能检查', '首都医科大学附属北京安贞医院', '检验科', '', DATE_ADD(CURDATE(), INTERVAL 5 DAY), '08:00', 'UPCOMING', '服用阿司匹林期间需定期监测', 1, 1, 23),
(23, 'EXAM', '心脏彩超复查', '首都医科大学附属北京安贞医院', '超声科', '', DATE_ADD(CURDATE(), INTERVAL 60 DAY), '09:30', 'UPCOMING', '评估心功能和瓣膜情况', 1, 3, 1),

-- 患者24 周秀英 - 脑梗死后遗症患者的康复安排
(24, 'FOLLOW_UP', '神经内科复诊', '首都医科大学附属北京天坛医院', '神经内科', '刘主任', DATE_ADD(CURDATE(), INTERVAL 10 DAY), '15:30', 'UPCOMING', '评估肢体功能和语言恢复情况', 1, 2, 1),
(24, 'CHECKUP', '头颅CT复查', '首都医科大学附属北京天坛医院', '放射科', '', DATE_ADD(CURDATE(), INTERVAL 90 DAY), '10:00', 'UPCOMING', '脑梗后3个月常规复查', 1, 3, 24),

-- 患者25 吴国华 - 慢性支气管炎患者（已完成的记录）
(25, 'FOLLOW_UP', '呼吸科复诊', '首都医科大学附属北京朝阳医院', '呼吸内科', '陈医生', DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:00', 'OVERDUE', '请尽快补约，评估肺部情况', 1, 1, 1),
(25, 'EXAM', '肺功能检查', '首都医科大学附属北京朝阳医院', '肺功能室', '', DATE_ADD(CURDATE(), INTERVAL -3 DAY), '14:00', 'CANCELLED', '因故取消，需重新预约', 0, 2, 25);

SELECT '✅ 测试复诊数据插入成功！共12条记录' AS result;

-- 4️⃣ 验证插入结果
SELECT '========== 数据验证 ==========' AS info;

SELECT 
  '按状态统计' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN status = 'UPCOMING' THEN 1 ELSE 0 END) AS upcoming_count,
  SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_count,
  SUM(CASE WHEN status = 'OVERDUE' THEN 1 ELSE 0 END) AS overdue_count,
  SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_count
FROM follow_up WHERE is_deleted = 0;

SELECT 
  '按类型统计' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN type = 'FOLLOW_UP' THEN 1 ELSE 0 END) AS follow_up,
  SUM(CASE WHEN type = 'CHECKUP' THEN 1 ELSE 0 END) AS checkup,
  SUM(CASE WHEN type = 'EXAM' THEN 1 ELSE 0 END) AS exam
FROM follow_up WHERE is_deleted = 0;

SELECT '=== 患者复诊列表 ===' AS info;
SELECT 
  id,
  patient_id,
  type,
  title,
  hospital_name,
  department,
  doctor_name,
  follow_up_date,
  follow_up_time,
  status,
  LEFT(notes, 40) AS notes_summary
FROM follow_up
WHERE is_deleted = 0
ORDER BY follow_up_date ASC, follow_up_time ASC;

SELECT '🎉 复诊表及测试数据准备完成！可以开始测试前端功能了！' AS success_message;
