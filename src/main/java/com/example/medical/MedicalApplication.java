package com.example.medical;

import com.example.medical.util.DatabaseStructureValidator;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;


// 关键：扫描 Mapper 接口
@MapperScan("com.example.medical.mapper")
@SpringBootApplication
public class MedicalApplication {
    public static void main(String[] args) {
        ConfigurableApplicationContext context = SpringApplication.run(MedicalApplication.class, args);
        
        // 启动后验证数据库结构
        try {
            DatabaseStructureValidator validator = context.getBean(DatabaseStructureValidator.class);
            validator.validateAll();
        } catch (Exception e) {
            System.err.println("数据库结构验证失败: " + e.getMessage());
        }
    }
}
