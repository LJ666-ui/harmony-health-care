-- 医学影像AI识别功能 - 示例测试数据初始化脚本
-- 创建日期: 2026-05-09
-- 说明: 插入示例影像数据，用于功能测试和演示

-- 开始事务
START TRANSACTION;

-- 清空已有示例数据（避免重复插入）
DELETE FROM image_metadata WHERE image_id LIKE 'SAMPLE-%';

-- ============================================
-- 1. 胸部X光示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-CHEST-XRAY-001',
    0,
    'CHEST_XRAY',
    'JPG',
    2048000,
    1024000,
    '/resources/rawfile/medical-images/chest-xray/sample1.jpg',
    '/resources/rawfile/medical-images/chest-xray/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-CHEST-XRAY-002',
    0,
    'CHEST_XRAY',
    'JPG',
    2560000,
    1280000,
    '/resources/rawfile/medical-images/chest-xray/sample2.jpg',
    '/resources/rawfile/medical-images/chest-xray/sample2.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 2. 骨骼X光示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-BONE-XRAY-001',
    0,
    'BONE_XRAY',
    'JPG',
    1536000,
    768000,
    '/resources/rawfile/medical-images/bone-xray/sample1.jpg',
    '/resources/rawfile/medical-images/bone-xray/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 3. 皮肤照片示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-SKIN-PHOTO-001',
    0,
    'SKIN_PHOTO',
    'JPG',
    1024000,
    512000,
    '/resources/rawfile/medical-images/skin-photo/sample1.jpg',
    '/resources/rawfile/medical-images/skin-photo/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-SKIN-PHOTO-002',
    0,
    'SKIN_PHOTO',
    'PNG',
    1280000,
    640000,
    '/resources/rawfile/medical-images/skin-photo/sample2.png',
    '/resources/rawfile/medical-images/skin-photo/sample2.png',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 4. 眼底照片示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-FUNDUS-PHOTO-001',
    0,
    'FUNDUS_PHOTO',
    'JPG',
    1792000,
    896000,
    '/resources/rawfile/medical-images/fundus-photo/sample1.jpg',
    '/resources/rawfile/medical-images/fundus-photo/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 5. 乳腺超声示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-BREAST-ULTRASOUND-001',
    0,
    'BREAST_ULTRASOUND',
    'JPG',
    2304000,
    1152000,
    '/resources/rawfile/medical-images/breast-ultrasound/sample1.jpg',
    '/resources/rawfile/medical-images/breast-ultrasound/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 6. 其他类型示例图片
-- ============================================
INSERT INTO `image_metadata` (
    `image_id`,
    `user_id`,
    `image_type`,
    `original_format`,
    `original_size`,
    `compressed_size`,
    `storage_url`,
    `preview_url`,
    `upload_time`,
    `status`,
    `created_at`,
    `updated_at`
) VALUES (
    'SAMPLE-OTHER-001',
    0,
    'OTHER',
    'JPG',
    1536000,
    768000,
    '/resources/rawfile/medical-images/other/sample1.jpg',
    '/resources/rawfile/medical-images/other/sample1.jpg',
    NOW(),
    'UPLOADED',
    NOW(),
    NOW()
);

-- ============================================
-- 记录审计日志
-- ============================================
INSERT INTO `operation_audit_log` (
    `user_id`,
    `operation_type`,
    `resource_type`,
    `resource_id`,
    `operation_detail`,
    `operation_time`,
    `created_at`
) VALUES (
    0,
    'SAMPLE_DATA_INIT',
    'IMAGE_METADATA',
    'ALL',
    '{"message": "Sample medical images initialized successfully", "count": 8}',
    NOW(),
    NOW()
);

-- 提交事务
COMMIT;

-- 查询插入结果
SELECT 
    image_id,
    image_type,
    original_format,
    original_size,
    compressed_size,
    storage_url
FROM image_metadata 
WHERE image_id LIKE 'SAMPLE-%'
ORDER BY image_type, image_id;

SELECT '示例测试数据初始化完成！共插入 8 条示例影像数据。' AS result;
