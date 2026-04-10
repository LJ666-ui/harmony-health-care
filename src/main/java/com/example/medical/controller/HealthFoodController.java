package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.HealthFood;
import com.example.medical.service.HealthFoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/health_food")
@CrossOrigin
public class HealthFoodController {

    @Autowired
    private HealthFoodService healthFoodService;

    @GetMapping("/list")
    public Result<List<HealthFood>> list() {
        try {
            // 调用service获取数据
            List<HealthFood> dataList = healthFoodService.list();
            System.out.println("数据库数据：" + dataList);
            return Result.success(dataList);
        } catch (Exception e) {
            System.out.println("错误信息：" + e.getMessage());
            e.printStackTrace();
            return Result.error("获取健康食材列表失败：" + e.getMessage());
        }
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class test_health_food {

    @GetMapping("/test-health-food")
    public String test_health_food() {
        return "项目运行成功！接口正常！";
    }
}