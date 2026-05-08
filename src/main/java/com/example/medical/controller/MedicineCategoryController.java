package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.dto.CategoryWithCountDTO;
import com.example.medical.entity.MedicineCategory;
import com.example.medical.service.MedicineCategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/medicine/category")
public class MedicineCategoryController {

    @Autowired
    private MedicineCategoryService medicineCategoryService;

    /**
     * 获取分类列表（包含药品数量统计）
     */
    @GetMapping("/list")
    public Result<List<CategoryWithCountDTO>> list() {
        List<CategoryWithCountDTO> categories = medicineCategoryService.getAllCategoriesWithCount();
        return Result.success(categories);
    }

    /**
     * 获取分类详情
     */
    @GetMapping("/{id}")
    public Result<MedicineCategory> detail(@PathVariable Long id) {
        MedicineCategory category = medicineCategoryService.getById(id);
        return Result.success(category);
    }

    /**
     * 新增分类
     */
    @PostMapping("/add")
    public Result<String> add(@RequestBody MedicineCategory category) {
        try {
            boolean success = medicineCategoryService.addCategory(category);
            if (success) {
                return Result.success("分类添加成功");
            } else {
                return Result.error("分类添加失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新分类
     */
    @PutMapping("/update")
    public Result<String> update(@RequestBody MedicineCategory category) {
        try {
            boolean success = medicineCategoryService.updateById(category);
            if (success) {
                return Result.success("分类更新成功");
            } else {
                return Result.error("分类更新失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 删除分类
     */
    @DeleteMapping("/{id}")
    public Result<String> delete(@PathVariable Long id) {
        try {
            boolean success = medicineCategoryService.deleteCategory(id);
            if (success) {
                return Result.success("分类删除成功");
            } else {
                return Result.error("分类删除失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
