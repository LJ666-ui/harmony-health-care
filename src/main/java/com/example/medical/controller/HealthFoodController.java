package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthFood;
import com.example.medical.service.HealthFoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping({"/healthFood", "/health_food"})
@CrossOrigin
public class HealthFoodController {

    @Autowired
    private HealthFoodService healthFoodService;

    /**
     * 分页列表接口
     */
    @GetMapping("/page")
    public Result<PageResult<HealthFood>> pageList(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String foodName,
            @RequestParam(required = false) String applicableDisease,
            @RequestParam(required = false) String dietTherapy,
            @RequestParam(required = false) String efficacy,
            @RequestParam(required = false) String dietaryTaboo) {
        try {
            PageResult<HealthFood> result = healthFoodService.pageQuery(page, pageSize, foodName, applicableDisease, dietTherapy, efficacy, dietaryTaboo);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康食材列表失败：" + e.getMessage());
        }
    }

    /**
     * 详情接口
     */
    @GetMapping("/detail/{id}")
    public Result<HealthFood> detail(@PathVariable Long id) {
        try {
            HealthFood healthFood = healthFoodService.getById(id);
            if (healthFood == null) {
                return Result.error("健康食材不存在");
            }
            return Result.success(healthFood);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取健康食材详情失败：" + e.getMessage());
        }
    }

    /**
     * 旧版列表接口（保持兼容性）
     */
    @GetMapping("/list")
    public Result<List<HealthFood>> list() {
        try {
            // 调用父类的list方法获取所有数据
            List<HealthFood> dataList = healthFoodService.list();
            System.out.println("数据库数据：" + dataList);
            return Result.success(dataList);
        } catch (Exception e) {
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
        return "项目运行成功！健康食材接口正常！";
    }
}