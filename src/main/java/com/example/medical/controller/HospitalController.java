package com.example.medical.controller;

import com.example.medical.entity.Hospital;
import com.example.medical.service.HospitalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/hospital")
public class HospitalController {

    @Autowired
    private HospitalService hospitalService;

    @GetMapping("/list")
    public List<Hospital> list() {
        // 打印查看数据库数据
        List<Hospital> dataList = hospitalService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class test_hospital {

    @GetMapping("/test-hospital")
    public String test_hospital() {
        return "项目运行成功！接口正常！";
    }
}