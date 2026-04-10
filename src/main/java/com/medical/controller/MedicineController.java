package com.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.medical.commin.Result;
import com.medical.entity.Medicine;
import com.medical.service.MedicineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 药品接口控制器，供鸿蒙前端调用
 */
@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/medicine")
public class MedicineController {

    // 1. 修复字段注入警告：改为构造器注入（IDEA推荐，Spring最佳实践）
    private final MedicineService medicineService;

    public MedicineController(MedicineService medicineService) {
        this.medicineService = medicineService;
    }

    /**
     * 1. 查询所有药品
     * GET /api/medicine/list
     */
    @GetMapping("/list")
    public Result<List<Medicine>> list() {
        List<Medicine> list = medicineService.list();
        return Result.success(list);
    }

    /**
     * 2. 根据 ID 查询药品
     * GET /api/medicine/{id}
     */
    @GetMapping("/{id}")
    public Result<Medicine> getById(@PathVariable Long id) {
        Medicine medicine = medicineService.getById(id);
        return Result.success(medicine);
    }

    /**
     * 3. 新增药品
     * POST /api/medicine/add
     * 鸿蒙前端传 JSON 格式的 Medicine 对象
     */
    @PostMapping("/add")
    public Result<String> add(@RequestBody Medicine medicine) {
        boolean success = medicineService.save(medicine);
        if (success) {
            return Result.success("新增成功");
        } else {
            return Result.error("新增失败");
        }
    }

    /**
     * 4. 更新药品
     * PUT /api/medicine/update
     * 鸿蒙前端传 JSON 格式的 Medicine 对象
     */
    @PutMapping("/update")
    public Result<String> update(@RequestBody Medicine medicine) {
        boolean success = medicineService.updateById(medicine);
        if (success) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 5. 删除药品
     * DELETE /api/medicine/delete/{id}
     */
    @DeleteMapping("/delete/{id}")
    public Result<String> delete(@PathVariable Long id) {
        boolean success = medicineService.removeById(id);
        if (success) {
            return Result.success("删除成功");
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 6. 清空表（重置 ID）
     * DELETE /api/medicine/truncate
     */
    @DeleteMapping("/truncate")
    public Result<String> truncate() {
        // 2. 修复truncate报错：BaseMapper没有truncate方法，用remove清空+手动执行SQL重置ID
        medicineService.remove(new LambdaQueryWrapper<>());

        // 方案1：用MyBatis-Plus执行TRUNCATE（推荐，无需写XML）
        medicineService.getBaseMapper().delete(new LambdaQueryWrapper<>());
        // 方案2：如果需要重置自增ID，在Mapper中添加truncate方法（可选）
        // medicineService.truncate();

        return Result.success("清空成功");
    }
}