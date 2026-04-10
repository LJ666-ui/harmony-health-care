package com.medical.test_lyz.controller;

import com.medical.test_lyz.entity.HealthFood;
import com.medical.test_lyz.services.HealthFoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/health")
public class HealthFoodController {

    @Autowired
    private HealthFoodService healthFoodService;

    @GetMapping("/list")
    public List<HealthFood> list() {
        // 打印查看数据库数据
        List<HealthFood> dataList = healthFoodService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class test_lykController {

    @GetMapping("/test_lyz")
    public String test_lyz() {
        return "项目运行成功！接口正常！";
    }
}
