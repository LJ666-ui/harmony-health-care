package com.medical;

import com.medical.entity.Medicine;
import com.medical.mapper.MedicineMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

/**
 * 数据库连接测试类
 * 测试Java后端是否与数据库连接，并打印数据库里的前10条数据
 */
@SpringBootTest
public class DatabaseConnectionTest {

    @Autowired
    private MedicineMapper medicineMapper;

    @Test
    public void testDatabaseConnection() {
        System.out.println("开始测试数据库连接...");
        
        try {
            // 查询前10条药品数据
            List<Medicine> medicines = medicineMapper.selectList(null);
            
            if (medicines != null && !medicines.isEmpty()) {
                System.out.println("数据库连接成功！");
                System.out.println("查询到的药品数据（前10条）：");
                
                // 只打印前10条
                int limit = Math.min(10, medicines.size());
                for (int i = 0; i < limit; i++) {
                    Medicine medicine = medicines.get(i);
                    System.out.println("ID: " + medicine.getId() + ", 名称: " + medicine.getName() + ", 适应症: " + medicine.getIndication());
                }
                
                System.out.println("共查询到 " + medicines.size() + " 条数据");
            } else {
                System.out.println("数据库连接成功，但没有查询到数据");
            }
        } catch (Exception e) {
            System.out.println("数据库连接失败：" + e.getMessage());
            e.printStackTrace();
        }
    }
}
