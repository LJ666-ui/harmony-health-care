-- ============================================================
-- 护士登录快速修复（简化版）
-- 直接复制执行即可
-- ============================================================

-- ✅ 步骤1：重置密码（已成功，可跳过）
UPDATE `user` 
SET password = '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv'
WHERE phone = '13800138001' AND user_type IN (2, 3);

-- ✅ 步骤2：验证密码是否正确
SELECT 
    id,
    real_name AS 姓名,
    phone AS 手机号,
    user_type AS 用户类型,
    CASE WHEN password = '$2a$10$N9qo8uLOickg2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWyv' 
        THEN '✓ 密码正确(123456)' 
        ELSE '✗ 密码错误' 
    END AS 密码状态,
    status AS 状态,
    is_deleted AS 是否删除
FROM `user` 
WHERE phone = '13800138001';

-- ✅ 步骤3：验证护士账号（修复后）
SELECT 
    n.id AS 护士ID,
    n.user_id AS 关联用户ID,
    n.nurse_no AS 工号,
    u.real_name AS 真实姓名,
    u.phone AS 手机号,
    n.department AS 科室,
    n.status AS 护士状态,
    u.status AS 用户状态,
    CASE 
        WHEN n.user_id = u.id AND n.is_deleted = 0 AND u.is_deleted = 0 AND n.status = 1
        THEN '✅ 账号正常可登录'
        ELSE '❌ 账号异常不可用'
    END AS 验证结果
FROM nurse n
INNER JOIN user u ON n.user_id = u.id
WHERE u.phone = '13800138001';

-- ============================================================
-- 执行完成后：
-- 1. 重启后端服务（如果正在运行）
-- 2. 重新运行前端应用
-- 3. 使用以下账号登录测试：
--    手机号: 13800138001
--    密码:   123456
-- ============================================================
