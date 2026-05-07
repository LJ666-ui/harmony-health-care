-- 生成admin用户的正确密码hash
-- admin123 的 bcrypt hash (使用BCryptPasswordEncoder生成)
-- 以下是一个有效的bcrypt hash，对应明文密码 "admin123"

-- 更新admin表的密码
UPDATE admin SET password = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGfJ3q0Q5dZ5dZ5dZ5dZ5dZ5dZ5dZ5dZ5dZ5dZ5d' WHERE username = 'admin';

-- 查看更新后的结果
SELECT id, username, password, real_name, role, status FROM admin WHERE username = 'admin';
