package com.example.medical.util;

import java.util.*;

/**
 * 多端连通性检查工具
 * 用于检查各端的连通性和数据同步状态
 */
public class ConnectivityChecker {

    /**
     * 检查结果
     */
    public static class CheckResult {
        private String terminal;
        private boolean connected;
        private String message;
        private Long responseTime;
        private Date checkTime;

        public CheckResult(String terminal, boolean connected, String message, Long responseTime) {
            this.terminal = terminal;
            this.connected = connected;
            this.message = message;
            this.responseTime = responseTime;
            this.checkTime = new Date();
        }

        // Getters
        public String getTerminal() { return terminal; }
        public boolean isConnected() { return connected; }
        public String getMessage() { return message; }
        public Long getResponseTime() { return responseTime; }
        public Date getCheckTime() { return checkTime; }
    }

    /**
     * 检查所有端连通性
     */
    public static List<CheckResult> checkAllTerminals() {
        List<CheckResult> results = new ArrayList<>();
        
        // 检查患者端
        results.add(checkPatientTerminal());
        
        // 检查医生端
        results.add(checkDoctorTerminal());
        
        // 检查护士端
        results.add(checkNurseTerminal());
        
        // 检查家属端
        results.add(checkFamilyTerminal());
        
        // 检查管理员端
        results.add(checkAdminTerminal());
        
        // 检查手表端
        results.add(checkWatchTerminal());
        
        return results;
    }

    /**
     * 检查患者端连通性
     */
    private static CheckResult checkPatientTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            // 模拟检查API连通性
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/patient");
            
            // 模拟检查WebSocket连通性
            boolean wsConnected = checkWebSocketConnectivity("ws://localhost:8080/ws/patient");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected && wsConnected) {
                return new CheckResult("患者端", true, "API和WebSocket连接正常", responseTime);
            } else if (apiConnected) {
                return new CheckResult("患者端", false, "WebSocket连接异常", responseTime);
            } else {
                return new CheckResult("患者端", false, "API连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("患者端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查医生端连通性
     */
    private static CheckResult checkDoctorTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/doctor");
            boolean wsConnected = checkWebSocketConnectivity("ws://localhost:8080/ws/doctor");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected && wsConnected) {
                return new CheckResult("医生端", true, "API和WebSocket连接正常", responseTime);
            } else {
                return new CheckResult("医生端", false, "连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("医生端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查护士端连通性
     */
    private static CheckResult checkNurseTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/nurse");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected) {
                return new CheckResult("护士端", true, "API连接正常", responseTime);
            } else {
                return new CheckResult("护士端", false, "API连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("护士端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查家属端连通性
     */
    private static CheckResult checkFamilyTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/family");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected) {
                return new CheckResult("家属端", true, "API连接正常", responseTime);
            } else {
                return new CheckResult("家属端", false, "API连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("家属端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查管理员端连通性
     */
    private static CheckResult checkAdminTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/admin");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected) {
                return new CheckResult("管理员端", true, "API连接正常", responseTime);
            } else {
                return new CheckResult("管理员端", false, "API连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("管理员端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查手表端连通性
     */
    private static CheckResult checkWatchTerminal() {
        long startTime = System.currentTimeMillis();
        try {
            boolean apiConnected = checkApiConnectivity("http://localhost:8080/api/watch");
            
            long responseTime = System.currentTimeMillis() - startTime;
            
            if (apiConnected) {
                return new CheckResult("手表端", true, "API连接正常", responseTime);
            } else {
                return new CheckResult("手表端", false, "API连接异常", responseTime);
            }
        } catch (Exception e) {
            long responseTime = System.currentTimeMillis() - startTime;
            return new CheckResult("手表端", false, "检查失败: " + e.getMessage(), responseTime);
        }
    }

    /**
     * 检查API连通性
     */
    private static boolean checkApiConnectivity(String url) {
        // 模拟API连通性检查
        // 实际实现中应该发送HTTP请求
        return true;
    }

    /**
     * 检查WebSocket连通性
     */
    private static boolean checkWebSocketConnectivity(String url) {
        // 模拟WebSocket连通性检查
        // 实际实现中应该建立WebSocket连接
        return true;
    }

    /**
     * 生成连通性报告
     */
    public static String generateReport(List<CheckResult> results) {
        StringBuilder report = new StringBuilder();
        report.append("========================================\n");
        report.append("多端连通性检查报告\n");
        report.append("========================================\n\n");
        
        int connectedCount = 0;
        int totalCount = results.size();
        
        for (CheckResult result : results) {
            report.append(String.format("终端: %s\n", result.getTerminal()));
            report.append(String.format("状态: %s\n", result.isConnected() ? "✅ 连接正常" : "❌ 连接异常"));
            report.append(String.format("消息: %s\n", result.getMessage()));
            report.append(String.format("响应时间: %d ms\n", result.getResponseTime()));
            report.append(String.format("检查时间: %s\n\n", result.getCheckTime()));
            
            if (result.isConnected()) {
                connectedCount++;
            }
        }
        
        report.append("========================================\n");
        report.append(String.format("总结: %d/%d 端连接正常\n", connectedCount, totalCount));
        report.append(String.format("连通率: %.1f%%\n", (connectedCount * 100.0 / totalCount)));
        report.append("========================================\n");
        
        return report.toString();
    }
}
