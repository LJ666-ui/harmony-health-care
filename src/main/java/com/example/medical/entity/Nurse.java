package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.Date;

/**
 * 护士实体类
 */
@Data
@TableName("nurse")
public class Nurse {
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 关联用户表ID（外键）
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 护士工号
     */
    @NotBlank(message = "护士工号不能为空")
    @Size(min = 4, max = 20, message = "护士工号长度必须在4-20个字符之间")
    @TableField("nurse_no")
    private String nurseNo;

    /**
     * 真实姓名
     */
    @NotBlank(message = "姓名不能为空")
    @Size(min = 2, max = 50, message = "姓名长度必须在2-50个字符之间")
    private String name;

    /**
     * 手机号
     */
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式不正确")
    private String phone;

    /**
     * 所属科室
     */
    @NotBlank(message = "科室不能为空")
    private String department;

    /**
     * 职称
     */
    private String title;

    /**
     * 状态：0-离职，1-在职
     */
    private Integer status;

    /**
     * 创建时间
     */
    @TableField("create_time")
    private Date createTime;

    /**
     * 更新时间
     */
    @TableField("update_time")
    private Date updateTime;

    /**
     * 删除标记：0-未删除，1-已删除
     */
    @TableField("is_deleted")
    private Integer isDeleted;
}