-- 药品分类标准化增强功能 - 数据库表创建脚本
-- 创建时间：2026-05-07
-- 说明：创建药品分类字典表、迁移日志表、映射规则表

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 创建药品分类字典表
-- ----------------------------
DROP TABLE IF EXISTS `medicine_categories`;
CREATE TABLE `medicine_categories` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `category_code` varchar(10) NOT NULL COMMENT '分类编码（XX-XX-XX格式）',
  `category_name` varchar(50) NOT NULL COMMENT '分类名称',
  `parent_code` varchar(10) NULL DEFAULT NULL COMMENT '父分类编码',
  `level` tinyint NOT NULL COMMENT '分类层级：1=一级 2=二级 3=三级',
  `display_order` int NULL DEFAULT 0 COMMENT '显示顺序',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=禁用 1=启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_category_code`(`category_code` ASC) USING BTREE,
  INDEX `idx_parent_code`(`parent_code` ASC) USING BTREE,
  INDEX `idx_level`(`level` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '药品分类字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- 插入标准分类初始数据
-- ----------------------------
INSERT INTO `medicine_categories` (`category_code`, `category_name`, `parent_code`, `level`, `display_order`, `status`) VALUES
-- 一级分类
('01', '消化系统用药', NULL, 1, 1, 1),
('02', '抗过敏药物', NULL, 1, 2, 1),
('03', '内分泌系统用药', NULL, 1, 3, 1),
('04', '利尿剂', NULL, 1, 4, 1),
('05', '神经系统用药', NULL, 1, 5, 1),
('06', '心血管系统用药', NULL, 1, 6, 1),
('07', '呼吸系统用药', NULL, 1, 7, 1),
('08', '抗生素/抗感染药物', NULL, 1, 8, 1),
('09', '免疫调节药物', NULL, 1, 9, 1),
('10', '输液及电解质平衡', NULL, 1, 10, 1),
('11', '肝脏疾病用药', NULL, 1, 11, 1),
('12', '镇痛药物', NULL, 1, 12, 1),
('13', '抗真菌药物', NULL, 1, 13, 1),
('14', '眼科用药', NULL, 1, 14, 1),
('15', '抗凝血/抗血小板', NULL, 1, 15, 1),
('16', '耳鼻喉科用药', NULL, 1, 16, 1),
-- 二级分类示例
('01-01', '胃药', '01', 2, 1, 1),
('01-02', '肠道用药', '01', 2, 2, 1),
('03-01', '胰岛素', '03', 2, 1, 1),
('03-02', '降糖药', '03', 2, 2, 1),
('05-01', '抗抑郁药', '05', 2, 1, 1),
('06-01', '降压药', '06', 2, 1, 1),
('06-02', '抗心绞痛药', '06', 2, 2, 1),
('07-01', '平喘药', '07', 2, 1, 1),
('11-01', '保肝药', '11', 2, 1, 1);

-- ----------------------------
-- 2. 创建分类迁移日志表
-- ----------------------------
DROP TABLE IF EXISTS `category_migration_log`;
CREATE TABLE `category_migration_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志ID',
  `batch_no` varchar(30) NOT NULL COMMENT '迁移批次号（MIG+yyyyMMddHHmmss）',
  `old_category_name` varchar(100) NULL DEFAULT NULL COMMENT '原分类名称',
  `new_category_code` varchar(10) NULL DEFAULT NULL COMMENT '新分类编码',
  `medicine_count` int NULL DEFAULT 0 COMMENT '迁移药品数量',
  `status` varchar(20) NOT NULL COMMENT '迁移状态：pending/success/failed/rolled_back',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `remark` text NULL COMMENT '备注信息',
  `is_rolled_back` tinyint NOT NULL DEFAULT 0 COMMENT '是否已回滚：0=否 1=是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_batch_no`(`batch_no` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分类迁移日志表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- 3. 创建分类名称映射规则表
-- ----------------------------
DROP TABLE IF EXISTS `category_name_mapping`;
CREATE TABLE `category_name_mapping` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '映射规则ID',
  `old_name_pattern` varchar(100) NOT NULL COMMENT '原分类名称模式（支持LIKE模糊匹配）',
  `new_category_code` varchar(10) NOT NULL COMMENT '新分类编码',
  `priority` int NULL DEFAULT 0 COMMENT '匹配优先级（数值越大优先级越高）',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=禁用 1=启用',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_old_name`(`old_name_pattern` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分类名称映射规则表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- 插入分类名称映射规则数据
-- ----------------------------
INSERT INTO `category_name_mapping` (`old_name_pattern`, `new_category_code`, `priority`, `status`) VALUES
-- 精确匹配（优先级高）
('消化系统用药（胃）', '01-01', 100, 1),
('消化系统用药（肠道）', '01-02', 100, 1),
('抗过敏药物', '02', 100, 1),
('内分泌系统用药（胰岛素）', '03-01', 100, 1),
('内分泌系统用药（降糖）', '03-02', 100, 1),
('利尿剂', '04', 100, 1),
('神经系统用药（抗抑郁）', '05-01', 100, 1),
('精神神经系统用药', '05', 100, 1),
('心血管系统用药（降压）', '06-01', 100, 1),
('心血管系统用药（抗心绞痛）', '06-02', 100, 1),
('心血管用药（降压药）', '06-01', 100, 1),
('心用药（降压药）', '06-01', 100, 1),
('呼吸系统用药（平喘）', '07-01', 100, 1),
('抗生素/抗感染药物', '08', 100, 1),
('抗生素/抗感染药', '08', 100, 1),
('免疫调节药物', '09', 100, 1),
('免疫调节节药物', '09', 100, 1),
('输液及电解质平衡', '10', 100, 1),
('肝脏疾病用药（保肝）', '11-01', 100, 1),
('镇痛药物', '12', 100, 1),
('抗真菌药物', '13', 100, 1),
('眼科用药', '14', 100, 1),
('抗凝血/抗血小板', '15', 100, 1),
('耳鼻喉科用药', '16', 100, 1),
-- 模糊匹配（优先级低）
('消化系统用药%', '01', 50, 1),
('内分泌系统用药%', '03', 50, 1),
('心血管系统用药%', '06', 50, 1),
('心血管用药%', '06', 50, 1),
('呼吸系统用药%', '07', 50, 1),
('肝脏疾病用药%', '11', 50, 1),
('神经系统用药%', '05', 50, 1);

-- ----------------------------
-- 4. 修改medicine表结构（添加category和category_code字段）
-- ----------------------------
-- 先备份原category字段数据（如果存在）
-- CREATE TABLE IF NOT EXISTS `medicine_category_backup_20260507` AS SELECT id, category FROM `medicine`;

-- 添加category字段（如果不存在）
-- ALTER TABLE `medicine` ADD COLUMN IF NOT EXISTS `category` varchar(50) NOT NULL COMMENT '药品类别' AFTER `name`;

-- 添加category_code字段
ALTER TABLE `medicine` ADD COLUMN IF NOT EXISTS `category_code` varchar(10) NULL COMMENT '分类编码（关联medicine_categories.category_code）' AFTER `category`;

-- 创建索引
CREATE INDEX IF NOT EXISTS `idx_category_code` ON `medicine`(`category_code` ASC);

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- 执行完成提示
-- ----------------------------
SELECT '药品分类表创建完成！' AS message;
