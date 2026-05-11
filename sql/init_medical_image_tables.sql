-- 医学影像AI识别功能 - 数据库初始化脚本
-- 创建日期: 2026-05-09
-- 说明: 创建医学影像诊断相关的5张核心表

-- 1. 影像元数据表
CREATE TABLE IF NOT EXISTS `image_metadata` (
    `image_id` VARCHAR(64) NOT NULL COMMENT '影像唯一标识',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `image_type` VARCHAR(32) NOT NULL COMMENT '影像类型: CHEST_XRAY/BONE_XRAY/SKIN_PHOTO/FUNDUS_PHOTO/BREAST_ULTRASOUND/OTHER',
    `original_format` VARCHAR(16) NOT NULL COMMENT '原始格式: JPG/PNG/DICOM',
    `original_size` BIGINT NOT NULL COMMENT '原始文件大小(字节)',
    `compressed_size` BIGINT NOT NULL COMMENT '压缩后文件大小(字节)',
    `storage_url` VARCHAR(512) NOT NULL COMMENT '对象存储URL',
    `preview_url` VARCHAR(512) COMMENT '预览图URL',
    `upload_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    `status` VARCHAR(16) NOT NULL DEFAULT 'UPLOADED' COMMENT '状态: UPLOADED/ANALYZING/ANALYZED/ERROR',
    `error_message` TEXT COMMENT '错误信息',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`image_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_upload_time` (`upload_time`),
    INDEX `idx_status` (`status`),
    INDEX `idx_user_upload` (`user_id`, `upload_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='影像元数据表';

-- 2. 诊断记录表
CREATE TABLE IF NOT EXISTS `diagnosis_record` (
    `result_id` VARCHAR(64) NOT NULL COMMENT '诊断结果唯一标识',
    `image_id` VARCHAR(64) NOT NULL COMMENT '影像ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `image_type` VARCHAR(32) NOT NULL COMMENT '影像类型',
    `lesion_count` INT NOT NULL DEFAULT 0 COMMENT '病灶数量',
    `overall_confidence` DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '总体置信度(0-100)',
    `analysis_status` VARCHAR(16) NOT NULL DEFAULT 'PENDING' COMMENT '分析状态: PENDING/IN_PROGRESS/COMPLETED/FAILED',
    `analysis_time` DATETIME COMMENT '分析完成时间',
    `analysis_duration` INT COMMENT '分析耗时(毫秒)',
    `ai_engine_version` VARCHAR(32) COMMENT 'AI引擎版本',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`result_id`),
    UNIQUE INDEX `idx_image_id` (`image_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_analysis_status` (`analysis_status`),
    INDEX `idx_analysis_time` (`analysis_time`),
    INDEX `idx_user_analysis` (`user_id`, `analysis_time`),
    FOREIGN KEY (`image_id`) REFERENCES `image_metadata`(`image_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='诊断记录表';

-- 3. 病灶详情表
CREATE TABLE IF NOT EXISTS `lesion_detail` (
    `lesion_id` VARCHAR(64) NOT NULL COMMENT '病灶唯一标识',
    `result_id` VARCHAR(64) NOT NULL COMMENT '诊断结果ID',
    `lesion_type` VARCHAR(64) NOT NULL COMMENT '病灶类型',
    `lesion_name` VARCHAR(128) NOT NULL COMMENT '病灶名称',
    `position_x` DECIMAL(10,2) COMMENT '病灶位置X坐标',
    `position_y` DECIMAL(10,2) COMMENT '病灶位置Y坐标',
    `bounding_box` VARCHAR(256) COMMENT '边界框坐标(JSON格式): {x, y, width, height}',
    `confidence` DECIMAL(5,2) NOT NULL COMMENT '置信度(0-100)',
    `severity` VARCHAR(16) NOT NULL COMMENT '严重程度: CRITICAL/SEVERE/MODERATE/MILD',
    `description` TEXT COMMENT '病灶描述',
    `size_mm` DECIMAL(10,2) COMMENT '病灶大小(毫米)',
    `shape` VARCHAR(64) COMMENT '形态特征',
    `density` VARCHAR(64) COMMENT '密度特征',
    `edge` VARCHAR(64) COMMENT '边缘特征',
    `internal_structure` VARCHAR(128) COMMENT '内部结构特征',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`lesion_id`),
    INDEX `idx_result_id` (`result_id`),
    INDEX `idx_severity` (`severity`),
    INDEX `idx_confidence` (`confidence`),
    FOREIGN KEY (`result_id`) REFERENCES `diagnosis_record`(`result_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='病灶详情表';

-- 4. 诊断建议表
CREATE TABLE IF NOT EXISTS `diagnosis_recommendation` (
    `recommendation_id` BIGINT AUTO_INCREMENT COMMENT '建议ID',
    `result_id` VARCHAR(64) NOT NULL COMMENT '诊断结果ID',
    `lesion_id` VARCHAR(64) COMMENT '病灶ID(可为空,表示整体建议)',
    `recommendation_type` VARCHAR(32) NOT NULL COMMENT '建议类型: DIAGNOSIS/TREATMENT/FOLLOW_UP/REFERRAL',
    `recommendation_text` TEXT NOT NULL COMMENT '建议文本',
    `priority` INT NOT NULL DEFAULT 1 COMMENT '优先级(1-5,数字越小优先级越高)',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`recommendation_id`),
    INDEX `idx_result_id` (`result_id`),
    INDEX `idx_lesion_id` (`lesion_id`),
    INDEX `idx_priority` (`priority`),
    FOREIGN KEY (`result_id`) REFERENCES `diagnosis_record`(`result_id`) ON DELETE CASCADE,
    FOREIGN KEY (`lesion_id`) REFERENCES `lesion_detail`(`lesion_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='诊断建议表';

-- 5. 操作审计日志表
CREATE TABLE IF NOT EXISTS `operation_audit_log` (
    `log_id` BIGINT AUTO_INCREMENT COMMENT '日志ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `operation_type` VARCHAR(32) NOT NULL COMMENT '操作类型: UPLOAD/ANALYZE/VIEW_RESULT/VIEW_LESION/DELETE',
    `resource_type` VARCHAR(32) NOT NULL COMMENT '资源类型: IMAGE/DIAGNOSIS/LESION',
    `resource_id` VARCHAR(64) NOT NULL COMMENT '资源ID',
    `operation_detail` TEXT COMMENT '操作详情(JSON格式)',
    `ip_address` VARCHAR(64) COMMENT 'IP地址',
    `user_agent` VARCHAR(256) COMMENT '用户代理',
    `operation_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`log_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_operation_type` (`operation_type`),
    INDEX `idx_resource` (`resource_type`, `resource_id`),
    INDEX `idx_operation_time` (`operation_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作审计日志表';

-- 插入初始化完成标记
INSERT INTO `operation_audit_log` (`user_id`, `operation_type`, `resource_type`, `resource_id`, `operation_detail`)
VALUES (0, 'SYSTEM_INIT', 'TABLE', 'medical_image_tables', '{"message": "Medical image diagnosis tables initialized successfully"}');

SELECT 'Medical image diagnosis tables initialized successfully!' AS result;
