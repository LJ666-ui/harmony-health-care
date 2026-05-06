package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.ParkingRecord;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Service接口
 */
public interface ParkingRecordService extends IService<ParkingRecord> {
    
    /**
     * 创建停车记录
     * @param record 停车记录
     * @return 创建结果
     */
    boolean createParkingRecord(ParkingRecord record);
    
    /**
     * 获取用户当前停车记录
     * @param userId 用户ID
     * @return 停车记录
     */
    ParkingRecord getCurrentParking(Long userId);
    
    /**
     * 计算停车费用
     * @param parkTime 停车时间
     * @return 费用
     */
    double calculateFee(Date parkTime);
    
    /**
     * 结算停车费用
     * @param recordId 记录ID
     * @return 结算结果
     */
    Map<String, Object> settleParking(Long recordId);
    
    /**
     * 获取用户停车历史
     * @param userId 用户ID
     * @return 历史记录列表
     */
    List<ParkingRecord> getParkingHistory(Long userId);
}
