/*
 星云医疗助手 - 新增功能模块数据库表 (第二部分: AR院内导航模块)

 模块说明:
   二、AR院内导航模块 (AR Navigation Module)
   功能对应: 项目功能清单第7章 - AR院内导航
   页面: ARNavigationPage, DestinationSelectPage, NavigationSummaryPage, VoiceAssistantPage
   组件: ARNavigationService, PathPlanner, IndoorLocator, ARRenderer, VoiceGuide
   用途: 医院内部AR导航地图管理、路径规划、兴趣点定位、导航历史记录

 包含表:
   表4: navigation_map (导航地图数据表) - 存储医院各楼层地图拓扑结构
   表5: navigation_point (导航兴趣点表) - 存储科室、电梯、洗手间等关键位置
   表6: navigation_history (导航历史记录表) - 记录用户导航轨迹和统计

 依赖: 需要先执行 new_tables_part1_parking.sql (如果需要完整导入)
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 二、AR院内导航模块 (AR Navigation Module)
-- ============================================================================

-- ----------------------------
-- 表4: navigation_map (导航地图数据表)
-- 用途: 存储医院各楼层/区域的完整导航地图数据，包括路径节点、连通性等
-- 数据格式: map_data字段存储JSON格式地图拓扑结构
-- 关联: hospital表 (hospital_id外键)
-- ----------------------------
DROP TABLE IF EXISTS `navigation_map`;
CREATE TABLE `navigation_map` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '地图ID，主键自增',
  `hospital_id` bigint NOT NULL COMMENT '所属医院ID',
  `map_name` varchar(100) NOT NULL COMMENT '地图名称，如"门诊楼1F平面图"、"外科楼B1导航图"',
  `floor` varchar(20) NOT NULL COMMENT '楼层标识，如"1F"、"2F"、"B1"、"B2"、"屋顶"',
  `building_name` varchar(100) DEFAULT NULL COMMENT '建筑名称，如"门诊楼"、"外科楼"、"急诊楼"',
  `map_data` json NOT NULL COMMENT '地图数据(JSON格式): 包含nodes(节点)、edges(边)、pois(兴趣点)等',
  `map_image_url` varchar(500) DEFAULT NULL COMMENT '地图背景图片URL',
  `map_width` int DEFAULT 1920 COMMENT '地图宽度(像素)',
  `map_height` int DEFAULT 1080 COMMENT '地图高度(像素)',
  `scale_ratio` decimal(10,4) DEFAULT 1.0000 COMMENT '比例尺(米/像素)',
  `version` varchar(20) DEFAULT 'v1.0' COMMENT '地图版本号',
  `update_reason` varchar(255) DEFAULT NULL COMMENT '更新原因描述',
  `total_nodes` int DEFAULT 0 COMMENT '路径节点总数',
  `total_edges` int DEFAULT 0 COMMENT '路径边总数',
  `coverage_area` decimal(10,2) DEFAULT NULL COMMENT '覆盖面积(平方米)',
  `is_published` tinyint NOT NULL DEFAULT 0 COMMENT '是否已发布: 0=草稿 1=已发布',
  `effective_date` datetime DEFAULT NULL COMMENT '生效日期',
  `creator_id` bigint DEFAULT NULL COMMENT '创建者(管理员)ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_hospital_id` (`hospital_id`),
  INDEX `idx_floor` (`floor`),
  INDEX `idx_building` (`building_name`),
  INDEX `idx_version` (`version`),
  INDEX `idx_published` (`is_published`),
  CONSTRAINT `fk_navmap_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospital` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导航地图数据表';

-- 示例数据: 插入医院各楼层地图
INSERT INTO `navigation_map` (`id`, `hospital_id`, `map_name`, `floor`, `building_name`, `map_data`, `map_image_url`, `map_width`, `map_height`, `scale_ratio`, `version`, `update_reason`, `total_nodes`, `total_edges`, `coverage_area`, `is_published`, `effective_date`, `creator_id`, `create_time`, `update_time`, `is_deleted`) VALUES
(1, 377, '门诊楼1F大厅导航图', '1F', '门诊楼',
 '{"nodes":[{"id":"n1","x":100,"y":200,"type":"entrance","label":"正门入口"},{"id":"n2","x":400,"y":200,"type":"junction","label":"大厅中心"},{"id":"n3","x":700,"y":150,"type":"poi","label":"挂号处"},{"id":"n4","x":700,"y":250,"type":"poi","label":"收费处"},{"id":"n5","x":400,"y":400,"type":"elevator","label":"1号电梯"},{"id":"n6","x":200,"y":400,"type":"stairs","label":"楼梯A"}],"edges":[{"from":"n1","to":"n2","weight":10},{"from":"n2","to":"n3","weight":8},{"from":"n2","to":"n4","weight":8},{"from":"n2","to":"n5","weight":12},{"from":"n2","to":"n6","weight":15}],"pois":[{"nodeId":"n3","category":"service","subCategory":"registration"},{"nodeId":"n4","category":"service","subCategory":"payment"}]}',
 '/images/maps/outpatient_1f.png', 1920, 1080, 0.5000, 'v2.1', '优化挂号处路径节点', 6, 5, 3840.00, 1, '2026-04-01 00:00:00', 1, NOW(), NOW(), 0),

(2, 377, '门诊楼2F科室分布图', '2F', '门诊楼',
 '{"nodes":[{"id":"n1","x":400,"y":100,"type":"elevator","label":"1号电梯"},{"id":"n2","x":200,"y":300,"type":"poi","label":"内科诊区"},{"id":"n3","x":600,"y":300,"type":"poi","label":"外科诊区"},{"id":"n4","x":400,"y":500,"type":"poi","label":"检验科"},{"id":"n5","x":800,"y":300,"type":"poi","label":"药房"}],"edges":[{"from":"n1","to":"n2","weight":12},{"from":"n1","to":"n3","weight":12},{"from":"n2","to":"n4","weight":15},{"from":"n3","to":"n4","weight":15},{"from":"n3","to":"n5","weight":10}],"pois":[{"nodeId":"n2","category":"department","subCategory":"internal_medicine"},{"nodeId":"n3","category":"department","subCategory":"surgery"},{"nodeId":"n4","category":"service","subCategory":"lab"},{"nodeId":"n5","category":"service","subCategory":"pharmacy"}]}',
 '/images/maps/outpatient_2f.png', 1920, 1080, 0.4800, 'v1.8', '新增药房位置', 5, 5, 3686.40, 1, '2026-03-15 00:00:00', 1, NOW(), NOW(), 0),

(3, 377, '门诊楼B1停车场导航图', 'B1', '门诊楼',
 '{"nodes":[{"id":"n1","x":100,"y":400,"type":"entrance","label":"停车场入口"},{"id":"n2","x":300,"y":400,"type":"junction","label":"主通道"},{"id":"n3","x":500,"y":200,"type":"poi","label":"A区车位"},{"id":"n4","x":500,"y":400,"type":"poi","label":"B区车位"},{"id":"n5","x":500,"y":600,"type":"poi","label":"C区车位"},{"id":"n6","x":800,"y":400,"type":"elevator","label":"电梯厅"}],"edges":[{"from":"n1","to":"n2","weight":8},{"from":"n2","to":"n3","weight":10},{"from":"n2","to":"n4","weight":8},{"from":"n2","to":"n5","weight":10},{"from":"n4","to":"n6","weight":15}],"pois":[{"nodeId":"n3","category":"parking","subCategory":"area_a"},{"nodeId":"n4","category":"parking","subCategory":"area_b"},{"nodeId":"n5","category":"parking","subCategory":"area_c"},{"nodeId":"n6","category":"facility","subCategory":"elevator"}]}',
 '/images/maps/parking_b1.png', 2048, 1152, 0.6000, 'v1.5', '初始版本', 6, 5, 5631.15, 1, '2026-02-01 00:00:00', 2, NOW(), NOW(), 0);

-- ----------------------------
-- 表5: navigation_point (导航兴趣点表)
-- 用途: 存储医院内的所有关键位置点，如科室、电梯、洗手间、出口、ATM等
-- 这些点是AR导航的目的地和途经点
-- 关联: hospital表, navigation_map表
-- ----------------------------
DROP TABLE IF EXISTS `navigation_point`;
CREATE TABLE `navigation_point` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '兴趣点ID，主键自增',
  `hospital_id` bigint NOT NULL COMMENT '所属医院ID',
  `map_id` bigint DEFAULT NULL COMMENT '所属地图ID(可选，跨楼层POI可为NULL)',
  `point_name` varchar(100) NOT NULL COMMENT '地点名称，如"心内科诊室"、"1号电梯"、"洗手间"',
  `point_name_en` varchar(100) DEFAULT NULL COMMENT '英文名称',
  `point_type` enum('DEPARTMENT','ELEVATOR','STAIRS','RESTROOM','ENTRANCE','EXIT','SERVICE_DESK','PHARMACY','LAB','WAITING_AREA','EMERGENCY','ATM','CAFETERIA','PARKING','INFORMATION','OTHER') NOT NULL COMMENT '地点类型: DEPARTMENT=科室 ELEVATOR=电梯 STAIRS=楼梯 RESTROOM=洗手间 ENTRANCE=入口 EXIT=出口 SERVICE_DESK=服务台 PHARMACY=药房 LAB=检验科 WAITING_AREA=候诊区 EMERGENCY=急诊 ATM=取款机 CAFETERIA=餐厅 PARKING=停车场 INFORMATION=问询处 OTHER=其他',
  `point_category` varchar(50) DEFAULT NULL COMMENT '细分分类，如"内科"、"外科"、"男厕"、"女厕"',
  `location_x` decimal(10,4) NOT NULL COMMENT 'X坐标(相对于地图左上角，单位:像素或米)',
  `location_y` decimal(10,4) NOT NULL COMMENT 'Y坐标',
  `floor` varchar(20) NOT NULL COMMENT '所在楼层',
  `building` varchar(100) DEFAULT NULL COMMENT '所在建筑',
  `room_number` varchar(50) DEFAULT NULL COMMENT '房间号，如"201"、"305A"',
  `description` text COMMENT '位置描述，如"门诊楼2楼东侧走廊尽头"',
  `icon_url` varchar(255) DEFAULT NULL COMMENT '图标URL(用于AR显示)',
  `ar_model_url` varchar(255) DEFAULT NULL COMMENT 'AR 3D模型URL',
  `working_hours` varchar(100) DEFAULT NULL COMMENT '营业时间，如"08:00-17:00"',
  `phone` varchar(30) DEFAULT NULL COMMENT '联系电话',
  `is_accessible` tinyint NOT NULL DEFAULT 1 COMMENT '是否无障碍可达: 0=否 1=是',
  `popularity_score` int DEFAULT 0 COMMENT '热门程度评分(0-100)',
  `search_keywords` varchar(500) DEFAULT NULL COMMENT '搜索关键词，逗号分隔',
  `nearby_points` json DEFAULT NULL COMMENT '附近兴趣点ID列表JSON',
  `sort_order` int DEFAULT 0 COMMENT '排序权重(数字越小越靠前)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=禁用 1=启用 2=临时关闭',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_hospital_id` (`hospital_id`),
  INDEX `idx_map_id` (`map_id`),
  INDEX `idx_point_type` (`point_type`),
  INDEX `idx_floor` (`floor`),
  INDEX `idx_point_name` (`point_name`),
  INDEX `idx_location` (`location_x`, `location_y`),
  FULLTEXT INDEX `ft_search` (`point_name`, `description`, `search_keywords`),
  CONSTRAINT `fk_navpoint_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospital` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_navpoint_map` FOREIGN KEY (`map_id`) REFERENCES `navigation_map` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导航兴趣点表';

-- 示例数据: 插入各类兴趣点
INSERT INTO `navigation_point` VALUES
(1, 377, 1, '门诊大厅正门入口', 'Main Entrance', 'ENTRANCE', NULL, 100.0000, 200.0000, '1F', '门诊楼', NULL, '门诊楼正门，面向帅府园大街', '/icons/entrance.png', NULL, '00:00-24:00', NULL, 1, 95, '入口,大门,正门', '[2,6]', 1, 1, NOW(), NOW(), 0),
(2, 377, 1, '挂号收费处', 'Registration & Payment', 'SERVICE_DESK', NULL, 700.0000, 150.0000, '1F', '门诊楼', '大厅右侧', '位于门诊大厅东北侧，提供挂号、缴费服务', '/icons/service_desk.png', NULL, '07:30-17:00', '010-69156699', 1, 98, '挂号,收费,缴费,注册', '[3,4]', 1, 1, NOW(), NOW(), 0),
(3, 377, 1, '1号客梯', 'Elevator No.1', 'ELEVATOR', NULL, 400.0000, 400.0000, '1F', '门诊楼', '大厅中央', '连接B3至5F的客用电梯', '/icons/elevator.png', '/models/elevator.glb', '00:00-24:00', NULL, 1, 99, '电梯,升降梯,1号梯', '[1,2,5]', 2, 1, NOW(), NOW(), 0),
(4, 377, 1, '楼梯A(应急通道)', 'Staircase A (Emergency)', 'STAIRS', NULL, 200.0000, 400.0000, '1F', '门诊楼', '大厅西侧', '应急疏散楼梯，连接所有楼层', '/icons/stairs.png', NULL, '00:00-24:00', NULL, 1, 60, '楼梯,步行梯,应急通道', '[1,6]', 3, 1, NOW(), NOW(), 0),
(5, 377, 2, '内科诊区', 'Internal Medicine Dept', 'DEPARTMENT', '内科', 200.0000, 300.0000, '2F', '门诊楼', '201-215', '包含心内科、呼吸内科、消化内科等诊室', '/icons/department.png', NULL, '08:00-12:00,13:30-17:00', '010-69156001', 1, 96, '内科,心内,呼吸,消化,内分泌', '[6,4]', 1, 1, NOW(), NOW(), 0),
(6, 377, 2, '外科诊区', 'Surgery Dept', 'DEPARTMENT', '外科', 600.0000, 300.0000, '2F', '门诊楼', '216-230', '包含普外科、骨科、神经外科等诊室', '/icons/department.png', NULL, '08:00-12:00,13:30-17:00', '010-69156002', 1, 94, '外科,骨科,神经外科,普外', '[5,7]', 2, 1, NOW(), NOW(), 0),
(7, 377, 2, '门诊药房', 'Outpatient Pharmacy', 'PHARMACY', NULL, 800.0000, 300.0000, '2F', '门诊楼', '240', '西药、中药房，支持医保结算', '/icons/pharmacy.png', NULL, '08:00-17:30', '010-69156003', 1, 97, '药房,取药,买药,发药', '[6]', 3, 1, NOW(), NOW(), 0),
(8, 377, 2, '检验科', 'Laboratory', 'LAB', '检验', 400.0000, 500.0000, '2F', '门诊楼', '250-260', '血液、尿液、生化检验', '/icons/lab.png', NULL, '07:30-17:00', '010-69156004', 1, 85, '检验,化验,抽血,验血', '[5,6]', 4, 1, NOW(), NOW(), 0),
(9, 377, 1, '患者服务中心', 'Patient Service Center', 'INFORMATION', NULL, 500.0000, 250.0000, '1F', '门诊楼', NULL, '提供咨询、导诊、投诉建议等服务', '/icons/info.png', NULL, '07:30-17:00', '010-69156666', 1, 92, '咨询,导诊,问询,服务台', '[2,3]', 5, 1, NOW(), NOW(), 0),
(10, 377, 3, 'B1停车场A区', 'Parking Area A', 'PARKING', 'A区', 500.0000, 200.0000, 'B1', '门诊楼', NULL, '普通车位区域，靠近电梯', '/icons/parking.png', NULL, '00:00-24:00', NULL, 1, 88, '停车,A区,车位,车库', '[6]', 1, 1, NOW(), NOW(), 0),
(11, 377, 1, '男卫生间', 'Men\'s Restroom', 'RESTROOM', '男厕', 150.0000, 350.0000, '1F', '门诊楼', '105', '门诊楼1楼西侧男卫生间', '/icons/restroom_m.png', NULL, '00:00-24:00', NULL, 1, 70, '厕所,卫生间,洗手间,男厕', '[4]', 10, 1, NOW(), NOW(), 0),
(12, 377, 1, '女卫生间', 'Women\'s Restroom', 'RESTROOM', '女厕', 150.0000, 380.0000, '1F', '门诊楼', '106', '门诊楼1楼西侧女卫生间', '/icons/restroom_w.png', NULL, '00:00-24:00', NULL, 1, 70, '厕所,卫生间,洗手间,女厕', '[4]', 10, 1, NOW(), NOW(), 0);

-- ----------------------------
-- 表6: navigation_history (导航历史记录表)
-- 用途: 记录用户的AR导航历史，用于分析常用路线、优化推荐、个性化体验
-- 存储完整的导航轨迹和统计数据
-- 关联: user表, navigation_point表
-- ----------------------------
DROP TABLE IF EXISTS `navigation_history`;
CREATE TABLE `navigation_history` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '导航记录ID，主键自增',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `session_id` varchar(64) NOT NULL COMMENT '导航会话唯一标识(UUID)',
  `start_point_id` bigint DEFAULT NULL COMMENT '起始点ID(navigation_point表)',
  `start_point_name` varchar(100) DEFAULT NULL COMMENT '起始点名称(冗余存储)',
  `end_point_id` bigint DEFAULT NULL COMMENT '目的地ID',
  `end_point_name` varchar(100) DEFAULT NULL COMMENT '目的地名称',
  `start_time` datetime NOT NULL COMMENT '导航开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '导航结束时间(NULL表示进行中)',
  `duration_seconds` int DEFAULT NULL COMMENT '实际耗时(秒)，结束后计算',
  `estimated_duration` int DEFAULT NULL COMMENT '预估时长(秒)',
  `route_data` json DEFAULT NULL COMMENT '完整路径数据(JSON): 包含waypoints、distance、turns等',
  `route_distance` decimal(10,2) DEFAULT NULL COMMENT '路径总距离(米)',
  `route_image_url` varchar(500) DEFAULT NULL COMMENT '导航轨迹截图URL',
  `navigation_mode` enum('AR','MAP','VOICE','HYBRID') NOT NULL DEFAULT 'AR' COMMENT '导航模式: AR=增强现实 MAP=2D地图 VOICE=语音 HYBRID=混合',
  `device_info` varchar(255) DEFAULT NULL COMMENT '设备信息，如"Huawei Mate 60 Pro"',
  `ar_accuracy` decimal(5,2) DEFAULT NULL COMMENT 'AR定位精度(米)，0-5优秀 5-10良好 >10一般',
  `completion_status` enum('COMPLETED','CANCELLED','INTERRUPTED','TIMEOUT','DEV_OFF_ROUTE') NOT NULL DEFAULT 'COMPLETED' COMMENT '完成状态: COMPLETED=成功完成 CANCELLED=用户取消 INTERRUPTED=中断 TIMEOUT=超时 DEV_OFF_ROUTE=设备偏离路线',
  `interruption_reason` varchar(255) DEFAULT NULL COMMENT '中断原因',
  `feedback_rating` tinyint DEFAULT NULL COMMENT '用户评分(1-5星)',
  `feedback_comment` text COMMENT '用户反馈内容',
  `error_count` int DEFAULT 0 COMMENT '定位错误次数',
  `reroute_count` int DEFAULT 0 COMMENT '重新规划次数',
  `battery_start` int DEFAULT NULL COMMENT '开始时电量(%)',
  `battery_end` int DEFAULT NULL COMMENT '结束时电量(%)',
  `hospital_id` bigint DEFAULT NULL COMMENT '所属医院ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_session_id` (`session_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_start_time` (`start_time`),
  INDEX `idx_end_point_id` (`end_point_id`),
  INDEX `idx_completion_status` (`completion_status`),
  INDEX `idx_navigation_mode` (`navigation_mode`),
  INDEX `idx_hospital_id` (`hospital_id`),
  CONSTRAINT `fk_navhist_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_navhist_start_point` FOREIGN KEY (`start_point_id`) REFERENCES `navigation_point` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_navhist_end_point` FOREIGN KEY (`end_point_id`) REFERENCES `navigation_point` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_navhist_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospital` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导航历史记录表';

-- 示例数据: 插入各种状态的导航记录
INSERT INTO `navigation_history` (`id`, `user_id`, `session_id`, `start_point_id`, `start_point_name`, `end_point_id`, `end_point_name`, `start_time`, `end_time`, `duration_seconds`, `estimated_duration`, `route_data`, `route_distance`, `route_image_url`, `navigation_mode`, `device_info`, `ar_accuracy`, `completion_status`, `interruption_reason`, `feedback_rating`, `feedback_comment`, `error_count`, `reroute_count`, `battery_start`, `battery_end`, `hospital_id`, `create_time`, `update_time`) VALUES
(1, 107, 'nav_session_20260509_001', 1, '门诊大厅正门入口', 5, '内科诊区', '2026-05-09 08:35:00', '2026-05-09 08:42:15', 435, 420, '{"waypoints":[{"order":1,"pointId":1,"x":100,"y":200},{"order":2,"pointId":2,"x":400,"y":200,"instruction":"直行"},{"order":3,"pointId":3,"x":400,"y":400,"instruction":"左转乘电梯"},{"order":4,"pointId":5,"x":200,"y":300,"instruction":"出电梯右转"}],"turns":["left"],"distance":185,"estimatedTime":420}', 185.50, '/images/routes/nav_20260509_001.png', 'AR', 'Huawei Mate 60 Pro', 2.35, 'COMPLETED', NULL, 5, 'AR导航体验流畅，路线清晰，语音提示及时', 0, 0, 95, 93, 377, NOW(), NOW()),

(2, 108, 'nav_session_20260510_001', 10, 'B1停车场A区', 2, '挂号收费处', '2026-05-10 07:20:00', '2026-05-10 07:28:30', 510, 480, '{"waypoints":[{"order":1,"pointId":10,"x":500,"y":200},{"order":2,"pointId":6,"x":800,"y":400,"instruction":"乘电梯至1F"},{"order":3,"pointId":2,"x":700,"y":150,"instruction":"出电梯右转"}],"turns":["right"],"distance":210,"estimatedTime":480}', 210.00, '/images/routes/nav_20260510_001.png', 'HYBRID', 'HUAWEI WATCH 4 Pro', 3.80, 'COMPLETED', NULL, 4, '手表导航很方便，但屏幕较小看地图有点吃力', 1, 1, 88, 85, 377, NOW(), NOW()),

(3, 109, 'nav_session_20260510_002', 3, '1号客梯', 7, '门诊药房', '2026-05-10 10:15:00', NULL, NULL, 300, NULL, NULL, NULL, NULL, 'AR', 'HUAWEI Pura 70 Ultra', 1.52, 'INTERRUPTED', '患者接到电话需要返回停车场取物品', NULL, NULL, 0, 0, 78, NULL, 377, NOW(), NOW()),

(4, 107, 'nav_session_20260508_001', 1, '门诊大厅正门入口', 8, '检验科', '2026-05-08 09:00:00', '2026-05-08 09:06:45', 405, 390, '{"waypoints":[{"order":1,"pointId":1,"x":100,"y":200},{"order":2,"pointId":3,"x":400,"y":400,"instruction":"直行至电梯"},{"order":3,"pointId":8,"x":400,"y":500,"instruction":"2楼出电梯直行"}],"turns":[],"distance":175,"estimatedTime":390}', 175.20, NULL, 'MAP', 'HUAZE Pad Air', NULL, 'COMPLETED', NULL, 5, '2D地图模式简单直接，适合老年人使用', 0, 0, 100, 99, 377, NOW(), NOW()),

(5, 110, 'nav_session_20260509_002', 11, '男卫生间', 6, '外科诊区', '2026-05-09 14:30:00', '2026-05-09 14:33:20', 200, 180, '{"waypoints":[{"order":1,"pointId":11,"x":150,"y":350},{"order":2,"pointId":4,"x":200,"y":400,"instruction":"右转至楼梯"},{"order":3,"pointId":6,"x":600,"y":300,"instruction":"2楼左转"}],"turns":["right","left"],"distance":95,"estimatedTime":180}', 95.80, NULL, 'VOICE', 'HUAWEI FreeBuds Pro 3', NULL, 'COMPLETED', NULL, 4, '语音导航解放双手，适合赶时间的场景', 0, 0, 82, 81, 377, NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;

/*
 ============================================================================
 AR院内导航模块说明:

 表4 - navigation_map (导航地图数据表):
   存储3张示例地图:
     - 门诊楼1F大厅(6个节点，5条边): 入口→大厅中心→挂号处/收费处/电梯/楼梯
     - 门诊楼2F科室层(5个节点，5条边): 电梯→内科/外科/检验科→药房
     - B1停车场(6个节点，5条边): 入口→主通道→A/B/C区车位→电梯厅
   map_data字段使用JSON存储完整的图结构(nodes + edges + pois)
   支持版本管理和发布控制

 表5 - navigation_point (导航兴趣点表):
   存储12个示例兴趣点，覆盖16种类型中的11种:
     - DEPARTMENT(2个): 内科诊区、外科诊区
     - ELEVATOR(1个): 1号客梯
     - STAIRS(1个): 应急楼梯
     - RESTROOM(2个): 男/女卫生间
     - ENTRANCE(1个): 正门入口
     - SERVICE_DESK(1个): 挂号收费处
     - PHARMACY(1个): 门诊药房
     - LAB(1个): 检验科
     - INFORMATION(1个): 患者服务中心
     - PARKING(1个): 停车场A区
   包含详细的坐标、营业时间、联系方式、无障碍标识
   支持全文搜索(ft_search索引)

 表6 - navigation_history (导航历史记录表):
   存储5条示例记录，展示不同场景:
     - AR模式完成导航(手机，精度2.35米，评分5星)
     - 混合模式导航(手表设备，包含重规划)
     - AR模式中断(正在进行的导航)
     - 2D地图模式导航(平板设备)
     - 语音导航(蓝牙耳机设备)
   记录完整的路径数据(waypoints)、距离、耗时、电池消耗
   支持多维度分析(设备类型、导航模式、完成率、用户满意度)
*/
