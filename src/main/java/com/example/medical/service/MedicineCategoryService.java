package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.dto.CategoryWithCountDTO;
import com.example.medical.entity.MedicineCategory;
import com.example.medical.mapper.MedicineCategoryMapper;
import com.example.medical.mapper.MedicineMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MedicineCategoryService extends ServiceImpl<MedicineCategoryMapper, MedicineCategory> {

    @Autowired
    private MedicineCategoryMapper medicineCategoryMapper;

    @Autowired
    private MedicineMapper medicineMapper;

    /**
     * 获取所有分类及其药品数量统计
     */
    public List<CategoryWithCountDTO> getAllCategoriesWithCount() {
        return medicineCategoryMapper.selectCategoriesWithCount();
    }

    /**
     * 获取所有有效分类列表
     */
    public List<MedicineCategory> getValidCategories() {
        return medicineCategoryMapper.selectValidCategories();
    }

    /**
     * 新增分类
     */
    public boolean addCategory(MedicineCategory category) {
        if (category.getCategoryCode() == null || category.getCategoryCode().isEmpty()) {
            category.setCategoryCode(generateCategoryCode(category.getParentCode(), category.getLevel()));
        }

        if (medicineCategoryMapper.existsByCode(category.getCategoryCode()) > 0) {
            throw new RuntimeException("分类编码已存在：" + category.getCategoryCode());
        }

        if (medicineCategoryMapper.existsByName(category.getCategoryName()) > 0) {
            throw new RuntimeException("分类名称已存在：" + category.getCategoryName());
        }

        category.setStatus(1);
        category.setIsDeleted(0);
        return save(category);
    }

    /**
     * 生成分类编码（XX-XX-XX格式）
     */
    public String generateCategoryCode(String parentCode, Integer level) {
        if (level == null || level < 1 || level > 3) {
            throw new RuntimeException("分类层级必须是1、2或3");
        }

        if (level == 1) {
            String maxCode = medicineCategoryMapper.getMaxCodeByLevel(1);
            if (maxCode == null) {
                return "01";
            }
            int nextNum = Integer.parseInt(maxCode) + 1;
            return String.format("%02d", nextNum);
        } else {
            if (parentCode == null || parentCode.isEmpty()) {
                throw new RuntimeException("二级及三级分类必须指定父分类编码");
            }

            String maxCode = medicineCategoryMapper.getMaxCodeByParent(parentCode);
            if (maxCode == null) {
                return parentCode + "-01";
            }

            String[] parts = maxCode.split("-");
            int lastNum = Integer.parseInt(parts[parts.length - 1]);
            int nextNum = lastNum + 1;
            return parentCode + "-" + String.format("%02d", nextNum);
        }
    }

    /**
     * 删除分类（逻辑删除）
     */
    public boolean deleteCategory(Long categoryId) {
        MedicineCategory category = getById(categoryId);
        if (category == null) {
            throw new RuntimeException("分类不存在");
        }

        QueryWrapper<com.example.medical.entity.Medicine> wrapper = new QueryWrapper<>();
        wrapper.eq("category_code", category.getCategoryCode());
        wrapper.eq("is_deleted", 0);
        long count = medicineMapper.selectCount(wrapper);
        if (count > 0) {
            throw new RuntimeException("该分类下存在" + count + "个药品，无法删除");
        }

        category.setIsDeleted(1);
        return updateById(category);
    }
}
