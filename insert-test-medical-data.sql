-- =====================================================
-- 插入测试病历和处方数据
-- 为医生1的患者（user_id: 21-33）添加示例数据
-- 执行时间: 2026-05-11
-- =====================================================

-- 先查看现有数据避免冲突
SELECT '=== 现有病历数据 ===' AS info;
SELECT id, user_id, doctor_id, diagnosis, record_time FROM medical_record WHERE is_deleted = 0 ORDER BY id LIMIT 10;

SELECT '=== 现有处方数据 ===' AS info;
SELECT id, patient_id, doctor_id, diagnosis, status FROM prescription LIMIT 10;

-- =====================================================
-- 1. 插入测试病历数据
-- =====================================================

INSERT INTO medical_record (user_id, hospital_id, doctor_id, diagnosis, treatment, record_time, is_desensitized, is_deleted) VALUES
(21, 1, 1, '原发性高血压2级（中危）', '1. 氨氯地平片 5mg 每日一次口服\n2. 厄贝沙坦片 150mg 每日一次口服\n3. 低盐低脂饮食，每日食盐量<5g\n4. 适量运动，每周3-5次，每次30分钟\n5. 监测血压每日早晚各一次', '2026-03-15 09:30:00', 0, 0),

(22, 1, 1, '2型糖尿病', '1. 二甲双胍缓释片 500mg 每日三次餐前口服\n2. 阿卡波糖片 50mg 每日三次餐时嚼服\n3. 控制饮食，主食每餐不超过2两\n4. 餐后运动20-30分钟\n5. 监测空腹及餐后2小时血糖', '2026-04-02 14:15:00', 0, 0),

(23, 1, 1, '高血压病3级（极高危）伴冠心病', '1. 硝苯地平控释片 30mg 每日一次口服\n2. 阿托伐他汀钙片 20mg 每晚一次口服\n3. 阿司匹林肠溶片 100mg 每日一次口服\n4. 单硝酸异山梨酯片 20mg 每日两次口服\n5. 绝对卧床休息，心电监护\n6. 低盐低脂饮食，保持大便通畅', '2026-04-18 10:45:00', 0, 0),

(24, 1, 1, '脑梗死后遗症期', '1. 阿司匹林肠溶片 100mg 每日一次口服（抗血小板聚集）\n2. 阿托伐他汀钙片 20mg 每晚一次口服（稳定斑块）\n3. 甲钴胺片 0.5mg 每日三次口服（营养神经）\n4. 康复训练：肢体功能锻炼、语言训练\n5. 预防压疮、坠积性肺炎\n6. 定期复查头颅CT', '2026-05-01 16:20:00', 0, 0),

(25, 1, 1, '慢性支气管炎急性发作', '1. 头孢呋辛酯片 0.25g 每日两次口服（抗感染）\n2. 氨溴索口服液 10ml 每日三次口服（祛痰）\n3. 布地奈德福莫特罗粉吸入剂 160/4.5μg 每日两次吸入\n4. 多饮水，每日>2000ml\n5. 避免受凉感冒\n6. 戒烟限酒', '2026-05-08 11:00:00', 0, 0);

-- 为患者21追加第二次就诊记录
INSERT INTO medical_record (user_id, hospital_id, doctor_id, diagnosis, treatment, record_time, is_desensitized, is_deleted) VALUES
(21, 1, 1, '原发性高血压2级 - 复诊', '血压控制良好，继续当前治疗方案：\n1. 氨氯地平片 5mg qd\n2. 厄贝沙坦片 150mg qd\n3. 建议增加: 缬沙坦氢氯噻嗪片 替代单药治疗\n4. 1个月后复诊，监测肝肾功能、电解质', '2026-04-20 09:00:00', 0, 0);

-- =====================================================
-- 2. 插入测试处方数据
-- =====================================================

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

-- =====================================================
-- 3. 验证插入结果
-- =====================================================

SELECT '========== 插入完成后的数据统计 ==========' AS result;

SELECT 
  '病历数据' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN doctor_id = 1 THEN 1 ELSE 0 END) AS doctor1_records
FROM medical_record WHERE is_deleted = 0;

SELECT 
  '处方数据' AS type,
  COUNT(*) AS total,
  SUM(CASE WHEN doctor_id = 1 THEN 1 ELSE 0 END) AS doctor1_prescriptions
FROM prescription;

SELECT '=== 医生1的病历列表 ===' AS info;
SELECT 
  mr.id,
  mr.user_id AS patient_id,
  u.username AS patient_name,
  mr.diagnosis,
  mr.record_time,
  mr.treatment AS treatment_summary
FROM medical_record mr
LEFT JOIN user u ON mr.user_id = u.id
WHERE mr.doctor_id = 1 AND mr.is_deleted = 0
ORDER BY mr.record_time DESC;

SELECT '=== 医生1的处方列表 ===' AS info;
SELECT 
  p.id,
  p.patient_id,
  p.patient_name,
  p.diagnosis,
  p.status,
  p.created_at,
  LENGTH(p.medications) AS medications_length
FROM prescription p
WHERE p.doctor_id = 1
ORDER BY p.created_at DESC;

SELECT '✅ 测试数据插入成功！共插入7条病历 + 5条处方' AS success_message;
