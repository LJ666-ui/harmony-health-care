package com.example.medical.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

/**
 * 停车记录实体类
 * 对应数据库表：parking_record
 */
@Data
@TableName("parking_record")
public class ParkingRecord {
    
    /**
     * 记录ID（主键，自增）
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 停车场ID
     */
    private Long parkingLotId;
    
    /**
     * 停车场名称
     */
    private String parkingLotName;
    
    /**
     * 车位编号
     */
    private String spaceNumber;
    
    /**
     * 楼层
     */
    private String floor;
    
    /**
     * 区域
     */
    private String zone;
    
    /**
     * 纬度
     */
    private Double latitude;
    
    /**
     * 经度
     */
    private Double longitude;
    
    /**
     * 车牌号
     */
    private String licensePlate;
    
    /**
     * 车辆描述
     */
    private String carDescription;
    
    /**
     * 停车时间
     */
    private Date parkTime;
    
    /**
     * 离开时间
     */
    private Date leaveTime;
    
    /**
     * 停车费用
     */
    private Double fee;
    
    /**
     * 是否已支付（0-未支付，1-已支付）
     */
    private Integer paymentStatus;
    
    /**
     * 是否活跃（0-已离开，1-停车中）
     */
    private Integer isActive;
    
    /**
     * 备注
     */
    private String note;
    
    /**
     * 创建时间
     */
    private Date createTime;
    
    /**
     * 更新时间
     */
    private Date updateTime;
}
