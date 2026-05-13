/*
 Navicat Premium Dump SQL

 Source Server         : lfz
 Source Server Type    : MySQL
 Source Server Version : 80045 (8.0.45)
 Source Host           : localhost:3306
 Source Schema         : medical_health

 Target Server Type    : MySQL
 Target Server Version : 80045 (8.0.45)
 File Encoding         : 65001

 Date: 13/05/2026 09:34:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for family_member
-- ----------------------------
DROP TABLE IF EXISTS `family_member`;
CREATE TABLE `family_member`  (
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
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录密码（BCrypt加密）',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '登录用户名（可选）',
  `login_enabled` tinyint(1) NULL DEFAULT 0 COMMENT '是否允许登录：0-否，1-是',
  `login_fail_count` int NULL DEFAULT 0 COMMENT '登录失败次数',
  `lock_until` datetime NULL DEFAULT NULL COMMENT '账号锁定截止时间',
  `last_login_time` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_relation`(`relation` ASC) USING BTREE,
  INDEX `idx_phone`(`phone` ASC) USING BTREE,
  INDEX `idx_login_enabled`(`login_enabled` ASC) USING BTREE,
  CONSTRAINT `fk_family_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 51 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '家属信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of family_member
-- ----------------------------
INSERT INTO `family_member` VALUES (1, 1, '王秀英', '配偶', '13912345001', '440102197601012365', 2, 52, '北京市朝阳区建国路88号', 1, '身体健康，无慢性病', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', NULL, 1, 0, NULL, '2026-05-13 01:33:08', '2026-05-06 15:39:17', '2026-05-08 08:42:26', 0);
INSERT INTO `family_member` VALUES (2, 1, '王明', '子女', '13712345002', '440102200001012366', 1, 26, '北京市海淀区中关村大街1号', 0, '良好', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', NULL, 0, 0, NULL, NULL, '2026-05-06 15:39:17', '2026-05-08 08:42:24', 0);
INSERT INTO `family_member` VALUES (3, 1, '王建国（父亲）', '父母', NULL, '440102195001012367', 1, 76, '北京市朝阳区建国路88号', 0, '高血压、糖尿病，需定期复查', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', NULL, 0, 0, NULL, NULL, '2026-05-06 15:39:17', '2026-05-08 08:42:24', 0);
INSERT INTO `family_member` VALUES (4, 2, '李强', '配偶', '13812345003', '110101197802023456', 1, 48, '北京市西城区金融街15号', 1, '健康', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', NULL, 1, 0, NULL, NULL, '2026-05-06 15:39:17', '2026-05-08 08:42:26', 0);
INSERT INTO `family_member` VALUES (5, 2, '李小雨', '子女', '13612345004', '110101200103023457', 2, 25, '北京市东城区王府井大街18号', 0, '良好', '$2a$10$drI53FwlB2.tdaOYC4MkCOKlAW4PiYG0qLn.S7LoiJq07QcJpZEV.', NULL, 0, 0, NULL, NULL, '2026-05-06 15:39:17', '2026-05-08 08:42:24', 0);
INSERT INTO `family_member` VALUES (6, 24, '王秀英', '配偶', '13912345001', '440102197601012365', 2, 52, '北京市朝阳区建国路88号', 1, '身体健康，无慢性病', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_wangxy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (7, 25, '李明', '子女', '13712345002', '440102200001012366', 1, 26, '北京市海淀区中关村大街1', 0, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_liming', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (8, 25, '王建国（父亲）', '父母', NULL, '440102195001012367', 1, 76, '北京市朝阳区建国路88号', 0, '高血压、糖尿病', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_wangjg', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (9, 26, '李强', '配偶', '13812345003', '110101197802023456', 1, 48, '北京市西城区金融街15号', 1, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_liqiang', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (10, 26, '李小雨', '子女', '13612345004', '110101200103023457', 2, 25, '北京市东城区王府井大街1', 0, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_lxy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (11, 27, '张淑芬', '配偶', '13512345005', '110105196805154321', 2, 58, '北京市丰台区南三环西路16号', 1, '轻度高血压', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhangsf', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (12, 27, '张伟（儿子）', '子女', '13412345006', '110105199005154322', 1, 36, '北京市海淀区五道口', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhangw', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (13, 28, '刘美兰', '配偶', '13312345007', '110107197203214567', 2, 54, '北京市石景山区石景山路31号', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_liuml', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (14, 29, '赵德明', '配偶', '13212345008', '110108197906124567', 1, 47, '北京市门头沟区新桥大街', 1, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhaodm', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (15, 29, '赵丽华（姐姐）', '兄弟姐妹', '13112345009', '110108197506124568', 2, 51, '北京市房山区良乡', 0, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhaolh', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (16, 30, '陈桂芳', '配偶', '13012345010', '110109198007234567', 2, 46, '北京市通州区新华大街', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_chengf', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (17, 30, '陈志强（弟弟）', ' siblings', '13912345011', '110109198307234568', 1, 43, '北京市顺义区胜利街道', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_chenzq', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (18, 31, '周玉梅', '配偶', '13812345012', '110111196912314567', 2, 57, '北京市昌平区回龙观', 1, '糖尿病前期', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhouym', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (19, 32, '吴国强', '配偶', '13712345013', '110112197604154321', 1, 50, '大兴区黄村镇兴华大街', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_wugq', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (20, 32, '吴婷婷（女儿）', '子女', '13612345014', '110112200004154322', 2, 26, '北京市朝阳区望京', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_wutt', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (21, 33, '孙志国', '配偶', '13512345015', '110113197808214567', 1, 48, '怀柔区迎宾路', 1, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_sunzg', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (22, 34, '郑秀琴', '配偶', '13412345016', '110114197103124567', 2, 55, '平谷区建设街', 1, '轻度高血脂', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_zhengxq', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (23, 35, '冯文涛', '子女', '13312345017', '110115199205234567', 1, 34, '密云区鼓楼大街', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_fengwt', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (24, 35, '冯丽娟（妹妹）', '兄弟姐妹', '13212345018', '110115199505234568', 2, 31, '北京市西城区什刹海', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_fenglj', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (25, 36, '廖桂芳', '配偶', '13012345019', '110116198010314567', 2, 46, '延庆区高塔街', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family liaogf', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (26, 37, '郭建军', '父母', '13912345020', '110117195512054321', 1, 71, '北京市东城区东直门', 1, '冠心病、高血压', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_guo jj', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (27, 37, '郭雪梅（女儿）', '子女', '13812345021', '110117198512054322', 2, 41, '北京市海淀区中关村', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_guoxm', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (28, 38, '韩美华', '配偶', '13712345022', '110118197707214567', 2, 49, '北京市朝阳区三里屯', 1, '良好', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_hanmh', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (29, 39, '唐国栋', '配偶', '13612345023', '440301197408124567', 1, 52, '深圳市福田区深南大道', 1, '痛风', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_tanggd', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (30, 39, '唐欣怡（女儿）', '子女', '13512345024', '440301200008124568', 2, 26, '深圳市南山区科技园', 0, '健康', '$2a$10$P4Rish76HxsAWYZh91R3wuHsOx9UYkgxyF208CYYJk85O3gdANJ7u', 'family_tangxy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (31, 40, '曹丽萍', '配偶', '13412345025', '440303196911154321', 2, 57, '深圳市罗湖区人民南路', 1, '甲状腺结节', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_caolp', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (32, 41, '郝明亮', '子女', '13312345026', '440305199203234567', 1, 34, '深圳市宝安区新安街道', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_haoml', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (33, 42, '董秀英', '配偶', '13212345027', '440306197805314567', 2, 48, '深圳市龙岗区中心城', 1, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_dongxy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (34, 43, '白志强', '父母', '13012345028', '440307195302054321', 1, 73, '深圳市盐田区沙头角', 1, '高血压、白内障', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_baizq', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (35, 44, '崔雪梅', '配偶', '13912345029', '440308198106124567', 2, 45, '深圳市龙华区民治大道', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_cuixm', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (36, 45, '康建国', '配偶', '13812345030', '440309197212214567', 1, 54, '深圳市坪山区坪山大道', 1, '糖尿病', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_kang jg', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (37, 46, '丁丽华', '子女', '13712345031', '440310199412314567', 2, 32, '深圳市光明区公明街道', 1, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_dinglh', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (38, 47, '范德明', '配偶', '13612345032', '440103197603154321', 1, 50, '广州市越秀区中山路', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_fandm', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (39, 48, '彭秀芬', '配偶', '13512345033', '440104196810214567', 2, 58, '广州市海珠区江南大道', 1, '类风湿关节炎', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_pengxf', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (40, 48, '彭浩然（儿子）', '子女', '13412345034', '440104199510214568', 1, 31, '广州市天河区珠江新城', 0, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_penghr', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (41, 49, '鲁国强', '父母', '13312345035', '440105195408054321', 1, 72, '广州市荔湾区上下九', 1, '慢阻肺、高血压', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_lugq', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (42, 50, '韦丽娟', '配偶', '13212345036', '440106197909124567', 2, 47, '广州市白云区白云大道', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_weilj', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (43, 51, '昌志远', '配偶', '13012345037', '440111197511234567', 1, 51, '广州市番禺区市桥', 1, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_changzy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (44, 52, '马桂花', '配偶', '13912345038', '440112197002154321', 2, 56, '广州市花都区新华镇', 1, '骨质疏松', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_magh', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (45, 53, '苗伟强', '子女', '13812345039', '440113199201314567', 1, 34, '广州市南沙区南沙街道', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_miaowq', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (46, 54, '凤丽霞', '配偶', '13712345040', '440114197812214567', 2, 48, '广州市从化区街口镇', 1, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_fenglx', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (47, 55, '花建国', '父母', '13612345041', '440115195601054321', 1, 70, '广州市增城区荔城街道', 1, '帕金森、高血压', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_hua jg', 0, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (48, 56, '方秀英', '配偶', '13512345042', '440201197403124567', 2, 52, '上海市黄浦区南京东路', 1, '良好', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_fangxy', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (49, 57, '俞志明', '配偶', '13412345043', '440202197104154321', 1, 55, '上海市徐汇区徐家汇', 1, '痛风、高尿酸', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_yuzm', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);
INSERT INTO `family_member` VALUES (50, 58, '任丽华', '子女', '13312345044', '440203199305214567', 2, 33, '上海市静安区南京西路', 1, '健康', '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv', 'family_renlh', 1, 0, NULL, NULL, '2026-05-13 09:30:48', '2026-05-13 09:30:48', 0);

SET FOREIGN_KEY_CHECKS = 1;
