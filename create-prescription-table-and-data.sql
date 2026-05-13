-- =====================================================
-- 创建 prescription 表并插入测试数据
-- 解决：Table 'medical_health.prescription' doesn't exist
-- 执行时间: 2026-05-11
-- =====================================================

-- 1️⃣ 首先创建 prescription 表（如果不存在）
CREATE TABLE IF NOT EXISTS `prescription` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '处方ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `patient_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '患者姓名',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '医生姓名',
  `medications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '药品信息（JSON格式）',
  `diagnosis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '诊断',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '备注',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE' COMMENT '状态：ACTIVE-有效, COMPLETED-已完成, CANCELLED-已取消',
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `valid_until` datetime NULL DEFAULT NULL COMMENT '有效期至',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_patient_id` (`patient_id`) USING BTREE,
  INDEX `idx_doctor_id` (`doctor_id`) USING BTREE,
  INDEX `idx_status` (`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '处方表' ROW_FORMAT = DYNAMIC;

SELECT '✅ 处方表创建成功！' AS result;

-- 2️⃣ 清空可能存在的旧测试数据（避免重复）
DELETE FROM prescription WHERE doctor_id = 1 AND patient_id IN (21, 22, 23, 24, 25);
SELECT '🧹 已清理旧测试数据' AS result;

-- 3️⃣ 插入测试处方数据
INSERT INTO prescription (patient_id, patient_name, doctor_id, doctor_name, medications, diagnosis, notes, status, created_at, valid_until) VALUES
(21, '马建军', 1, '张伟',
 '[{"medicineName":"氨氯地平片","specification":"5mg*28片","dosage":"5mg","frequency":"每日一次","quantity":2,"unit":"盒"},{"medicineName":"厄贝沙坦片","specification":"150mg*7片","dosage":"150mg","frequency":"每日一次","quantity":4,"unit":"盒"}]',
 '原发性高血压2级（中危）',
 '1. 服药期间监测血压，如出现头晕、乏力及时就诊\n2. 定期复查血钾、肾功能\n3. 药品需阴凉干燥处保存\n4. 有效期30天，按时服药不可随意停药',
 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(22, '任桂花', 1, '张伟',
 '[{"medicineName":"二甲双胍缓释片","specification":"500mg*30片","dosage":"500mg","frequency":"每日三次餐前","quantity":3,"unit":"盒"},{"medicineName":"阿卡波糖片","specification":"50mg*30片","dosage":"50mg","frequency":"每日三餐时嚼服","quantity":3,"unit":"盒"},{"medicineName":"血糖仪试纸","specification":"50条/盒","dosage":"","frequency":"","quantity":2,"unit":"盒"}]',
 '2型糖尿病',
 '1. 监测血糖谱（空腹+三餐后2小时+睡前）\n2. 注意预防低血糖，随身携带糖果\n3. 如出现恶心、腹泻等胃肠道反应，可餐中服用\n4. 定期复查糖化血红蛋白、肝肾功能',
 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(23, '谢建强', 1, '张伟',
 '[{"medicineName":"硝苯地平控释片","specification":"30mg*7片","dosage":"30mg","frequency":"每日早晨一次","quantity":4,"unit":"盒"},{"medicineName":"阿托伐他汀钙片","specification":"20mg*7片","dosage":"20mg","frequency":"每晚一次","quantity":4,"unit":"盒"},{"medicineName":"阿司匹林肠溶片","specification":"100mg*30片","dosage":"100mg","frequency":"每日早餐后一次","quantity":1,"unit":"盒"},{"medicineName":"单硝酸异山梨酯片","specification":"20mg*48片","dosage":"20mg","frequency":"每日早晚各一次","quantity":1,"unit":"瓶"}]',
 '高血压病3级（极高危）伴冠心病',
 '⚠️ 重症患者注意事项：\n1. 绝对卧床休息，心电监护24小时\n2. 严密监测血压、心率变化\n3. 注意观察有无胸痛、胸闷加重\n4. 保持大便通畅，必要时使用缓泻剂\n5. 低盐低脂饮食，少量多餐\n6. 备好硝酸甘油急救用药',
 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(24, '周秀英', 1, '张伟',
 '[{"medicineName":"阿司匹林肠溶片","specification":"100mg*30片","dosage":"100mg","frequency":"每日一次","quantity":1,"unit":"盒"},{"medicineName":"阿托伐他汀钙片","specification":"20mg*7片","dosage":"20mg","frequency":"每晚一次","quantity":4,"unit":"盒"},{"medicineName":"甲钴胺片","specification":"0.5mg*48片","dosage":"0.5mg","frequency":"每日三次","quantity":2,"unit":"瓶"},{"medicineName":"维生素B1片","specification":"10mg*100片","dosage":"10mg","frequency":"每日三次","quantity":1,"unit":"瓶"}]',
 '脑梗死后遗症期',
 '康复指导：\n1. 坚持肢体功能锻炼，每日2-3次，每次30分钟\n2. 语言训练：从简单发音开始，循序渐进\n3. 预防并发症：定时翻身拍背（每2小时一次）\n4. 心理疏导，保持乐观心态\n5. 定期复查头颅CT/MRI',
 'ACTIVE', NOW(), DATE_ADD(NOW(), INTERVAL 60 DAY)),

(25, '吴国华', 1, '张伟',
 '[{"medicineName":"头孢呋辛酯片","specification":"0.25g*12片","dosage":"0.25g","frequency":"每日两次","quantity":2,"unit":"盒"},{"medicineName":"氨溴索口服溶液","specification":"100ml:0.6g","dosage":"10ml","frequency":"每日三次","quantity":3,"unit":"瓶"},{"medicineName":"布地奈德福莫特罗粉吸入剂","specification":"160/4.5μg*60吸","dosage":"2吸","frequency":"每日早晚各一次","quantity":1,"unit":"支"}]',
 '慢性支气管炎急性发作',
 '1. 疗程7-10天，症状消失后巩固2-3天\n2. 头孢过敏者禁用，如有皮疹立即停药\n3. 吸入激素后漱口，防止口腔真菌感染\n4. 多饮温水，稀释痰液\n5. 避免烟雾、粉尘刺激\n6. 戒烟是关键，可咨询戒烟门诊',
 'COMPLETED', '2026-05-15', '2026-06-15');

SELECT '✅ 测试处方数据插入成功！共5张处方' AS result;

-- 4️⃣ 验证插入结果
SELECT '========== 数据验证 ==========' AS info;

SELECT 
  '病历统计' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN doctor_id = 1 THEN 1 ELSE 0 END) AS doctor1_records
FROM medical_record WHERE is_deleted = 0;

SELECT 
  '处方统计' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN doctor_id = 1 THEN 1 ELSE 0 END) AS doctor1_prescriptions
FROM prescription;

SELECT '=== 医生1的处方列表 ===' AS info;
SELECT 
  id,
  patient_id,
  patient_name,
  LEFT(diagnosis, 50) AS diagnosis_summary,
  status,
  created_at,
  valid_until,
  LENGTH(medications) AS medications_length
FROM prescription
WHERE doctor_id = 1
ORDER BY created_at DESC;

SELECT '🎉 所有测试数据准备完成！可以开始测试前端功能了！' AS success_message;
