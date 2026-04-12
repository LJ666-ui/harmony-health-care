package com.example.medical.controller;

import com.example.medical.common.Result;
import com.baomidou.mybatisplus.core.MybatisSqlSessionFactoryBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
@CrossOrigin
public class HealthController {
    @Autowired
    private DataSource dataSource;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 系统状态检查
     * @return 系统状态信息
     */
    @GetMapping("/status")
    public Result<Map<String, Object>> getSystemStatus() {
        try {
            Map<String, Object> status = new HashMap<>();
            
            // 运行状态
            status.put("status", "running");
            
            // 启动时间
            long startTime = ManagementFactory.getRuntimeMXBean().getStartTime();
            status.put("startTime", new java.util.Date(startTime));
            
            // Java版本
            status.put("javaVersion", System.getProperty("java.version"));
            
            // 系统信息
            status.put("osName", System.getProperty("os.name"));
            status.put("osVersion", System.getProperty("os.version"));
            
            return Result.success(status);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取系统状态失败：" + e.getMessage());
        }
    }

    /**
     * 数据库连接检查
     * @return 数据库连接状态
     */
    @GetMapping("/database")
    public Result<Map<String, Object>> checkDatabaseConnection() {
        try {
            Map<String, Object> databaseStatus = new HashMap<>();
            
            // 测试数据库连接
            jdbcTemplate.execute("SELECT 1");
            databaseStatus.put("status", "connected");
            databaseStatus.put("message", "数据库连接正常");
            
            return Result.success(databaseStatus);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("数据库连接检查失败：" + e.getMessage());
        }
    }

    /**
     * 系统资源概览
     * @return 系统资源信息
     */
    @GetMapping("/resources")
    public Result<Map<String, Object>> getSystemResources() {
        try {
            Map<String, Object> resources = new HashMap<>();
            
            // 内存信息
            MemoryMXBean memoryMXBean = ManagementFactory.getMemoryMXBean();
            MemoryUsage heapMemoryUsage = memoryMXBean.getHeapMemoryUsage();
            MemoryUsage nonHeapMemoryUsage = memoryMXBean.getNonHeapMemoryUsage();
            
            Map<String, Object> memoryInfo = new HashMap<>();
            memoryInfo.put("heapUsed", heapMemoryUsage.getUsed() / 1024 / 1024 + " MB");
            memoryInfo.put("heapMax", heapMemoryUsage.getMax() / 1024 / 1024 + " MB");
            memoryInfo.put("nonHeapUsed", nonHeapMemoryUsage.getUsed() / 1024 / 1024 + " MB");
            resources.put("memory", memoryInfo);
            
            // CPU信息
            int availableProcessors = Runtime.getRuntime().availableProcessors();
            resources.put("cpuCores", availableProcessors);
            
            // 系统负载
            double systemLoad = ManagementFactory.getOperatingSystemMXBean().getSystemLoadAverage();
            resources.put("systemLoad", systemLoad);
            
            return Result.success(resources);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取系统资源信息失败：" + e.getMessage());
        }
    }
}