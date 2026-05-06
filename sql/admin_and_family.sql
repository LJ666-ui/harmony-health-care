-- ============================================================
-- 医疗健康管理系统 - 管理员后台 & 家属表（精简版）
-- 生成时间：2026-05-06
-- 说明：仅2张表，简洁实用
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 管理员表 (admin)
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '管理员ID，主键自增',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录用户名，唯一',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录密码（加密存储）',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `role` tinyint NOT NULL DEFAULT 1 COMMENT '角色：1=超级管理员 2=普通管理员',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态：0=禁用 1=启用',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最后登录IP',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- 2. 家属表 (family_member)
-- ----------------------------
DROP TABLE IF EXISTS `family_member`;
CREATE TABLE `family_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '家属ID，主键自增',
  `user_id` bigint NOT NULL COMMENT '用户ID（关联user表）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '家属姓名',
  `relation` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '与用户关系：配偶/子女/父母/兄弟姐妹/其他',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `id_card` varchar(18) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '身份证号',
  `gender` tinyint NULL DEFAULT NULL COMMENT '性别：0=未知 1=男 2=女',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '居住地址',
  `is_emergency_contact` tinyint NOT NULL DEFAULT 0 COMMENT '是否紧急联系人：0=否 1=是',
  `health_condition` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '健康状况备注',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_relation`(`relation` ASC) USING BTREE,
  CONSTRAINT `fk_family_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT = '家属信息表' ROW_FORMAT = DYNAMIC;

-- ============================================================
-- 初始化数据
-- ============================================================

-- ----------------------------
-- 插入默认管理员账号
-- 密码：admin123
-- ----------------------------
INSERT INTO `admin` (`username`, `password`, `real_name`, `phone`, `email`, `role`, `status`, `create_time`) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E', '超级管理员', '13800000000', 'admin@medical.com', 1, 1, NOW()),
('admin2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5E', '普通管理员', '13900000000', 'admin2@medical.com', 2, 1, NOW());

-- ----------------------------
-- 插入示例家属数据
-- ----------------------------
INSERT INTO `family_member` (`user_id`, `name`, `relation`, `phone`, `id_card`, `gender`, `age`, `address`, `is_emergency_contact`, `health_condition`) VALUES
(1, '王秀英', '配偶', '13912345001', '440102197601012365', 2, 52, '北京市朝阳区建国路88号', 1, '身体健康，无慢性病'),
(1, '王明', '子女', '13712345002', '440102200001012366', 1, 26, '北京市海淀区中关村大街1号', 0, '良好'),
(1, '王建国（父亲）', '父母', NULL, '440102195001012367', 1, 76, '北京市朝阳区建国路88号', 0, '高血压、糖尿病，需定期复查'),
(2, '李强', '配偶', '13812345003', '110101197802023456', 1, 48, '北京市西城区金融街15号', 1, '健康'),
(2, '李小雨', '子女', '13612345004', '110101200103023457', 2, 25, '北京市东城区王府井大街18号', 0, '良好');

SET FOREIGN_KEY_CHECKS = 1;
