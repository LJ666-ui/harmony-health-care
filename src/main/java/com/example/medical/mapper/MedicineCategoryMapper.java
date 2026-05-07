package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.dto.CategoryWithCountDTO;
import com.example.medical.entity.MedicineCategory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface MedicineCategoryMapper extends BaseMapper<MedicineCategory> {

    /**
     * 查询所有有效分类（按显示顺序排序）
     */
    @Select("SELECT * FROM medicine_categories WHERE status = 1 AND is_deleted = 0 ORDER BY display_order ASC")
    List<MedicineCategory> selectValidCategories();

    /**
     * 查询分类及其药品数量统计
     */
    @Select("SELECT mc.id, mc.category_code AS categoryCode, mc.category_name AS categoryName, " +
            "mc.parent_code AS parentCode, mc.level, mc.display_order AS displayOrder, " +
            "COUNT(m.id) AS medicineCount " +
            "FROM medicine_categories mc " +
            "LEFT JOIN medicine m ON m.category_code = mc.category_code AND m.is_deleted = 0 " +
            "WHERE mc.status = 1 AND mc.is_deleted = 0 " +
            "GROUP BY mc.id, mc.category_code, mc.category_name, mc.parent_code, mc.level, mc.display_order " +
            "ORDER BY mc.display_order ASC")
    List<CategoryWithCountDTO> selectCategoriesWithCount();

    /**
     * 检查分类名称是否存在
     */
    @Select("SELECT COUNT(*) FROM medicine_categories WHERE category_name = #{categoryName} AND is_deleted = 0")
    int existsByName(String categoryName);

    /**
     * 检查分类编码是否存在
     */
    @Select("SELECT COUNT(*) FROM medicine_categories WHERE category_code = #{categoryCode} AND is_deleted = 0")
    int existsByCode(String categoryCode);

    /**
     * 获取指定层级的最大分类编码
     */
    @Select("SELECT MAX(category_code) FROM medicine_categories WHERE level = #{level} AND is_deleted = 0")
    String getMaxCodeByLevel(Integer level);

    /**
     * 获取指定父分类下的最大子分类编码
     */
    @Select("SELECT MAX(category_code) FROM medicine_categories WHERE parent_code = #{parentCode} AND is_deleted = 0")
    String getMaxCodeByParent(String parentCode);
}
