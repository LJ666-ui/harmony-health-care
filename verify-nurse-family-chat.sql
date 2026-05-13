-- ========================================
# 护士-家属双向聊天功能数据验证和测试脚本
# 验证消息系统是否正常工作
# ========================================

USE medical_health;

SELECT '========================================' AS '';
SELECT '✅ 护士-家属聊天功能验证' AS '';
SELECT '========================================' AS '';

-- 第一步：检查消息表是否存在
SELECT '' AS '';
SELECT '第一步：检查 doctor_message 表结构' AS '';
SHOW TABLES LIKE 'doctor_message';

-- 如果表不存在，创建它
CREATE TABLE IF NOT EXISTS `doctor_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `sender_id` bigint NOT NULL COMMENT '发送者ID',
  `receiver_id` bigint NOT NULL COMMENT '接收者ID',
  `content` text COMMENT '消息内容',
  `is_read` tinyint DEFAULT 0 COMMENT '是否已读: 0=未读, 1=已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `expire_time` datetime DEFAULT NULL COMMENT '过期时间（48小时后过期）',
  PRIMARY KEY (`id`),
  KEY `idx_sender_receiver` (`sender_id`, `receiver_id`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='消息表（支持医生/护士/患者/家属间通信）';

DESCRIBE doctor_message;

-- 第二步：查看当前护士信息
SELECT '' AS '';
SELECT '第二步：查看护士列表' AS '';
SELECT 
    n.id AS nurse_id,
    n.user_id,
    u.real_name AS 护士姓名,
    n.job_number AS 工号
FROM nurse n
LEFT JOIN user u ON n.user_id = u.id
WHERE n.is_deleted = 0
LIMIT 5;

-- 第三步：查看护士负责的患者
SELECT '' AS '';
SELECT '第三步：查看护士1负责的患者' AS '';
SELECT 
    npr.nurse_id,
    npr.patient_id,
    u.real_name AS 患者姓名,
    u.phone AS 患者电话
FROM nurse_patient_relation npr
JOIN user u ON npr.patient_id = u.id
WHERE npr.nurse_id = 1 AND npr.is_deleted = 0
LIMIT 10;

-- 第四步：查看这些患者的家属
SELECT '' AS '';
SELECT '第四步：查看患者的家属列表' AS '';
SELECT 
    fm.id AS family_id,
    fm.name AS 家属姓名,
    fm.relation AS 关系,
    fm.phone AS 电话,
    fm.user_id AS 关联患者ID,
    u.real_name AS 患者姓名,
    CASE fm.is_emergency_contact WHEN 1 THEN '✅ 紧急联系人' ELSE '' END AS 紧急标识
FROM family_member fm
JOIN user u ON fm.user_id = u.id
WHERE fm.user_id IN (
    SELECT patient_id FROM nurse_patient_relation WHERE nurse_id = 1 AND is_deleted = 0
)
AND fm.is_deleted = 0
ORDER BY fm.is_emergency_contact DESC, fm.id
LIMIT 20;

-- 第五步：查看现有消息记录
SELECT '' AS '';
SELECT '第五步：查看 doctor_message 表中的现有消息' AS '';
SELECT COUNT(*) AS 消息总数 FROM doctor_message;

SELECT 
    dm.id,
    dm.sender_id AS 发送者ID,
    dm.receiver_id AS 接收者ID,
    LEFT(dm.content, 50) AS 消息内容预览,
    dm.is_read AS 是否已读,
    dm.create_time AS 发送时间,
    dm.expire_time AS 过期时间
FROM doctor_message dm
ORDER BY dm.create_time DESC
LIMIT 10;

-- 第六步：插入测试消息（模拟护士给家属发消息）
SELECT '' AS '';
SELECT '第六步：插入测试聊天消息' AS '';

-- 获取护士1的user_id和第一个家属的ID
SET @nurse_user_id = (SELECT user_id FROM nurse WHERE id = 1 LIMIT 1);
SET @first_family_id = (SELECT id FROM family_member WHERE is_deleted = 0 LIMIT 1);

SELECT CONCAT('护士user_id: ', IFNULL(@nurse_user_id, 'NULL')) AS 信息;
SELECT CONCAT('第一个家属ID: ', IFNULL(@first_family_id, 'NULL')) AS 信息;

-- 插入测试消息：护士问候家属
INSERT INTO doctor_message (sender_id, receiver_id, content, is_read, create_time, expire_time)
VALUES (
    @nurse_user_id,
    @first_family_id,
    '您好！我是您的责任护士，请问患者今天情况如何？',
    0,
    NOW(),
    DATE_ADD(NOW(), INTERVAL 48 HOUR)
);

SELECT CONCAT('✅ 已插入测试消息 ID=', LAST_INSERT_ID()) AS 结果;

-- 插入测试消息：家属回复护士
INSERT INTO doctor_message (sender_id, receiver_id, content, is_read, create_time, expire_time)
VALUES (
    @first_family_id,
    @nurse_user_id,
    '护士您好！患者今天状态不错，血压正常，谢谢关心！',
    0,
    DATE_ADD(NOW(), INTERVAL 1 MINUTE),
    DATE_ADD(NOW(), INTERVAL 48 HOUR)
);

SELECT CONCAT('✅ 已插入家属回复 ID=', LAST_INSERT_ID()) AS 结果;

-- 第七步：验证查询接口应该返回的数据
SELECT '' AS '';
SELECT '第七步：验证 /message/history 接口返回格式' AS '';

SET @user_a = @nurse_user_id;
SET @user_b = @first_family_id;

SELECT 
    dm.id,
    dm.sender_id,
    dm.receiver_id,
    dm.content,
    dm.is_read,
    DATE_FORMAT(dm.create_time, '%Y-%m-%d %H:%i:%S') AS createTime,
    CASE 
        WHEN dm.expire_time IS NULL THEN NULL
        ELSE DATE_FORMAT(dm.expire_time, '%Y-%m-%d %H:%i:%S')
    END AS expireTime
FROM doctor_message dm
WHERE 
    (dm.sender_id = @user_a AND dm.receiver_id = @user_b)
    OR (dm.sender_id = @user_b AND dm.receiver_id = @user_a)
    AND (dm.expire_time > NOW() OR dm.expire_time IS NULL)
ORDER BY dm.create_time ASC;

-- 第八步：统计信息
SELECT '' AS '';
SELECT '第八步：系统统计信息' AS '';
SELECT 
    (SELECT COUNT(*) FROM nurse WHERE is_deleted = 0) AS 护士总数,
    (SELECT COUNT(*) FROM nurse_patient_relation WHERE is_deleted = 0) AS 护士患者关联数,
    (SELECT COUNT(DISTINCT patient_id) FROM nurse_patient_relation WHERE is_deleted = 0) AS 被管理患者数,
    (SELECT COUNT(*) FROM family_member WHERE is_deleted = 0) AS 家属总数,
    (SELECT COUNT(*) FROM doctor_message) AS 消息总数;

-- 第九步：API端点测试说明
SELECT '' AS '';
SELECT '========================================' AS '';
SELECT '✅ 验证完成！' AS '';
SELECT '========================================' AS '';
SELECT '' AS '';
SELECT '📋 API接口测试方法：' AS '';
SELECT '' AS '';
SELECT '1️⃣ 发送消息（POST）：' AS '';
SELECT '   URL: POST http://localhost:8080/user/message/send' AS '';
SELECT '   Body: {' AS '';
SELECT '     "senderId": <护士user_id>,' AS '';
SELECT '     "receiverId": <家属id>,' AS '';
SELECT '     "content": "您好",' AS '';
SELECT '     "senderType": "nurse",' AS '';
SELECT '     "receiverType": "family"' AS '';
SELECT '   }' AS '';
SELECT '' AS '';
SELECT '2️⃣ 获取历史消息（GET）：' AS '';
SELECT '   URL: GET http://localhost:8080/user/message/history?userA=<护士id>&userB=<家属id>' AS '';
SELECT '' AS '';
SELECT '3️⃣ 检查发送权限（GET）：' AS '';
SELECT '   URL: GET http://localhost:8080/user/message/can-send?senderId=<护士id>&receiverId=<家属id>' AS '';
SELECT '' AS '';
SELECT '🎯 预期结果：' AS '';
SELECT '- canSend 应该返回 true（护士可以主动联系家属）' AS '';
SELECT '- history 应该返回刚插入的2条测试消息' AS '';
SELECT '' AS '';
SELECT '⚠️ 注意事项：' AS '';
SELECT '1. senderId 必须是 user 表中存在的用户ID' AS '';
SELECT '2. receiverId 可以是 user 表或 family_member 表的ID' AS '';
SELECT '3. 消息48小时后自动过期' AS '';
SELECT '4. 前端每3秒轮询一次获取新消息' AS '';
SELECT '' AS '';
SELECT '🚀 下一步操作：' AS '';
SELECT '1. 重启后端服务以加载新代码' AS '';
SELECT '2. 在模拟器中登录护士账号' AS '';
SELECT '3. 进入"家属沟通"功能' AS '';
SELECT '4. 选择一个家属进入聊天' AS '';
SELECT '5. 发送测试消息验证双向通信' AS '';
