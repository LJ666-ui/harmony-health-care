package com.example.medical.controller;

import com.example.medical.entity.HealthArticle;
import com.example.medical.service.HealthArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/health-article")
public class HealthArticleController {

    @Autowired
    private HealthArticleService healthArticleService;

    @GetMapping("/list")
    public List<HealthArticle> list() {
        // 打印查看数据库数据
        List<HealthArticle> dataList = healthArticleService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class test_lyk {

    @GetMapping("/test_lyk")
    public String test_lyk() {
        return "项目运行成功！接口正常！";
    }
}