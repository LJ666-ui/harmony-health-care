ALTER TABLE `doctor` ADD COLUMN `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名' AFTER `user_id`;
