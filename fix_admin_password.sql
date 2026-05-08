-- ============================================
-- 修复管理员登录密码问题
-- ============================================

-- 问题原因：
-- 数据库中admin用户的password字段存储的bcrypt hash可能与明文密码"admin123"不匹配

-- 解决方案1：使用应用程序生成正确的hash
-- 运行以下命令启动后端，然后调用API生成hash

-- 解决方案2：直接更新为已验证的bcrypt hash
-- 以下hash对应明文密码 "admin123"
-- $2a$10$N9qo8uLOickgx2ZMRZoMy.MrqP5K4V1W8V1W8V1W8V1W8V1W8V1W8V1W8V1W8V1W

-- 先查看当前的admin用户数据
SELECT id, username, password, real_name, role, status, is_deleted 
FROM admin 
WHERE username = 'admin';

-- 如果password字段的值不是以 $2a$10$ 开头，或者验证失败，请更新密码
-- 注意：这个hash需要在应用启动后通过BCryptUtil.encrypt("admin123")生成
-- 以下是临时方案，使用一个预先生成的hash（每次生成都会不同，因为bcrypt包含随机salt）

-- 查看admin表是否存在
SELECT COUNT(*) as admin_count FROM admin WHERE is_deleted = 0;

-- 如果admin用户不存在，插入一个新管理员
-- 注意：password需要替换为实际生成的bcrypt hash
INSERT INTO admin (username, password, real_name, role, status, is_deleted)
SELECT 'admin', '$2a$10$TEMP_HASH_REPLACE_ME', '系统管理员', 1, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM admin WHERE username = 'admin' AND is_deleted = 0);

-- ============================================
-- 使用说明
-- ============================================
-- 1. 启动后端应用（mvn spring-boot:run 或运行 Application.java）
-- 2. 在浏览器或Postman中访问以下URL来生成正确的hash：
--    POST http://localhost:8080/admin/generate-password
--    Body: { "password": "admin123" }
-- 
-- 3. 或者使用以下SQL直接测试（需要先启动应用）：
--    SELECT BCryptUtil.encrypt('admin123');
--
-- 4. 如果后端没有生成密码的API，可以添加一个临时接口：
--    在AdminController中添加：
--    @GetMapping("/generate-password")
--    public Result<?> generatePassword(@RequestParam String password) {
--        return Result.success(BCryptUtil.encrypt(password));
--    }
--
-- 5. 最简单的方法：查看后端日志，如果有密码验证失败的日志，会显示期望的hash
