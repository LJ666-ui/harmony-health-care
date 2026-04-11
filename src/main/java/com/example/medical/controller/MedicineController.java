package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.Medicine;
import com.example.medical.service.MedicineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
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

    @GetMapping("/page")
    public Page<Medicine> page(@RequestParam(defaultValue = "1") Integer current, 
                              @RequestParam(defaultValue = "10") Integer size, 
                              @RequestParam(required = false) String sortField, 
                              @RequestParam(required = false) String sortOrder) {
        Page<Medicine> page = new Page<>(current, size);
        return medicineService.page(page);
    }

    @GetMapping("/search")
    public Page<Medicine> search(@RequestParam(required = false) String name, 
                               @RequestParam(required = false) String source, 
                               @RequestParam(defaultValue = "1") Integer current, 
                               @RequestParam(defaultValue = "10") Integer size) {
        Page<Medicine> page = new Page<>(current, size);
        // 这里需要在MedicineService中添加搜索方法，暂时使用page方法
        return medicineService.page(page);
    }

    @GetMapping("/detail/{id}")
    public Medicine detail(@PathVariable Long id) {
        return medicineService.getById(id);
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