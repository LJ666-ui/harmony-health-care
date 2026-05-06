# 数据库修复指南

## 问题描述

根据错误日志分析，后端报错：
```
Unknown column 'user_id' in 'field list'
```

这表明数据库表结构与代码期望的字段不一致。

## 原因分析

虽然SQL定义文件 `sql/medical_health.sql` 中已经正确包含了 `user_id` 字段，但实际数据库可能：

1. **使用了旧版本的数据库结构**，未执行最新的建表SQL
2. **数据库迁移未完成**，字段未同步
3. **开发环境数据库与SQL文件不同步**

## 解决方案

### 方案一：重新创建表（推荐用于开发环境）

**警告：此操作会清空表数据！**

```sql
-- 1. 删除旧表
DROP TABLE IF EXISTS `article_comment`;

-- 2. 创建新表（完整结构）
CREATE TABLE `article_comment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父评论ID（0为顶级评论）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态：0删除 1正常',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint NOT NULL DEFAULT 0 COMMENT '逻辑删除：0=未删除 1=已删除',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_article_id`(`article_id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '文章评论表' ROW_FORMAT = DYNAMIC;
```

### 方案二：修复现有表（保留数据）

如果表中已有重要数据，请使用增量修复脚本：

```bash
# 执行修复脚本
mysql -u root -p your_database < sql/fix_article_comment.sql
```

或手动执行：

```sql
-- 添加user_id字段（如果不存在）
ALTER TABLE `article_comment` 
ADD COLUMN IF NOT EXISTS `user_id` bigint NOT NULL COMMENT '用户ID' AFTER `id`;

-- 添加parent_id字段（如果不存在）
ALTER TABLE `article_comment` 
ADD COLUMN IF NOT EXISTS `parent_id` bigint NULL DEFAULT 0 COMMENT '父评论ID（0为顶级评论）' AFTER `article_id`;

-- 添加索引
CREATE INDEX IF NOT EXISTS `idx_user_id` ON `article_comment`(`user_id`);
```

### 方案三：完整数据库初始化

如果这是全新环境，建议执行完整的建表SQL：

```bash
# 1. 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS medical_health DEFAULT CHARACTER SET utf8mb4;"

# 2. 执行完整SQL脚本
mysql -u root -p medical_health < sql/medical_health.sql

# 3. 验证表结构
mysql -u root -p medical_health -e "SHOW COLUMNS FROM article_comment;"
```

## 验证修复

执行以下SQL验证字段是否正确：

```sql
-- 查看表结构
SHOW COLUMNS FROM `article_comment`;

-- 或更详细的查询
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, COLUMN_COMMENT 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'article_comment'
ORDER BY ORDINAL_POSITION;
```

期望结果应包含以下字段：
- id
- user_id ⭐ **必须存在**
- article_id
- parent_id
- content
- like_count
- status
- create_time
- update_time
- is_deleted

## 常见问题

### Q1: 执行ALTER TABLE时报错 "Column already exists"

**答**: 说明字段已存在，无需重复添加。可以跳过该步骤。

### Q2: 执行后仍然报错 "Unknown column 'user_id'"

**答**: 可能原因：
1. 修改了错误的数据库（检查DATABASE()）
2. MyBatis缓存未清理（重启后端服务）
3. 连接的数据库实例不对（检查数据库连接配置）

解决方法：
```sql
-- 1. 确认当前数据库
SELECT DATABASE();

-- 2. 确认表存在
SHOW TABLES LIKE 'article_comment';

-- 3. 确认字段存在
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'article_comment' 
  AND COLUMN_NAME = 'user_id';
```

### Q3: 如何避免此问题？

**答**: 建议：
1. 使用数据库版本管理工具（如Flyway、Liquibase）
2. 每次修改表结构后同步更新SQL文件
3. CI/CD流程中加入数据库结构验证
4. 开发环境使用Docker统一数据库版本

## 执行步骤总结

1. **备份数据库**（重要！）
   ```bash
   mysqldump -u root -p medical_health > backup_$(date +%Y%m%d).sql
   ```

2. **执行修复脚本**
   ```bash
   mysql -u root -p medical_health < sql/fix_all_tables.sql
   ```

3. **验证修复结果**
   ```bash
   mysql -u root -p medical_health -e "SHOW COLUMNS FROM article_comment;"
   ```

4. **重启后端服务**
   - 清理MyBatis缓存
   - 重启Spring Boot应用

5. **测试功能**
   - 测试评论发布
   - 测试文章发布
   - 查看日志确认无报错

## 相关文件

- 完整建表SQL: `sql/medical_health.sql`
- 单表修复脚本: `sql/fix_article_comment.sql`
- 全表修复脚本: `sql/fix_all_tables.sql`
