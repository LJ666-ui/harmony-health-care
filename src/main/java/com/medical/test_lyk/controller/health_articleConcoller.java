package com.medical.test_lyk_lyk.controller;

import com.medical.test_lyk.entity.health_article;
import com.medical.test_lyk.service.health_articleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/health")
public class health_articleConcoller {

    @Autowired
    private health_articleService healthArticleService;

    @GetMapping("/list")
    public List<health_article> list() {
        // 打印查看数据库数据
        List<health_article> dataList = healthArticleService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}

// 把测试接口单独拿出来，变成独立类
@RestController
class test_lykController {

    @GetMapping("/test_lyk")
    public String test_lyk() {
        return "项目运行成功！接口正常！";
    }
}
