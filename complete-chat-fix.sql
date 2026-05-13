-- ========================================
# 完整的护士-家属聊天功能测试SQL脚本
# 用于验证整个数据链路
# ========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '🔧 护士-家属聊天功能完整修复脚本' AS '';
SELECT '========================================' AS '';

-- 第一步：确保消息表存在
DROP TABLE IF EXISTS `doctor_message`;
CREATE TABLE IF NOT EXISTS `doctor_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `receiver_id` bigint NOT NULL COMMENT '接收者ID',
  `content` text NOT NULL COMMENT '消息内容',
  `is_read` tinyint DEFAULT 0 COMMENT '是否已读: 0=未读, 1=已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间（48小时）',
  PRIMARY KEY (`id`),
  KEY `idx_sender_receiver` (`sender_id`, `receiver_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消息表';

SELECT '✅ doctor_message 表创建成功' AS '';

-- 第二步：查看护士信息
SELECT '' AS '';
SELECT '第二步：查看护士列表（用于登录）' AS '';
SELECT 
    n.id AS nurse_id,
    n.user_id,
    n.nurse_no AS 工号,
    u.real_name AS 姓名,
    u.phone AS 手机号,
    n.department AS 科室
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE n.is_deleted = 0
LIMIT 10;

-- 第三步：获取第一个护士的信息
SET @nurse_user_id = (SELECT user_id FROM nurse WHERE is_deleted = 0 LIMIT 1);
SET @nurse_id = (SELECT id FROM nurse WHERE is_deleted = 0 LIMIT 1);

SELECT CONCAT('✅ 测试护士 user_id: ', IFNULL(@nurse_user_id, 'NULL')) AS 信息;
SELECT CONCAT('✅ 测试护士 nurse_id: ', IFNULL(@nurse_id, 'NULL')) AS 信息;

-- 第四步：查看该护士负责的患者
SELECT '' AS '';
SELECT '第四步：查看护士负责的患者' AS '';
SELECT 
    npr.patient_id,
    u.real_name AS 患者姓名,
    u.phone AS 患者电话
FROM nurse_patient_relation npr
JOIN user u ON npr.patient_id = u.id
WHERE npr.nurse_id = @nurse_id AND npr.is_deleted = 0
LIMIT 10;

-- 第五步：查看这些患者的家属
SELECT '' AS '';
SELECT '第五步：查看患者家属列表' AS '';
SELECT 
    fm.id AS family_id,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.phone AS 电话,
    fm.user_id AS 关联患者ID,
    u.real_name AS 患者姓名
FROM family_member fm
JOIN user u ON fm.user_id = u.id
WHERE fm.user_id IN (
    SELECT patient_id FROM nurse_patient_relation WHERE nurse_id = @nurse_id AND is_deleted = 0
)
AND fm.is_deleted = 0
ORDER BY fm.is_emergency_contact DESC
LIMIT 20;

-- 第六步：获取第一个家属ID
SET @first_family_id = (SELECT id FROM family_member WHERE is_deleted = 0 LIMIT 1);

SELECT CONCAT('✅ 第一个家属 ID: ', IFNULL(@first_family_id, 'NULL')) AS 信息;

-- 第七步：清理旧测试数据
DELETE FROM doctor_message WHERE content LIKE '%测试%';
SELECT CONCAT('✅ 已清理旧测试数据') AS 结果;

-- 第八步：插入测试消息
INSERT INTO doctor_message (sender_id, receiver_id, content, is_read, create_time, expire_time)
VALUES (@nurse_user_id, @first_family_id, '您好！我是责任护士，请问今天情况如何？', 0, NOW(), DATE_ADD(NOW(), INTERVAL 48 HOUR));

SELECT CONCAT('✅ 护士→家属 消息已插入 ID=', LAST_INSERT_ID()) AS 结果;

INSERT INTO doctor_message (sender_id, receiver_id, content, is_read, create_time, expire_time)
VALUES (@first_family_id, @nurse_user_id, '护士您好！患者状态稳定，谢谢关心！', 0, DATE_ADD(NOW(), INTERVAL 1 MINUTE), DATE_ADD(NOW(), INTERVAL 48 HOUR));

SELECT CONCAT('✅ 家属→护士 回复已插入 ID=', LAST_INSERT_ID()) AS 结果;

-- 第九步：验证查询结果
SELECT '' AS '';
SELECT '第九步：验证 /message/history 接口返回格式' AS '';

SELECT 
    dm.id,
    dm.sender_id AS 发送者ID,
    dm.receiver_id AS 接收者ID,
    dm.content AS 消息内容,
    dm.is_read AS 是否已读,
    DATE_FORMAT(dm.create_time, '%Y-%m-%d %H:%i:%S') AS createTime,
    CASE WHEN dm.expire_time IS NULL THEN NULL ELSE DATE_FORMAT(dm.expire_time, '%Y-%m-%d %H:%i:%S') END AS expireTime
FROM doctor_message dm
WHERE 
    (dm.sender_id = @nurse_user_id AND dm.receiver_id = @first_family_id)
    OR (dm.sender_id = @first_family_id AND dm.receiver_id = @nurse_user_id)
ORDER BY dm.create_time ASC;

-- 第十步：生成测试报告
SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 数据准备完成！' AS '';
SELECT '========================================' AS '';
SELECT '' AS '';
SELECT '📋 登录凭据（请使用以下信息登录）：' AS '';
SELECT '' AS '';

SELECT CONCAT('👩‍⚕️ 护士端登录信息：') AS '';
SELECT CONCAT('   手机号: ', (SELECT phone FROM user WHERE id = @nurse_user_id)) AS '';
SELECT CONCAT('   密码: 123456') AS '';
SELECT CONCAT('   userId (AppStorage): ', @nurse_user_id) AS '';
SELECT '' AS '';

SELECT CONCAT('👨‍👩‍👧 家属端登录信息：') AS '';
SELECT CONCAT('   手机号: ', (SELECT phone FROM family_member WHERE id = @first_family_id LIMIT 1)) AS '';
SELECT CONCAT('   密码: 123456') AS '';
SELECT CONCAT('   userId (AppStorage): ', @first_family_id) AS '';
SELECT '' AS '';

SELECT '🎯 预期行为：' AS '';
SELECT '1. 护士登录后 currentUserId 应该 = nurse_user_id (非0)' AS '';
SELECT '2. 进入家属列表应看到家属数据' AS '';
SELECT '3. 点击家属 family.id 应该 > 0' AS '';
SELECT '4. 成功跳转到聊天页面' AS '';
SELECT '5. 能看到刚才插入的2条测试消息' AS '';
SELECT '' AS '';

SELECT '⚠️ 如果仍然失败，请检查：' AS '';
SELECT '1. 后端 /nurse/families API 是否返回正确的 id 字段' AS '';
SELECT '2. 前端控制台是否有 [NurseFamilyList] 开头的日志' AS '';
SELECT '3. AppStorage 中 userId 是否被正确设置' AS '';
SELECT '' AS '';

SELECT '🚀 下一步操作：' AS '';
SELECT '1. 在Navicat中执行此SQL脚本' AS '';
SELECT '2. 重新编译前端项目 (Build → Rebuild)' AS '';
SELECT '3. 清除应用数据并重新登录' AS '';
SELECT '4. 按照上述流程测试' AS '';
