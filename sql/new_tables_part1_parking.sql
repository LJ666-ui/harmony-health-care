/*
 星云医疗助手 - 新增功能模块数据库表

 说明：本文件包含4个功能模块共12个新表
       用于支持停车服务、AR导航、智慧病房、数字孪生等核心功能

 创建时间: 2026-05-10
 数据库版本: MySQL 8.0+
 字符集: utf8mb4
 排序规则: utf8mb4_0900_ai_ci

 使用方法:
   1. 确保已导入 medical_health2.sql 基础数据库
   2. 在MySQL中执行本文件即可创建所有新表和示例数据
   3. 执行前请备份数据库

 模块清单:
   一、停车服务模块 (3个表) - 第14章功能
   二、AR院内导航模块 (3个表) - 第7章功能
   三、智慧病房系统模块 (4个表) - 第8章功能
   四、数字孪生系统模块 (2个表) - 第6章功能
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- 一、停车服务模块 (Parking Service Module)
-- 功能对应: 项目功能清单第14章 - 停车服务
-- 页面: ParkingListPage, ParkingSpacePage, FindCarPage, NavigationEngine
-- 用途: 医院停车场管理、车位查询、停车记录、费用计算、找车导航
-- ============================================================================

-- ----------------------------
-- 表1: parking_lot (停车场信息表)
-- 用途: 存储医院停车场的基本信息，包括位置、容量、收费标准等
-- 关联: hospital表 (hospital_id外键)
-- ----------------------------
DROP TABLE IF EXISTS `parking_lot`;
CREATE TABLE `parking_lot` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '停车场ID，主键自增',
  `hospital_id` bigint NOT NULL COMMENT '关联的医院ID',
  `name` varchar(100) NOT NULL COMMENT '停车场名称，如"门诊楼地下停车场"',
  `address` varchar(255) DEFAULT NULL COMMENT '详细地址，如"B1层-B3层"',
  `total_spaces` int NOT NULL DEFAULT 0 COMMENT '总车位数量',
  `available_spaces` int NOT NULL DEFAULT 0 COMMENT '当前可用车位数量',
  `latitude` decimal(10,6) DEFAULT NULL COMMENT '纬度坐标',
  `longitude` decimal(10,6) DEFAULT NULL COMMENT '经度坐标',
  `hourly_rate` decimal(10,2) NOT NULL DEFAULT 5.00 COMMENT '每小时收费标准(元)',
  `max_daily_rate` decimal(10,2) DEFAULT NULL COMMENT '每日最高收费(元)',
  `free_minutes` int NOT NULL DEFAULT 30 COMMENT '免费停放时长(分钟)',
  `open_time` time DEFAULT '00:00:00' COMMENT '开放时间',
  `close_time` time DEFAULT '23:59:59' COMMENT '关闭时间',
  `has_charging` tinyint NOT NULL DEFAULT 0 COMMENT '是否有充电桩: 0=无 1=有',
  `has_vip` tinyint NOT NULL DEFAULT 0 COMMENT '是否有VIP专区: 0=无 1=有',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0=关闭 1=正常运营 2=维护中',
  `description` text COMMENT '停车场描述信息',
  `entrance_count` int NOT NULL DEFAULT 1 COMMENT '入口数量',
  `exit_count` int NOT NULL DEFAULT 1 COMMENT '出口数量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除: 0=未删除 1=已删除',
  PRIMARY KEY (`id`),
  INDEX `idx_hospital_id` (`hospital_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_location` (`latitude`, `longitude`),
  CONSTRAINT `fk_parking_hospital` FOREIGN KEY (`hospital_id`) REFERENCES `hospital` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='停车场信息表';

-- 示例数据: 插入3个医院停车场
INSERT INTO `parking_lot` VALUES
(1, 377, '协和医院门诊地下停车场', '东城区帅府园1号B1-B3层', 500, 127, 39.913889, 116.416667, 8.00, 80.00, 15, '06:00:00', '23:00:00', 1, 1, 1, '门诊楼正下方大型停车场，配备智能导引系统', 2, 2, NOW(), NOW(), 0),
(2, 377, '协和医院外科楼停车场', '东城区帅府园1号北侧地面', 200, 89, 39.915000, 116.417000, 6.00, 60.00, 30, '00:00:00', '23:59:59', 0, 0, 1, '外科楼旁地面停车场，适合急诊车辆', 1, 1, NOW(), NOW(), 0),
(3, 378, '朝阳医院立体停车库', '朝阳区工人体育场南路8号', 350, 203, 39.920000, 116.450000, 5.00, 50.00, 30, '00:00:00', '24:00:00', 1, 1, 1, '智能化立体车库，自动泊车系统', 1, 1, NOW(), NOW(), 0);

-- ----------------------------
-- 表2: parking_space (车位信息表)
-- 用途: 存储每个停车场的具体车位详情，包括类型、位置、状态等
-- 关联: parking_lot表 (parking_lot_id外键)
-- ----------------------------
DROP TABLE IF EXISTS `parking_space`;
CREATE TABLE `parking_space` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '车位ID，主键自增',
  `parking_lot_id` bigint NOT NULL COMMENT '所属停车场ID',
  `space_number` varchar(20) NOT NULL COMMENT '车位编号，如"A-001"、"B2-056"',
  `space_type` enum('NORMAL','VIP','CHARGING','DISABLED','COMPACT') NOT NULL DEFAULT 'NORMAL' COMMENT '车位类型: NORMAL=普通 VIP=贵宾 CHARGING=充电桩 DISABLED=残疾人 COMPACT=紧凑型',
  `floor` varchar(10) DEFAULT NULL COMMENT '所在楼层，如"B1"、"B2"、"地面"',
  `area` varchar(50) DEFAULT NULL COMMENT '区域标识，如"A区"、"B区"、"靠近电梯"',
  `status` enum('AVAILABLE','OCCUPIED','RESERVED','MAINTENANCE','OUT_OF_SERVICE') NOT NULL DEFAULT 'AVAILABLE' COMMENT '状态: AVAILABLE=空闲 OCCUPIED=占用 RESERVED=预约 MAINTENANCE=维护中 OUT_OF_SERVICE=停用',
  `vehicle_type` enum('CAR','SUV','ELECTRIC','MOTORCYCLE') DEFAULT 'CAR' COMMENT '适用车型: CAR=轿车 SUV=SUV ELECTRIC=电动车 MOTORCYCLE=摩托车',
  `width_cm` int DEFAULT 250 COMMENT '车位宽度(厘米)',
  `length_cm` int DEFAULT 550 COMMENT '车位长度(厘米)',
  `distance_to_elevator` int DEFAULT NULL COMMENT '距离电梯距离(米)',
  `distance_to_exit` int DEFAULT NULL COMMENT '距离出口距离(米)',
  `has_shelter` tinyint NOT NULL DEFAULT 1 COMMENT '是否有遮阳棚: 0=无 1=有',
  `charging_power` decimal(10,2) DEFAULT NULL COMMENT '充电桩功率(kW)，仅充电桩车位有效',
  `last_updated` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `uk_space_number` (`parking_lot_id`, `space_number`),
  INDEX `idx_parking_lot_id` (`parking_lot_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_space_type` (`space_type`),
  CONSTRAINT `fk_space_parking_lot` FOREIGN KEY (`parking_lot_id`) REFERENCES `parking_lot` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='车位信息表';

-- 示例数据: 插入不同类型的车位
INSERT INTO `parking_space` VALUES
(1, 1, 'A-001', 'VIP', 'B1', 'A区靠近电梯', 'AVAILABLE', 'CAR', 300, 600, 10, 50, 1, NULL, NOW(), NOW()),
(2, 1, 'A-002', 'VIP', 'B1', 'A区靠近电梯', 'OCCUPIED', 'SUV', 300, 600, 10, 50, 1, NULL, NOW(), NOW()),
(3, 1, 'B-045', 'CHARGING', 'B2', 'B区充电区', 'AVAILABLE', 'ELECTRIC', 280, 580, 25, 80, 1, 120.00, NOW(), NOW()),
(4, 1, 'B-046', 'CHARGING', 'B2', 'B区充电区', 'OCCUPIED', 'ELECTRIC', 280, 580, 25, 80, 1, 120.00, NOW(), NOW()),
(5, 1, 'C-089', 'DISABLED', 'B1', 'C区无障碍', 'AVAILABLE', 'CAR', 350, 650, 5, 30, 1, NULL, NOW(), NOW()),
(6, 1, 'C-090', 'DISABLED', 'B1', 'C区无障碍', 'RESERVED', 'CAR', 350, 650, 5, 30, 1, NULL, NOW(), NOW()),
(7, 2, 'G-012', 'NORMAL', '地面', '北区普通', 'AVAILABLE', 'CAR', 250, 550, 50, 20, 0, NULL, NOW(), NOW()),
(8, 2, 'G-013', 'NORMAL', '地面', '北区普通', 'OCCUPIED', 'SUV', 250, 550, 50, 20, 0, NULL, NOW(), NOW()),
(9, 3, 'L1-A01', 'COMPACT', 'L1', 'A区紧凑型', 'AVAILABLE', 'CAR', 220, 450, 15, 40, 1, NULL, NOW(), NOW()),
(10, 3, 'L1-B02', 'CHARGING', 'L1', 'B区快充', 'AVAILABLE', 'ELECTRIC', 280, 580, 20, 35, 1, 180.00, NOW(), NOW());

-- ----------------------------
-- 表3: parking_record (停车记录表)
-- 用途: 记录用户每次停车的完整信息，用于计费、历史查询、找车等功能
-- 关联: user表, parking_lot表, parking_space表
-- ----------------------------
DROP TABLE IF EXISTS `parking_record`;
CREATE TABLE `parking_record` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID，主键自增',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID(匿名停车可为NULL)',
  `parking_lot_id` bigint NOT NULL COMMENT '停车场ID',
  `parking_space_id` bigint DEFAULT NULL COMMENT '实际停放的车位ID',
  `plate_number` varchar(20) NOT NULL COMMENT '车牌号码',
  `vehicle_color` varchar(20) DEFAULT NULL COMMENT '车辆颜色',
  `vehicle_brand` varchar(50) DEFAULT NULL COMMENT '车辆品牌',
  `entry_time` datetime NOT NULL COMMENT '入场时间',
  `exit_time` datetime DEFAULT NULL COMMENT '出场时间(NULL表示未出场)',
  `planned_duration` int DEFAULT NULL COMMENT '预计停放时长(分钟)',
  `actual_duration` int DEFAULT NULL COMMENT '实际停放时长(分钟)，出场后计算',
  `hourly_rate` decimal(10,2) NOT NULL COMMENT '实际使用的小时费率',
  `total_fee` decimal(10,2) DEFAULT 0.00 COMMENT '总费用(元)',
  `discount_amount` decimal(10,2) DEFAULT 0.00 COMMENT '优惠金额(元)',
  `payment_method` enum('CASH','WECHAT','ALIPAY','CARD','AUTO') DEFAULT NULL COMMENT '支付方式: CASH=现金 WECHAT=微信 ALIPAY=支付宝 CARD=银行卡 AUTO=自动扣款',
  `payment_status` enum('UNPAID','PAID','REFUNDING','REFUNDED') NOT NULL DEFAULT 'UNPAID' COMMENT '支付状态: UNPAID=未支付 PAID=已支付 REFUNDING=退款中 REFUNDED=已退款',
  `payment_time` datetime DEFAULT NULL COMMENT '支付时间',
  `transaction_id` varchar(100) DEFAULT NULL COMMENT '第三方交易流水号',
  `navigation_used` tinyint NOT NULL DEFAULT 0 COMMENT '是否使用了找车导航: 0=否 1=是',
  `entry_gate` varchar(50) DEFAULT NULL COMMENT '入场闸机口',
  `exit_gate` varchar(50) DEFAULT NULL COMMENT '出场闸机口',
  `parking_level` enum('UNDERGROUND','GROUND','ROOFTOP') DEFAULT 'UNDERGROUND' COMMENT '停车层级: UNDERGROUND=地下 GROUND=地面 ROOFTOP=顶层',
  `notes` text COMMENT '备注信息',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_plate_number` (`plate_number`),
  INDEX `idx_parking_lot_id` (`parking_lot_id`),
  INDEX `idx_entry_time` (`entry_time`),
  INDEX `idx_payment_status` (`payment_status`),
  INDEX `idx_entry_exit` (`entry_time`, `exit_time`),
  CONSTRAINT `fk_record_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_record_parking_lot` FOREIGN KEY (`parking_lot_id`) REFERENCES `parking_lot` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_record_parking_space` FOREIGN KEY (`parking_space_id`) REFERENCES `parking_space` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='停车记录表';

-- 示例数据: 插入各种状态的停车记录
INSERT INTO `parking_record` VALUES
(1, 107, 1, 2, '京A12345', '白色', '丰田凯美瑞', '2026-05-09 08:30:00', '2026-05-09 14:45:00', 360, 375, 8.00, 48.00, 5.00, 'WECHAT', 'PAID', '2026-05-09 14:46:00', 'WX202605091446001234', 1, '南门入口', '南门出口', 'UNDERGROUND', '就诊结束，已缴费离场', NOW(), NOW()),
(2, 108, 1, NULL, '京B67890', '黑色', '本田CR-V', '2026-05-10 07:15:00', NULL, 240, NULL, 8.00, 0.00, 0.00, NULL, 'UNPAID', NULL, NULL, 0, '北门入口', NULL, 'UNDERGROUND', '正在就诊中', NOW(), NOW()),
(3, NULL, 2, 7, '京C11111', '银色', '大众帕萨特', '2026-05-10 09:00:00', '2026-05-10 11:30:00', 180, 150, 6.00, 15.00, 0.00, 'ALIPAY', 'PAID', '2026-05-10 11:31:00', 'ALI202605101131005678', 0, '东侧入口', '西侧出口', 'GROUND', '急诊快速停车', NOW(), NOW()),
(4, 109, 3, 9, '京D22222', '红色', '特斯拉Model 3', '2026-05-10 10:00:00', NULL, 120, NULL, 5.00, 0.00, 0.00, NULL, 'UNPAID', NULL, NULL, 0, '主入口', NULL, 'UNDERGROUND', '充电停车', NOW(), NOW()),
(5, 107, 1, 5, '京A12345', '白色', '丰田凯美瑞', '2026-05-08 09:00:00', '2026-05-08 17:30:00', 480, 510, 8.00, 64.00, 10.00, 'CARD', 'PAID', '2026-05-08 17:31:00', 'CARD202605081731009999', 1, '南门入口', '南门出口', 'UNDERGROUND', 'VIP车位', NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;

/*
 ============================================================================
 停车服务模块说明:

 表1 - parking_lot (停车场信息表):
   存储3个示例停车场，包括协和医院门诊楼地下停车场(500个车位)、外科楼停车场(200个车位)、朝阳医院立体车库(350个车位)
   支持GPS定位、收费规则配置、充电桩和VIP区域标记

 表2 - parking_space (车位信息表):
   存储10个示例车位，涵盖5种类型(VIP/普通/充电桩/无障碍/紧凑型)
   包含详细的位置信息(楼层、区域)、尺寸、距离电梯/出口距离
   充电桩车位还标注了功率(120kW/180kW)

 表3 - parking_record (停车记录表):
   存储5条示例记录，展示完整生命周期:
     - 已完成支付的正常停车(用户107)
     - 正在进行中的停车(用户108)
     - 匿名快速停车(急诊场景)
     - 电动汽车充电停车
     - VIP车位历史记录
   支持多种支付方式(微信/支付宝/银行卡)
   记录找车导航使用情况
*/
