package com.medical.test.controller;

import com.medical.test.entity.RehabPlan;
import com.medical.test.services.RehabPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/rehab")
public class RehabPlanController {

    @Autowired
    private RehabPlanService rehabPlanService;

    @GetMapping("/list")
    public List<RehabPlan> list() {
        // 打印查看数据库数据
        List<RehabPlan> dataList = rehabPlanService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}

// 把测试接口单独拿出来，变成独立类
@RestController
class TestController {

    @GetMapping("/test")
    public String test() {
        return "项目运行成功！接口正常！";
    }
}
