package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.Date;

@Data
@TableName("transfer_apply")
public class TransferApply {
    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @NotNull(message = "转出医院ID不能为空")
    @TableField("from_hospital_id")
    private Long fromHospitalId;

    @NotNull(message = "转入医院ID不能为空")
    @TableField("to_hospital_id")
    private Long toHospitalId;

    @NotBlank(message = "申请原因不能为空")
    @TableField("apply_reason")
    private String applyReason;

    private Date applyTime;

    private Integer status;

    private Date approveTime;

    @TableField("approver_id")
    private Long approverId;

    private Date createTime;

    private Date updateTime;

    @TableField("is_deleted")
    private Integer isDeleted;

    public static final int STATUS_PENDING = 0;
    public static final int STATUS_APPROVED = 1;
    public static final int STATUS_REJECTED = 2;
}
