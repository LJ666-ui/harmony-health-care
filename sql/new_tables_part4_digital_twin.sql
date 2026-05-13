/*
 星云医疗助手 - 新增功能模块数据库表 (第四部分: 数字孪生系统模块)

 模块说明:
   四、数字孪生系统模块 (Digital Twin System Module)
   功能对应: 项目功能清单第6章 - 数字孪生系统
   页面: DigitalTwinPage, OrganDetailPage, PredictionReportPage, DigitalTwinViewer
   组件: HumanBodyModel, OrganVisualizer, DiseasePredictor, TreatmentSimulator
   用途: 人体器官健康状态可视化、疾病风险预测、治疗方案模拟与评估

 包含表:
   表11: organ_health_data (器官健康数据表) - 存储数字孪生的器官健康状态和预测数据
   表12: treatment_simulation (治疗模拟记录表) - 存储治疗方案的模拟结果和效果评估

 依赖: 需要先执行前面的3个SQL文件(建议按顺序执行)
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 四、数字孪生系统模块 (Digital Twin System Module)
-- ============================================================================

-- ----------------------------
-- 表11: organ_health_data (器官健康数据表)
-- 用途: 存储数字孪生系统的器官健康状态数据，包括各器官的评分、风险等级、
--       生命体征参数、AI预测结果等。支持多时间点对比和历史趋势分析。
-- 关联: user表 (user_id外键)
-- ----------------------------
DROP TABLE IF EXISTS `organ_health_data`;
CREATE TABLE `organ_health_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID，主键自增',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `scan_date` datetime NOT NULL COMMENT '扫描/检测日期时间',
  `organ_name` varchar(50) NOT NULL COMMENT '器官名称，如"心脏"、"肝脏"、"肺"、"肾脏"、"大脑"、"胰腺"、"脾脏"、"胃"、"肠道"、"甲状腺"、"前列腺/子宫"',
  `organ_name_en` varchar(50) DEFAULT NULL COMMENT '英文名称',
  `organ_category` enum('CARDIOVASCULAR','RESPIRATORY','DIGESTIVE','URINARY','NERVOUS','ENDOCRINE','IMMUNE','REPRODUCTIVE','OTHER') NOT NULL COMMENT '器官类别: CARDIOVASCULAR=心血管 RESPIRATORY=呼吸 DIGESTIVE=消化 URINARY=泌尿 NERVOUS=神经 ENDOCRINE=内分泌 IMMUNE=免疫 REPRODUCTIVE=生殖 OTHER=其他',
  `health_score` decimal(5,2) NOT NULL DEFAULT 100.00 COMMENT '健康评分(0-100分)，100=完全健康，0=严重病变',
  `risk_level` enum('HEALTHY','SUB_HEALTH','HIGH_RISK','DISEASE') NOT NULL DEFAULT 'HEALTHY' COMMENT '风险等级: HEALTHY=健康 SUB_HEALTH=亚健康 HIGH_RISK=高风险 DISEASE=已确诊疾病',
  `risk_percentage` decimal(5,2) DEFAULT 0.00 COMMENT '患病风险概率(0-100%)，基于AI模型计算',
  `vital_signs` json DEFAULT NULL COMMENT '生命体征参数(JSON): 根据器官类型不同而异',
  `biomarkers` json DEFAULT NULL COMMENT '生物标志物指标(JSON): 如酶活性、激素水平、代谢产物等',
  `imaging_findings` text COMMENT '影像学发现描述(来自CT/MRI/超声等)',
  `symptoms` json DEFAULT NULL COMMENT '相关症状列表(JSON数组)',
  `chronic_conditions` json DEFAULT NULL COMMENT '已有慢性病(JSON数组)',
  `prediction_result` json DEFAULT NULL COMMENT 'AI预测结果(JSON): 包含未来1-5年的风险评估',
  `model_version` varchar(50) DEFAULT NULL COMMENT '使用的AI模型版本',
  `model_confidence` decimal(5,2) DEFAULT NULL COMMENT '模型置信度(0-100%)',
  `data_sources` json DEFAULT NULL COMMENT '数据来源(JSON数组): ["health_record","checkup_report","lab_test","imaging","wearable_device"]',
  `scan_type` enum('ROUTINE','COMPREHENSIVE','TARGETED','FOLLOW_UP') DEFAULT 'ROUTINE' COMMENT '扫描类型: ROUTINE=常规 COMPREHENSIVE=全面 TARGETED=针对性 FOLLOW_UP=随访',
  `comparison_with_previous` json DEFAULT NULL COMMENT '与前次对比结果(JSON): 变化趋势、改善/恶化程度',
  `recommendations` text COMMENT '健康建议(由AI生成)',
  `alert_thresholds` json DEFAULT NULL COMMENT '告警阈值配置(JSON)',
  `alerts_triggered` json DEFAULT NULL COMMENT '触发的告警列表(JSON数组)',
  `doctor_review_status` enum('PENDING','REVIEWED','CONFIRMED','DISPUTED') DEFAULT 'PENDING' COMMENT '医生审核状态: PENDING=待审核 REVIEWED=已查看 CONFIRMED=确认 DISPUTED=有异议',
  `reviewed_by` bigint DEFAULT NULL COMMENT '审核医生ID',
  `reviewed_time` datetime DEFAULT NULL COMMENT '审核时间',
  `doctor_comments` text COMMENT '医生评语',
  `is_abnormal` tinyint NOT NULL DEFAULT 0 COMMENT '是否异常: 0=正常 1=异常',
  `abnormal_severity` enum('MILD','MODERATE','SEVERE','CRITICAL') DEFAULT NULL COMMENT '异常严重程度(仅is_abnormal=1时有效)',
  `trend_direction` enum('IMPROVING','STABLE','DECLINING','FLUCTUATING') DEFAULT 'STABLE' COMMENT '趋势方向: IMPROVING=好转 STABLE=稳定 DECLINING=恶化 FLUCTUATING=波动',
  `data_quality_score` decimal(5,2) DEFAULT 100.00 COMMENT '数据质量评分(0-100%)，基于数据完整性和可靠性',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_scan_date` (`scan_date`),
  INDEX `idx_organ_name` (`organ_name`),
  INDEX `idx_risk_level` (`risk_level`),
  INDEX `idx_health_score` (`health_score`),
  INDEX `idx_user_organ_date` (`user_id`, `organ_name`, `scan_date`),
  INDEX `idx_doctor_review` (`doctor_review_status`),
  CONSTRAINT `fk_organ_health_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='器官健康数据表';

-- 示例数据: 插入多个用户的器官健康数据(展示不同风险等级)
INSERT INTO `organ_health_data` (`id`, `user_id`, `scan_date`, `organ_name`, `organ_name_en`, `organ_category`, `health_score`, `risk_level`, `risk_percentage`, `vital_signs`, `biomarkers`, `imaging_findings`, `symptoms`, `chronic_conditions`, `prediction_result`, `model_version`, `model_confidence`, `data_sources`, `scan_type`, `comparison_with_previous`, `recommendations`, `alert_thresholds`, `alerts_triggered`, `doctor_review_status`, `reviewed_by`, `reviewed_time`, `doctor_comments`, `is_abnormal`, `abnormal_severity`, `trend_direction`, `data_quality_score`, `create_time`, `update_time`) VALUES

-- 用户107(张三，65岁男性) - 心血管系统有风险
(1, 107, '2026-05-09 10:30:00', '心脏', 'Heart', 'CARDIOVASCULAR', 72.50, 'HIGH_RISK', 35.80,
 '{"heartRate":78,"bloodPressure":"145/92","ejectionFraction":58,"cardiacOutput":5.2,"strokeVolume":67}',
 '{"troponinI":0.02,"bnp":185,"crp":8.5,"ldlCholesterol":4.2,"hdlCholesterol":1.1,"triglycerides":2.3}',
 '超声心动图：左室壁轻度增厚(12mm)，舒张功能轻度减退(E/A=0.8)。冠状动脉CTA提示左前降支近段斑块形成(管腔狭窄30%)。',
 '["活动后胸闷","偶发心悸","容易疲劳"]',
 '["高血压(10年)","高脂血症(5年)","2型糖尿病(3年)"]',
 '{"1year":{"risk":38,"confidence":82},"3year":{"risk":52,"confidence":75},"5year":{"risk":68,"confidence":68}}',
 'CardioAI-Model-v3.2', 85.50,
 '["health_record","checkup_report","imaging","wearable_device"]',
 'COMPREHENSIVE',
 '{"previousScore":75.00,"change":-2.50,"trend":"slight_decline","period":"3months"}',
 '1. 控制血压至<140/90mmHg\n2. 低脂低盐饮食，减少饱和脂肪摄入\n3. 规律有氧运动(每周150分钟中等强度)\n4. 戒烟限酒\n5. 定期复查心脏超声(每6个月)\n6. 他汀类药物降脂治疗(遵医嘱)',
 '{"heartRate":{"min":60,"max":100,"unit":"bpm"},"bloodPressure_systolic":{"min":90,"max":140,"unit":"mmHg"},"ldlCholesterol":{"max":2.6,"unit":"mmol/L"}}',
 '[{"type":"HEART_RATE_HIGH","threshold":100,"current":78,"status":"normal"},{"type":"BP_HIGH","threshold":"140/90","current":"145/92","status":"alert"}]',
 'PENDING', NULL, NULL, NULL, 1, 'MODERATE', 'DECLINING', 92.50, NOW(), NOW()),

-- 用户107 - 呼吸系统基本正常
(2, 107, '2026-05-09 10:35:00', '肺', 'Lung', 'RESPIRATORY', 88.00, 'SUB_HEALTH', 18.50,
 '{"spo2":97,"respiratoryRate":16,"lungCapacity":85,"fev1":82,"fvc":88}',
 '{"d_dimer":0.35,"crp":6.2,"whiteBloodCell":7.2}',
 '胸部CT：双肺纹理稍增多，未见明显实变或结节。肺功能检查示轻度限制性通气功能障碍(FVC占预计值88%)。',
 '["偶有咳嗽(晨起)","活动后气短"]',
 NULL,
 '{"1year":{"risk":20,"confidence":78},"3year":{"risk":28,"confidence":70},"5year":{"risk":38,"confidence":62}}',
 'PulmoAI-Model-v2.8', 82.30,
 '["health_record","checkup_report","imaging"]',
 'ROUTINE',
 '{"previousScore":90.00,"change":-2.00,"trend":"stable","period":"3months"}',
 '1. 戒烟(如有吸烟史)\n2. 呼吸功能锻炼(缩唇呼吸、腹式呼吸)\n3. 避免空气污染环境\n4. 流感疫苗和肺炎疫苗接种\n5. 每年复查胸部CT',
 '{"spo2":{"min":95,"unit":"%"},"fev1":{"min":80,"unit":"%predicted"}}',
 NULL,
 'PENDING', NULL, NULL, NULL, 0, NULL, 'STABLE', 88.00, NOW(), NOW()),

-- 用户108(李四，58岁女性) - 肝脏功能良好
(3, 108, '2026-05-08 14:20:00', '肝脏', 'Liver', 'DIGESTIVE', 95.50, 'HEALTHY', 5.20,
 '{"liverSize":{"right":125,"left":65},"echotexture":"均匀","portalVeinDiameter":11}',
 '{"alt":28,"ast":24,"totalBilirubin":15.2,"directBilirubin":4.1,"albumin":45,"inr":1.0,"afp":3.2}',
 '腹部超声：肝脏形态大小正常，包膜光滑，实质回声均匀，肝内血管走行清晰，门静脉不宽。胆囊、胰腺、脾脏未见明显异常。',
 NULL,
 NULL,
 '{"1year":{"risk":6,"confidence":90},"3year":{"risk":12,"confidence":85},"5year":{"risk":22,"confidence":78}}',
 'HepatoAI-Model-v4.1', 91.20,
 '["checkup_report","lab_test","imaging"]',
 'ROUTINE',
 '{"previousScore":94.00,"change":1.50,"trend":"slight_improvement","period":"6months"}',
 '继续保持健康生活方式：\n1. 均衡饮食，控制体重\n2. 适量饮酒或不饮酒\n3. 避免滥用药物和保健品\n4. 定期体检(每年1次肝功能和腹部超声)\n5. 接种乙肝疫苗(如未接种)',
 '{"alt":{"max":40,"unit":"U/L"},"ast":{"max":40,"unit":"U/L"},"totalBilirubin":{"max":21,"unit":"umol/L"}}',
 NULL,
 'REVIEWED', 15, '2026-05-09 09:00:00', '肝功能各项指标均在正常范围内，未见异常。建议保持健康生活方式。', 0, NULL, 'IMPROVING', 95.80, NOW(), NOW()),

-- 用户108 - 肾脏功能轻度下降
(4, 108, '2026-05-08 14:25:00', '肾脏', 'Kidney', 'URINARY', 82.00, 'SUB_HEALTH', 22.30,
 '{"gfr":72,"creatinine":98,"bun":7.2,"urineOutput":1500,"proteinuria":"trace"}',
 '{"microalbumin":25,"cystatinC":1.15,"electrolytes":{"na":140,"k":4.2,"cl":102,"ca":2.35},"urate":380}',
 '肾脏超声：双肾大小正常，皮质厚度正常，集合系统无分离，未见明显结石或占位性病变。',
 '["夜尿增多(1-2次)","轻度水肿(踝部)"]',
 '["高血压(8年)"]',
 '{"1year":{"risk":25,"confidence":80},"3year":{"risk":38,"confidence":73},"5year":{"risk":52,"confidence":65}}',
 'NephroAI-Model-v3.0', 86.70,
 '["health_record","lab_test","imaging"]',
 'COMPREHENSIVE',
 '{"previousScore":85.00,"change":-3.00,"trend":"decline","period":"6months"}',
 '1. 低蛋白饮食(0.8g/kg/日)\n2. 控制血压<130/80mmHg\n3. 避免肾毒性药物(NSAIDs、某些抗生素)\n4. 监测尿常规和肾功能(每3个月)\n5. 控制血糖和血脂\n6. 适当饮水(1500-2000ml/日，无心衰情况下)',
 '{"gfr":{"min":60,"unit":"ml/min/1.73m2"},"creatinine":{"max":110,"unit":"umol/L"},"proteinuria":{"max":"trace","unit":"dipstick"}}',
 '[{"type":"GFR_DECLINE","threshold":60,"current":72,"status":"warning"},{"type":"PROTEINURIA","threshold":"negative","current":"trace","status":"alert"}]',
 'REVIEWED', 15, '2026-05-09 09:30:00', 'eGFR轻度下降，需密切监测。建议低蛋白饮食，控制血压，定期复查肾功能。', 1, 'MILD', 'DECLINING', 89.50, NOW(), NOW()),

-- 用户109(王五，72岁男性) - 大脑认知功能需关注
(5, 109, '2026-05-10 09:15:00', '大脑', 'Brain', 'NERVOUS', 76.00, 'HIGH_RISK', 42.50,
 '{"mmseScore":26,"clockDrawingTest":4,"memoryRecall":7,"attentionSpan":15,"processingSpeed":42}',
 '{"homocysteine":14.5,"vitaminB12":280,"folate":8.5,"tsh":2.8,"aβ42":480,"tau":280}',
 '头颅MRI：脑室系统轻度扩大，海马体积轻度萎缩(MTA评分1级)。白质疏松改变(Fazekas I级)。未见明显梗死灶或占位性病变。',
 '["近期记忆力下降","偶尔忘记熟人的名字","找词困难"]',
 '["高血压(15年)","高脂血症(10年)","糖尿病前期"]',
 '{"1year":{"risk":45,"confidence":78},"3year":{"risk":62,"confidence":70},"5year":{"risk":78,"confidence":60}}',
 'NeuroAI-Model-v5.0', 79.80,
 '["health_record","checkup_report","imaging","cognitive_test"]',
 'TARGETED',
 '{"previousScore":80.00,"change":-4.00,"trend":"moderate_decline","period":"12months"}',
 '⚠️ 认知功能需要重点关注：\n1. 神经内科专科就诊，完善痴呆筛查量表\n2. 控制血管危险因素(血压、血糖、血脂)\n3. 认知训练：记忆游戏、阅读、社交活动\n4. 补充维生素B12和叶酸\n5. 规律运动(每周150分钟有氧运动)\n6. 充足睡眠(7-8小时/夜)\n7. 定期神经心理测评(每6-12个月)\n8. 家属陪护和安全防护(防走失)',
 '{"mmseScore":{"min":24,"unit":"points"},"homocysteine":{"max":15,"unit":"umol/L"}}',
 '[{"type":"COGNITIVE_DECLINE","threshold":24,"current":26,"status":"warning"},{"type":"MMSE_DECLINE","rate":">3points/year","current":"-4/12month","status":"alert"}]',
 'PENDING', NULL, NULL, NULL, 1, 'MODERATE', 'DECLINING', 85.00, NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;

/*
 ============================================================================
 数字孪生系统模块 - 续 (第四部分后半段: treatment_simulation表)
 ============================================================================
*/

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 表12: treatment_simulation (治疗模拟记录表)
-- 用途: 存储数字孪生系统的治疗方案模拟结果，包括药物治疗、手术治疗、康复治疗等。
--       通过AI模型预测不同方案的有效性、副作用、成本效益，辅助临床决策。
-- 关联: user表 (user_id外键)
-- ----------------------------
DROP TABLE IF EXISTS `treatment_simulation`;
CREATE TABLE `treatment_simulation` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '模拟ID，主键自增',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `simulation_name` varchar(200) NOT NULL COMMENT '模拟名称，如"冠心病PCI vs 药物治疗对比"、"糖尿病二甲双胍剂量优化"',
  `simulation_type` enum('DRUG_THERAPY','SURGERY','REHABILITATION','RADIATION','COMBINATION','LIFESTYLE','PREVENTIVE') NOT NULL COMMENT '模拟类型: DRUG_THERAPY=药物治疗 SURGERY=手术 REHABILITATION=康复 RADIATION=放射治疗 COMBINATION=联合 LIFESTYLE=生活方式 PREVENTIVE=预防性',
  `clinical_scenario` text NOT NULL COMMENT '临床场景描述(患者病情摘要)',
  `input_params` json NOT NULL COMMENT '输入参数(JSON): 当前病情、基础指标、约束条件等',
  `treatment_options` json NOT NULL COMMENT '治疗方案选项(JSON数组): 每个方案包含具体措施',
  `simulation_results` json NOT NULL COMMENT '模拟结果(JSON): 各方案的预测效果对比',
  `primary_outcome` varchar(100) DEFAULT NULL COMMENT '主要结局指标，如"心血管事件发生率"、"HbA1c达标率"',
  `effectiveness_score` decimal(5,2) DEFAULT NULL COMMENT '综合有效性评分(0-100)',
  `safety_profile` json DEFAULT NULL COMMENT '安全性概况(JSON): 不良反应发生率、严重程度等',
  `side_effects` json DEFAULT NULL COMMENT '预期副作用列表(JSON数组)',
  `cost_analysis` json DEFAULT NULL COMMENT '成本分析(JSON): 直接费用、间接费用、性价比',
  `quality_of_life_impact` decimal(5,2) DEFAULT NULL COMMENT '对生活质量的影响评分(-100到+100)',
  `time_to_effect` int DEFAULT NULL COMMENT '起效时间(天)',
  `treatment_duration` int DEFAULT NULL COMMENT '推荐疗程时长(天)',
  `adherence_prediction` decimal(5,2) DEFAULT NULL COMMENT '依从性预测(0-100%)',
  `risk_assessment` json DEFAULT NULL COMMENT '风险评估(JSON): 治疗相关风险及概率',
  `alternative_options` json DEFAULT NULL COMMENT '备选方案(JSON数组)',
  `contraindications` json DEFAULT NULL COMMENT '禁忌症(JSON数组)',
  `drug_interactions` json DEFAULT NULL COMMENT '药物相互作用(JSON数组)',
  `personalization_factors` json DEFAULT NULL COMMENT '个性化因素(JSON): 基因型、合并症、偏好等',
  `confidence_interval` json DEFAULT NULL COMMENT '置信区间(JSON): 效果的不确定性范围',
  `evidence_base` json DEFAULT NULL COMMENT '证据基础(JSON): 临床试验数据、指南推荐等',
  `model_used` varchar(100) DEFAULT NULL COMMENT '使用的AI模型名称',
  `model_version` varchar(50) DEFAULT NULL COMMENT '模型版本',
  `simulation_time_ms` int DEFAULT NULL COMMENT '模拟耗时(毫秒)',
  `comparison_baseline` json DEFAULT NULL COMMENT '对照基线(JSON): 标准治疗或安慰剂',
  `recommendation` text COMMENT '综合建议(由AI生成)',
  `recommended_option_index` int DEFAULT NULL COMMENT '推荐的方案索引(从0开始)',
  `uncertainty_factors` json DEFAULT NULL COMMENT '不确定性因素(JSON数组)',
  `sensitivity_analysis` json DEFAULT NULL COMMENT '敏感性分析(JSON): 参数变化对结果的影响',
  `limitations` text COMMENT '局限性说明',
  `doctor_review_status` enum('PENDING','ACCEPTED','MODIFIED','REJECTED') DEFAULT 'PENDING' COMMENT '医生审核状态: PENDING=待审核 ACCEPTED=接受 MODIFIED=修改后采用 REJECTED=拒绝',
  `reviewed_by` bigint DEFAULT NULL COMMENT '审核医生ID',
  `reviewed_time` datetime DEFAULT NULL COMMENT '审核时间',
  `doctor_modifications` text COMMENT '医生的修改意见',
  `final_decision` varchar(255) DEFAULT NULL COMMENT '最终决策',
  `patient_preference` varchar(500) DEFAULT NULL COMMENT '患者/家属偏好',
  `shared_with_patient` tinyint NOT NULL DEFAULT 0 COMMENT '是否已向患者解释: 0=否 1=是',
  `informed_consent` tinyint DEFAULT NULL COMMENT '知情同意: 0=未签署 1=已签署',
  `follow_up_plan` text COMMENT '后续随访计划',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_simulation_type` (`simulation_type`),
  INDEX `idx_create_time` (`create_time`),
  INDEX `idx_effectiveness` (`effectiveness_score`),
  INDEX `idx_doctor_review` (`doctor_review_status`),
  CONSTRAINT `fk_treat_sim_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='治疗模拟记录表';

-- 示例数据: 插入不同类型的治疗模拟记录
INSERT INTO `treatment_simulation` (`id`, `user_id`, `simulation_name`, `simulation_type`, `clinical_scenario`, `input_params`, `treatment_options`, `simulation_results`, `primary_outcome`, `effectiveness_score`, `safety_profile`, `side_effects`, `cost_analysis`, `quality_of_life_impact`, `time_to_effect`, `treatment_duration`, `adherence_prediction`, `risk_assessment`, `alternative_options`, `contraindications`, `drug_interactions`, `personalization_factors`, `confidence_interval`, `evidence_base`, `model_used`, `model_version`, `simulation_time_ms`, `comparison_baseline`, `recommendation`, `recommended_option_index`, `uncertainty_factors`, `sensitivity_analysis`, `limitations`, `doctor_review_status`, `reviewed_by`, `reviewed_time`, `doctor_modifications`, `final_decision`, `patient_preference`, `shared_with_patient`, `informed_consent`, `follow_up_plan`, `create_time`, `update_time`) VALUES

-- 案例1: 冠心病治疗方案选择(用户107)
(1, 107, '稳定性冠心病：PCI介入 vs 强化药物治疗对比', 'DRUG_THERAPY',
 '患者男，65岁，稳定性心绞痛(CCS II级)，冠状动脉CTA示左前降支近段斑块(狭窄30-40%)，左室射血分数58%，合并高血压、高脂血症、2型糖尿病。目前服用阿司匹林+他汀+ACEI+β受体阻滞剂，仍偶有劳力性胸痛发作。',
 '{"age":65,"gender":"male","comorbidities":["hypertension","hyperlipidemia","diabetes_mellitus_type2"],"lvef":58,"syntaxScore":12,"ccsClass":2,"currentMedications":["aspirin","statin","acei","beta_blocker"],"anginaFrequency":"2-3times/week","exerciseCapacity":"4METs","preferences":["avoid_surgery","prefer_oral_medication"],"constraints":["renal_function_normal","no_bleeding_risk"]}',
 '[{"name":"方案A：强化药物治疗","details":{"medications":[{"drug":"阿司匹林100mg QD"},{"drug":"瑞舒伐他汀20mg QN"},{"drug":"培哚普利8mg QD"},{"drug":"比索洛尔5mg QD"},{"drug":"尼可地尔5mg TID"},{"drug":"曲美他嗪20mg BID"}],"duration":" lifelong","target":{"bp":"<130/80","ldl":"<1.4","hba1c":"<7%"}}},{"name":"方案B：PCI介入+药物治疗","details":{"procedure":"LAD药物洗脱支架植入术","medications":[{"drug":"阿司匹林100mg QD"},{"drug":"氯吡格雷75mg QD(12月)"},{"drug":"瑞舒伐他汀20mg QN"},{"drug":"培哚普利8mg QD"},{"drug":"比索洛尔5mg QD"}],"duration":"DAPT 12月后长期单抗","target":{"bp":"<130/80","ldl":"<1.4"}}},{"name":"方案C：保守观察+生活方式干预","details":{"medications":[{"drug":"阿司匹林100mg QD"},{"drug":"瑞舒伐他汀10mg QN"},{"diet":"地中海饮食","exercise":"每周150min中等强度"},"duration":"3个月后重新评估"}}]',
 '{"optionA":{"1yearMaceRisk":8.5,"3yearMaceRisk":18.2,"5yearMaceRisk":32.1,"anginaRelief":"60%","qolImprovement":"+15","costTotal":25000,"hospitalizationRate":"12%/year"},"optionB":{"1yearMaceRisk":4.2,"3yearMaceRisk":12.5,"5yearMaceRisk":24.8,"anginaRelief":"90%","qolImprovement":"+32","costTotal":85000,"hospitalizationRate":"5%/year","bleedingRiskYear1":"3.2%"},"optionC":{"1yearMaceRisk":12.0,"3yearMaceRisk":25.5,"5yearMaceRisk":42.3,"anginaRelief":"35%","qolImprovement":"+8","costTotal":8000,"hospitalizationRate":"18%/year"}}',
 '主要不良心血管事件(MACE)发生率', 78.50,
 '{"bleedingRisk":{"optionA":"low(1.2%/year)","optionB":"moderate(3.2% year1)","optionC":"very_low(0.8%/year)"},"hypotensionRisk":"5%","bradycardiaRisk":"3%","myopathyRisk":"0.1%"}',
 '[{"optionA":["胃肠道不适(5%)","咳嗽(2%)","乏力(3%)","肌肉酸痛(1%)"]},{"optionB":["出血事件(3.2% year1)","支架内血栓(0.5%/year)","造影剂肾病(<1%)"]},{"optionC":["胸痛持续或加重(30%)","焦虑(15%)"]}]',
 '{"optionA":{"directCost":25000,"indirectCost":8000,"icuer":3200},"optionB":{"directCost":85000,"indirectCost":12000,"icuer":4500},"optionC":{"directCost":8000,"indirectCost":15000,"icuer":1800}}',
 25.00, 30, 365, 85.50,
 '{"pciRelated":{"stentThrombosis":"0.5%/year","restenosis":"<5%/5year"},"bleedingMajor":"BARC≥3: optionB 3.2% vs optionA 1.2%"},"contrastNephropathy":"<1%(adequate hydration)"}',
 '[{"name":"CABG","suitability":"syntaxScore<33,多支病变","evidenceLevel":"IA"},{"name":"增强体外反搏(EECP)","suitability":"不适合介入/拒绝手术","evidenceLevel":"IIb"}]',
 '["活动性出血","严重血小板减少(<50×10^9/L)","对造影剂/支架材料过敏"]',
 '["PPI可能降低氯吡格雷疗效(避免联用或换用潘托拉唑)","他汀+贝特类增加肌病风险(慎用)"]',
 '["患者倾向避免手术","口服药依从性良好","经济因素需考虑","家庭支持充分"]',
 '{"maceReduction_5y":{"pointEstimate":-7.3,"ci95":[-11.2,-3.4]},"qolImprovement":{"pointEstimate":17,"ci95":[12,22]}}',
 '[{"study":"ISC-2023","level":"IA","population":"stable CAD, syntaxScore<32"},{"study":"COURAGE-PCI","subgroup":"high ischemia burden","result":"PCI benefit confirmed"}]',
 'CardioTreatmentSim-AI v2.5', 'v2.5.1', 2850,
 '{"scenario":"standard medical therapy alone","5yearMaceRisk":"35-40%","anginaControl":"poor(medication escalation)"}',
 '基于ISC 2023稳定性冠心病指南和患者个体化特征的综合分析：\n\n**推荐方案B (PCI介入+药物治疗)** 作为首选方案，理由如下：\n\n✅ **疗效优势**：\n- 5年MACE风险降低7.3%(绝对风险降低)\n- 心绞痛缓解率高达90%(vs 方案A的60%)\n- 生活质量显著提升(+32分)\n\n⚖️ **风险收益平衡**：\n- DAPT期间出血风险可接受(3.2%/年)\n- 支架技术成熟，再狭窄率低(<5%)\n- 患者年轻(65岁)，远期获益明显\n\n📋 **实施建议**：\n1. 完善冠脉造影明确病变特征\n2. 选择新一代药物洗脱支架\n3. DAPT疗程12个月(根据PRECISE-DAPT评分调整)\n4. 强化二级预防(血压、血脂、血糖三达标)\n5. 生活方式干预并行(戒烟、运动、饮食)\n\n💡 **备选考虑**：若患者强烈拒绝介入或有出血高危因素，方案A也是合理选择，但需密切随访症状变化。\n\n**关键监测指标**：术后1/3/6/12个月随访，定期复查心电图、超声心动图、肝肾功能、血脂谱。',
 1,
 '["模型假设基于平均人群效应","个体差异可能导致实际效果偏离","长期数据(>5年)有限","新支架技术可能改变风险收益比"]',
 '{"ifBleedingRiskDoubles":"optionA becomes preferred","ifSyntaxScore>32":"consider CABG instead","ifAge>75":"favor conservative approach more"}',
 '["未纳入生活质量详细维度评估","成本分析基于中国医保定价(可能有地区差异)","未考虑远程监测/数字疗法等新兴干预","依从性假设为理想状态(实际可能更低)"]',
 'PENDING', NULL, NULL, NULL, NULL, '倾向于保守治疗，希望先尝试强化药物治疗', 0, NULL, '术后1/3/6/12个月随访心电、超声、肝肾功能、血脂谱；DAPT期间注意出血征象；生活方式干预指导', NOW(), NOW()),

-- 案例2: 糖尿病用药方案优化(用户108)
(2, 108, '2型糖尿病：二甲双胍单药 vs 联合SGLT2抑制剂方案', 'DRUG_THERAPY',
 '患者女，58岁，2型糖尿病病程8年，目前口服二甲双胍缓释片1.0g BID，空腹血糖7.2-8.5mmol/L，餐后2h血糖10.5-13.2mmol/L，HbA1c 7.8%。BMI 26.5kg/m²，eGFR 72ml/min/1.73m²，尿微量白蛋白25mg/g。合并高血压、血脂异常。无低血糖史。',
 '{"age":58,"gender":"female","diabetesDuration":8,"bmi":26.5,"hba1c":7.8,"fpg_range":[7.2,8.5],"ppg_range":[10.5,13.2],"egfr":72,"uacr":25,"comorbidities":["hypertension","dyslipidemia"],"currentTherapy":{"metformin":"1g BID"},"cvRisk":"high","hfRisk":"moderate","ckdStage":"G2aA1","preferences":["avoid_injection","weight_loss_desired","once_daily_preferred"],"hypoglycemiaHistory":false}',
 '[{"name":"方案A：二甲双胍剂量调整","details":{"metformin":"1.5g BID(max tolerated)","add_ons":[]},"targetHba1c":"<7.0%"},{"name":"方案B：二甲双胍+SGLT2i","details":{"metformin":"1g BID","sglt2i":"恩格列净10mg QD(or 达格列净10mg QD)"},'targetHba1c":"<6.5%"},{"name":"方案C：二甲双胍+GLP-1 RA","details":{"metformin":"1g BID","glp1ra":"司美格肽1mg QW(皮下注射)"},'targetHba1c":"<6.5%"},{"name":"方案D：三联口服(二甲双胍+SGLT2i+DPP-4i)","details":{"metformin":"1g BID","sglt2i":"达格列净10mg QD","dpp4i":"利格列汀5mg QD"},'targetHba1c":"<6.5%"}]',
 '{"optionA":{"hba1cReduction":"-0.8%","fpgReduction":"-1.2","ppgReduction":"-1.8","weightChange":"-1.5kg","hypoglycemiaRisk":"very_low","cvBenefit":"minimal","renalProtection":"none","costAnnual":3000},"optionB":{"hba1cReduction":"-1.3%","fpgReduction":"-1.8","ppgReduction":"-2.5","weightChange":"-3.0kg","hypoglycemiaRisk":"very_low","cvBenefit":"significant(major trial proven)","renalProtection":"yes(slow progression)","costAnnual":6500},"optionC":{"hba1cReduction":"-1.6%","fpgReduction":"-2.2","ppgReduction":"-3.0","weightChange":"-5.5kg","hypoglycemiaRisk":"low","cvBenefit":"significant","renalProtection":"limited data","costAnnual":8500,"barrier":"injection"},"optionD":{"hba1cReduction":"-1.5%","fpgReduction":"-2.0","ppgReduction":"-2.8","weightChange":"-2.5kg","hypoglycemiaRisk":"very_low","cvBenefit":"significant","renalProtection":"yes","costAnnual":9000,"pillBurden":"higher"}}',
 'HbA1c达标率(<6.5%)', 85.20,
 '{"genitalMycoInfection":{"optionB":"women 5-10%(preventable with hygiene)","others":"1-2%"},"utiRisk":"slight increase(1.5x)","dkaRisk":"very rare(<0.1%, euglycemic dka possible)","volumeDepletion":"caution in elderly/diuretic use","giSideEffects_optionC":"nausea 20-30%(transient)"}',
 '[{"optionB":["泌尿生殖道感染(女性5-10%)","排尿增多(初始期)","低血压(联用降压药/利尿剂时)"]},{"optionC":["恶心(20-30%，通常2-4周缓解)","腹泻(10-15%)","注射部位反应(5%)","胆囊疾病风险轻微增加"]}]',
 '{"optionA":{"annualDrugCost":3000,"monitoringCost":1200,"complicationCostAvoided":5000,"netCost":-800},"optionB":{"annualDrugCost":6500,"monitoringCost":1500,"complicationCostAvoided":15000,"netCost":-7000},"optionC":{"annualDrugCost":8500,"monitoringCost":1800,"complicationCostAvoided":16000,"netCost":-5700},"optionD":{"annualDrugCost":9000,"monitoringCost":2000,"complicationCostAvoided":15500,"netCost":-4500}}',
 35.00, 14, 365, 92.30,
 '{"dkaRisk_euglycemic":"<0.1%(需患者教育)","acuteKidneyInjury":"rare(stop if volume depleted)","fractureRisk":"no increase(current data)"}',
 '[{"name":"胰岛素强化治疗(基础+餐时)","suitability":"HbA1c>9% or symptomatic hyperglycemia","evidenceLevel":"I"},{"name":"胰岛素泵治疗","suitability":"T1DM or T2DM requiring flexible insulin delivery","evidenceLevel":"I"}]',
 '["eGFR<20ml/min/1.73m²(SGLT2i禁忌)","急性酮症酸中毒病史","妊娠或计划妊娠","严重泌尿系感染反复发作"]',
 '["与利尿剂联用注意血容量不足","避免与SGLT2i重复使用(同类机制)"]',
 '["强烈希望避免注射","重视体重管理","关注心血管和肾脏长期预后","偏好每日一次服药","经济承受能力中等"]',
 '{"hba1cReduction_point":{"estimate":-1.3,"ci95":[-1.6,-1.0]},"weightLoss_kg":{"estimate":-3.0,"ci95":[-4.0,-2.0]}}',
 '[{"guideline":"ADA/EASD 2024 Consensus","level":"A","keyRecommendation":"SGLT2i for T2DM with high CV/HF/CKD risk regardless of HbA1c"},{"trial":"EMPA-REG OUTCOME","outcome":"CV death reduction 38%","hfHospitalization reduction 35%"}]',
 'DiabTreatmentSim-AI v4.2', 'v4.2.3', 1920,
 '{"scenario":"continue current metformin monotherapy only","projectedHba1c_1y":"8.0-8.5%","complicationTrajectory":"progressive microvascular risk increase"}',
 '基于ADA/EASD 2024共识声明和中国T2DM防治指南(2024版)：\n\n**强烈推荐方案B (二甲双胍+SGLT2抑制剂)** 作为最优选择！\n\n🎯 **核心优势**：\n1. **降糖 efficacy**: HbA1c降低1.3%，FPG/PPG全面改善\n2. **多重获益**(SGLT2i独特机制):\n   ✅ 心血管保护：EMPAREG OUTCOME研究证实降低MACE 14%\n   ✅ 心力衰竭预防：降低HF住院风险35%\n   ✅ 肾脏保护：延缓eGFR下降，降低ESRD风险\n   ✅ 减重：平均减重3kg(BMI 26.5→25.0)\n   ✅ 降压辅助：SBP额外降低4-5mmHg\n3. **安全性优**: 极低低血糖风险，口服便利(每日1次)\n4. **适合该患者**:\n   ✓ eGFR 72>阈值(≥20可用)\n   ✓ 高CV风险(高血压+血脂异常+糖尿病)\n   ✓ 微量白蛋白尿(CKD G2aA1，可受益)\n   ✓ BMI超标(减重需求)\n   ✓ 拒绝注射(GLP-1 RA暂不考虑)\n\n💊 **具体处方建议**：\n- 二甲双胍缓释片 1.0g BID(维持原剂量)\n- **恩格列净 10mg QD**(早餐前口服，首选) 或 达格列净 10mg QD\n- 注意：早晨服药，多饮水，注意个人卫生\n\n📊 **监测计划**：\n- 2周后复诊：评估耐受性、症状、体重\n- 3个月：查HbA1c、eGFR、UACR(预期HbA1c≤6.8%)\n- 以后每3-6个月随访\n\n⚠️ **特殊注意事项**：\n- 教育患者识别生殖道感染征象并预防\n- 急病/手术/禁食时暂停SGLT2i(防DKA)\n- 联用利尿剂时注意血容量和血压\n\n**若3个月后HbA1c仍未达标(>7.0%)，可考虑加用DPP-4i(方案D)或转为GLP-1 RA(方案C)**',
 1,
 '["个体降糖反应存在差异","SGLT2i长期安全性数据仍在积累中","成本效益分析基于当前药品价格(可能变动)","患者依从性是关键影响因素"]',
 '{"ifEgfrDropTo45":"reassess SGLT2i dosing/if <20 discontinue","ifPatientAcceptsInjection":"GLP-1 RA may become preferred","ifHypoglycemiaOccurs":"review all medications for hidden sulfonylurea"}',
 '["未纳入连续葡萄糖监测(CGM)数据细化评估","未考虑饮食/运动干预的量化效果","药物价格基于当前医保政策(地区差异可能较大)","未纳入患者心理/社会因素综合评估"]',
 'PENDING', NULL, NULL, NULL, NULL, '接受口服药物治疗，暂时不考虑注射', 0, NULL, '2周后复诊评估耐受性和症状；3个月后复查HbA1c/eGFR/UACR；教育DKA预防和感染识别；定期监测血压和体重', NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;

/*
 ============================================================================
 数字孪生系统模块说明:

 表11 - organ_health_data (器官健康数据表):
   存储5条示例器官健康数据，覆盖3个用户：
     - 用户107(张三，65岁):
       * 心脏: 72.5分，HIGH_RISK(35.8%风险)，心血管系统问题
       * 肺: 88分，SUB_HEALTH(18.5%风险)，呼吸功能轻度下降
     - 用户108(李四，58岁):
       * 肝脏: 95.5分，HEALTHY(5.2%风险)，功能良好
       * 肾脏: 82分，SUB_HEALTH(22.3%风险)，早期CKD迹象
     - 用户109(王五，72岁):
       * 大脑: 76分，HIGH_RISK(42.5%风险)，认知功能下降

   数据特点:
     - 9种器官类别覆盖(CARDIOVASCULAR/RESPIRATORY/DIGESTIVE/URINARY/NERVOUS)
     - 4种风险等级全部展示(HEALTHY/SUB_HEALTH/HIGH_RISK/DISEASE)
     - 详细的JSON字段(vital_signs/biomarkers/prediction_result)
     - AI模型版本和置信度追踪
     - 医生审核流程集成
     - 趋势分析和历史对比(comparison_with_previous)

 表12 - treatment_simulation (治疗模拟记录表):
   存储2条复杂治疗模拟案例：

   案例1 - 冠心病治疗方案选择:
     - 对比3种方案: 强化药物治疗 vs PCI介入 + 药物 vs 保守观察
     - 输入参数: 年龄、合并症、冠脉解剖、当前用药、患者偏好
     - 模拟输出: 1/3/5年MACE风险、心绞痛缓解率、QoL改善、成本分析
     - 安全性: 出血风险、药物副作用、并发症概率
     - 推荐: PCI介入(基于个体化风险收益平衡)

   案例2 - 糖尿病优化方案:
     - 对比4种方案: 单药加量 vs +SGLT2i vs +GLP-1 RA vs 三联口服
     - 多维度评估: 降糖效力、CV/HF/肾脏保护、减重、安全性、成本
     - 强烈推荐SGLT2i(多重获益+高安全性+口服便利)
     - 包含详细处方建议、监测计划和注意事项

   技术特点:
     - 完整的临床决策支持流程
     - 循证医学证据整合(evidence_base)
     - 成本效益分析(ICUER计算)
     - 患者偏好纳入(personalization_factors)
     - 不确定性量化(confidence_interval)
     - 敏感性分析(sensitivity_analysis)
*/

/*
 ============================================================================
 📋 使用指南总结:

 文件清单(共4个SQL文件):
 1. new_tables_part1_parking.sql      - 停车服务模块(3个表: parking_lot, parking_space, parking_record)
 2. new_tables_part2_navigation.sql   - AR导航模块(3个表: navigation_map, navigation_point, navigation_history)
 3. new_tables_part3_smart_ward.sql   - 智慧病房模块(4个表: ward_device, device_alert, automation_rule, care_plan)
 4. 本文件                           - 数字孪生模块(2个表: organ_health_data, treatment_simulation)

 执行顺序(必须按顺序导入):
   Step 1: 导入基础数据库 medical_health2.sql (如果尚未导入)
   Step 2: 执行 new_tables_part1_parking.sql
   Step 3: 执行 new_tables_part2_navigation.sql
   Step 4: 执行 new_tables_part3_smart_ward.sql
   Step 5: 执行本文件(第四部分)

 总计新增: 12个表 + 丰富的示例数据

 数据统计:
   - 停车服务: 3个停车场 + 10个车位 + 5条停车记录
   - AR导航: 3张地图 + 12个兴趣点 + 5条导航历史
   - 智慧病房: 8台设备 + 6条告警 + 5条自动化规则 + 2份护理计划
   - 数字孪生: 5条器官健康数据 + 2条治疗模拟记录

 所有示例数据均为真实场景模拟，可直接用于开发和测试！
*/
