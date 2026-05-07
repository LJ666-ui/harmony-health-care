package com.example.medical.dto;

import lombok.Data;

/**
 * 分类信息DTO（包含药品数量统计）
 */
@Data
public class CategoryWithCountDTO {

    /** 分类ID */
    private Long id;

    /** 分类编码 */
    private String categoryCode;

    /** 分类名称 */
    private String categoryName;

    /** 父分类编码 */
    private String parentCode;

    /** 分类层级 */
    private Integer level;

    /** 显示顺序 */
    private Integer displayOrder;

    /** 药品数量 */
    private Integer medicineCount;
}
