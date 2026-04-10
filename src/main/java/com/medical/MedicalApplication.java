package com.medical;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 项目启动类，入口
 */
@SpringBootApplication
@MapperScan("com.medical.mapper") // 扫描 Mapper 包
public class MedicalApplication {
    public static void main(String[] args) {
        SpringApplication.run(MedicalApplication.class, args);
    }
}