package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Pattern;
import java.util.Date;

@Data
@TableName("device_binding")
public class DeviceBinding {
    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    @NotBlank(message = "设备ID不能为空")
    private String deviceId;

    @NotBlank(message = "设备名称不能为空")
    private String deviceName;

    @Pattern(regexp = "^(PHONE|WATCH|TABLET|PC|OTHER)$", message = "设备类型不合法")
    private String deviceType;

    private String deviceModel;

    private String osVersion;

    private Integer status;

    private Date bindTime;

    private Date lastSyncTime;

    private String syncData;

    @TableField("is_deleted")
    private Integer isDeleted;
}
