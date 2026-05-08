package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
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
    public Result<List<Medicine>> list(@RequestParam(required = false) String categoryCode) {
        List<Medicine> dataList;
        if (categoryCode != null && !categoryCode.isEmpty()) {
            dataList = medicineService.findByCategoryCode(categoryCode);
        } else {
            dataList = medicineService.list();
        }
        System.out.println("数据库数据：" + dataList);
        return Result.success(dataList);
    }

    @GetMapping("/page")
    public Result<Page<Medicine>> page(@RequestParam(defaultValue = "1") Integer current, 
                              @RequestParam(defaultValue = "10") Integer size, 
                              @RequestParam(required = false) String sortField, 
                              @RequestParam(required = false) String sortOrder) {
        Page<Medicine> page = new Page<>(current, size);
        Page<Medicine> result = medicineService.page(page);
        return Result.success(result);
    }

    @GetMapping("/search")
    public Result<Page<Medicine>> search(@RequestParam(required = false) String name, 
                               @RequestParam(required = false) String source, 
                               @RequestParam(defaultValue = "1") Integer current, 
                               @RequestParam(defaultValue = "10") Integer size) {
        Page<Medicine> page = new Page<>(current, size);
        Page<Medicine> result = medicineService.page(page);
        return Result.success(result);
    }

    @GetMapping("/detail/{id}")
    public Result<Medicine> detail(@PathVariable Long id) {
        Medicine medicine = medicineService.getById(id);
        return Result.success(medicine);
    }

}
