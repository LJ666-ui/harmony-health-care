package com.example.medical.util;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * 数据库结构验证工具
 * 用于检查表结构是否符合代码期望
 */
@Component
public class DatabaseStructureValidator {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 验证article_comment表结构
     */
    public boolean validateArticleCommentTable() {
        System.out.println("========== 验证 article_comment 表结构 ==========");
        
        try {
            // 检查表是否存在
            List<Map<String, Object>> tables = jdbcTemplate.queryForList(
                "SHOW TABLES LIKE 'article_comment'"
            );
            
            if (tables.isEmpty()) {
                System.err.println("❌ 错误: article_comment 表不存在！");
                return false;
            }
            
            System.out.println("✅ article_comment 表存在");
            
            // 检查字段
            List<Map<String, Object>> columns = jdbcTemplate.queryForList(
                "SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE " +
                "FROM INFORMATION_SCHEMA.COLUMNS " +
                "WHERE TABLE_SCHEMA = DATABASE() " +
                "AND TABLE_NAME = 'article_comment' " +
                "ORDER BY ORDINAL_POSITION"
            );
            
            System.out.println("\n当前表结构:");
            boolean hasUserId = false;
            for (Map<String, Object> col : columns) {
                String colName = (String) col.get("COLUMN_NAME");
                String colType = (String) col.get("COLUMN_TYPE");
                System.out.println("  - " + colName + " (" + colType + ")");
                
                if ("user_id".equals(colName)) {
                    hasUserId = true;
                }
            }
            
            if (!hasUserId) {
                System.err.println("\n❌ 错误: 缺少 user_id 字段！");
                System.out.println("\n请执行以下SQL修复:");
                System.out.println("ALTER TABLE `article_comment` " +
                    "ADD COLUMN `user_id` bigint NOT NULL COMMENT '用户ID' AFTER `id`;");
                return false;
            }
            
            System.out.println("\n✅ user_id 字段存在");
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ 验证失败: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 验证article_collect表结构
     */
    public boolean validateArticleCollectTable() {
        System.out.println("\n========== 验证 article_collect 表结构 ==========");
        
        try {
            List<Map<String, Object>> tables = jdbcTemplate.queryForList(
                "SHOW TABLES LIKE 'article_collect'"
            );
            
            if (tables.isEmpty()) {
                System.err.println("❌ 错误: article_collect 表不存在！");
                return false;
            }
            
            System.out.println("✅ article_collect 表存在");
            return true;
            
        } catch (Exception e) {
            System.err.println("❌ 验证失败: " + e.getMessage());
            return false;
        }
    }

    /**
     * 执行全部验证
     */
    public void validateAll() {
        System.out.println("\n========================================");
        System.out.println("开始数据库结构验证");
        System.out.println("========================================\n");
        
        boolean commentValid = validateArticleCommentTable();
        boolean collectValid = validateArticleCollectTable();
        
        System.out.println("\n========================================");
        if (commentValid && collectValid) {
            System.out.println("✅ 数据库结构验证通过");
        } else {
            System.out.println("❌ 数据库结构验证失败，请修复后重启服务");
        }
        System.out.println("========================================\n");
    }
}
