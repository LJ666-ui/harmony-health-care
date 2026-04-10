package com.example.medical.controller;

import com.example.medical.entity.Medicine;
import com.example.medical.service.MedicineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/medicine")
public class MedicineController {

    @Autowired
    private MedicineService medicineService;

    @GetMapping("/list")
    public List<Medicine> list() {
        // 打印查看数据库数据
        List<Medicine> dataList = medicineService.list();
        System.out.println("数据库数据：" + dataList);
        return dataList;
    }

}
// 把测试接口单独拿出来，变成独立类
@RestController
class test_medicine {

    @GetMapping("/test-medicine")
    public String test_medicine() {
        return "项目运行成功！接口正常！";
    }
}