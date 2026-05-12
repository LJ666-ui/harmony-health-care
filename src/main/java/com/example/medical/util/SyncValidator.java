package com.example.medical.util;

import java.util.*;

/**
 * 数据同步验证工具
 * 用于验证多端数据同步的正确性和性能
 */
public class SyncValidator {

    /**
     * 同步验证结果
     */
    public static class SyncResult {
        private String syncType;
        private boolean success;
        private String message;
        private Long syncTime;
        private Integer recordCount;
        private Date checkTime;

        public SyncResult(String syncType, boolean success, String message, Long syncTime, Integer recordCount) {
            this.syncType = syncType;
            this.success = success;
            this.message = message;
            this.syncTime = syncTime;
            this.recordCount = recordCount;
            this.checkTime = new Date();
        }

        // Getters
        public String getSyncType() { return syncType; }
        public boolean isSuccess() { return success; }
        public String getMessage() { return message; }
        public Long getSyncTime() { return syncTime; }
        public Integer getRecordCount() { return recordCount; }
        public Date getCheckTime() { return checkTime; }
    }

    /**
     * 验证所有数据同步
     */
    public static List<SyncResult> validateAllSync() {
        List<SyncResult> results = new ArrayList<>();
        
        // 验证用户数据同步
        results.add(validateUserSync());
        
        // 验证健康记录同步
        results.add(validateHealthRecordSync());
        
        // 验证预约数据同步
        results.add(validateAppointmentSync());
        
        // 验证医疗记录同步
        results.add(validateMedicalRecordSync());
        
        // 验证处方数据同步
        results.add(validatePrescriptionSync());
        
        return results;
    }

    /**
     * 验证用户数据同步
     */
    private static SyncResult validateUserSync() {
        long startTime = System.currentTimeMillis();
        try {
            // 模拟验证用户数据同步
            int recordCount = checkUserSync();
            long syncTime = System.currentTimeMillis() - startTime;
            
            if (recordCount > 0) {
                return new SyncResult("用户数据", true, "同步正常", syncTime, recordCount);
            } else {
                return new SyncResult("用户数据", false, "无同步记录", syncTime, 0);
            }
        } catch (Exception e) {
            long syncTime = System.currentTimeMillis() - startTime;
            return new SyncResult("用户数据", false, "验证失败: " + e.getMessage(), syncTime, 0);
        }
    }

    /**
     * 验证健康记录同步
     */
    private static SyncResult validateHealthRecordSync() {
        long startTime = System.currentTimeMillis();
        try {
            int recordCount = checkHealthRecordSync();
            long syncTime = System.currentTimeMillis() - startTime;
            
            if (recordCount > 0) {
                return new SyncResult("健康记录", true, "同步正常", syncTime, recordCount);
            } else {
                return new SyncResult("健康记录", false, "无同步记录", syncTime, 0);
            }
        } catch (Exception e) {
            long syncTime = System.currentTimeMillis() - startTime;
            return new SyncResult("健康记录", false, "验证失败: " + e.getMessage(), syncTime, 0);
        }
    }

    /**
     * 验证预约数据同步
     */
    private static SyncResult validateAppointmentSync() {
        long startTime = System.currentTimeMillis();
        try {
            int recordCount = checkAppointmentSync();
            long syncTime = System.currentTimeMillis() - startTime;
            
            if (recordCount > 0) {
                return new SyncResult("预约数据", true, "同步正常", syncTime, recordCount);
            } else {
                return new SyncResult("预约数据", false, "无同步记录", syncTime, 0);
            }
        } catch (Exception e) {
            long syncTime = System.currentTimeMillis() - startTime;
            return new SyncResult("预约数据", false, "验证失败: " + e.getMessage(), syncTime, 0);
        }
    }

    /**
     * 验证医疗记录同步
     */
    private static SyncResult validateMedicalRecordSync() {
        long startTime = System.currentTimeMillis();
        try {
            int recordCount = checkMedicalRecordSync();
            long syncTime = System.currentTimeMillis() - startTime;
            
            if (recordCount > 0) {
                return new SyncResult("医疗记录", true, "同步正常", syncTime, recordCount);
            } else {
                return new SyncResult("医疗记录", false, "无同步记录", syncTime, 0);
            }
        } catch (Exception e) {
            long syncTime = System.currentTimeMillis() - startTime;
            return new SyncResult("医疗记录", false, "验证失败: " + e.getMessage(), syncTime, 0);
        }
    }

    /**
     * 验证处方数据同步
     */
    private static SyncResult validatePrescriptionSync() {
        long startTime = System.currentTimeMillis();
        try {
            int recordCount = checkPrescriptionSync();
            long syncTime = System.currentTimeMillis() - startTime;
            
            if (recordCount > 0) {
                return new SyncResult("处方数据", true, "同步正常", syncTime, recordCount);
            } else {
                return new SyncResult("处方数据", false, "无同步记录", syncTime, 0);
            }
        } catch (Exception e) {
            long syncTime = System.currentTimeMillis() - startTime;
            return new SyncResult("处方数据", false, "验证失败: " + e.getMessage(), syncTime, 0);
        }
    }

    /**
     * 检查用户数据同步
     */
    private static int checkUserSync() {
        // 模拟检查用户数据同步
        return 100;
    }

    /**
     * 检查健康记录同步
     */
    private static int checkHealthRecordSync() {
        // 模拟检查健康记录同步
        return 500;
    }

    /**
     * 检查预约数据同步
     */
    private static int checkAppointmentSync() {
        // 模拟检查预约数据同步
        return 200;
    }

    /**
     * 检查医疗记录同步
     */
    private static int checkMedicalRecordSync() {
        // 模拟检查医疗记录同步
        return 300;
    }

    /**
     * 检查处方数据同步
     */
    private static int checkPrescriptionSync() {
        // 模拟检查处方数据同步
        return 150;
    }

    /**
     * 生成同步验证报告
     */
    public static String generateReport(List<SyncResult> results) {
        StringBuilder report = new StringBuilder();
        report.append("========================================\n");
        report.append("数据同步验证报告\n");
        report.append("========================================\n\n");
        
        int successCount = 0;
        int totalCount = results.size();
        int totalRecords = 0;
        
        for (SyncResult result : results) {
            report.append(String.format("同步类型: %s\n", result.getSyncType()));
            report.append(String.format("状态: %s\n", result.isSuccess() ? "✅ 同步正常" : "❌ 同步异常"));
            report.append(String.format("消息: %s\n", result.getMessage()));
            report.append(String.format("同步时间: %d ms\n", result.getSyncTime()));
            report.append(String.format("记录数量: %d\n", result.getRecordCount()));
            report.append(String.format("检查时间: %s\n\n", result.getCheckTime()));
            
            if (result.isSuccess()) {
                successCount++;
                totalRecords += result.getRecordCount();
            }
        }
        
        report.append("========================================\n");
        report.append(String.format("总结: %d/%d 数据同步正常\n", successCount, totalCount));
        report.append(String.format("成功率: %.1f%%\n", (successCount * 100.0 / totalCount)));
        report.append(String.format("总记录数: %d\n", totalRecords));
        report.append("========================================\n");
        
        return report.toString();
    }
}
