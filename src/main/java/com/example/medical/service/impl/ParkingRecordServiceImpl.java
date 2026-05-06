package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.ParkingRecord;
import com.example.medical.mapper.ParkingRecordMapper;
import com.example.medical.service.ParkingRecordService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 停车记录Service实现类
 */
@Service
public class ParkingRecordServiceImpl extends ServiceImpl<ParkingRecordMapper, ParkingRecord> implements ParkingRecordService {
    
    // 停车费率：每小时5元
    private static final double HOURLY_RATE = 5.0;
    // 每日封顶费用：50元
    private static final double DAILY_CAP = 50.0;
    
    @Override
    public boolean createParkingRecord(ParkingRecord record) {
        record.setParkTime(new Date());
        record.setIsActive(1);
        record.setPaymentStatus(0);
        record.setCreateTime(new Date());
        record.setUpdateTime(new Date());
        return save(record);
    }
    
    @Override
    public ParkingRecord getCurrentParking(Long userId) {
        LambdaQueryWrapper<ParkingRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ParkingRecord::getUserId, userId)
               .eq(ParkingRecord::getIsActive, 1)
               .orderByDesc(ParkingRecord::getParkTime)
               .last("LIMIT 1");
        return getOne(wrapper);
    }
    
    @Override
    public double calculateFee(Date parkTime) {
        long duration = System.currentTimeMillis() - parkTime.getTime();
        double hours = duration / (1000.0 * 60 * 60);
        
        // 计算费用
        double fee = hours * HOURLY_RATE;
        
        // 应用每日封顶
        if (fee > DAILY_CAP) {
            fee = DAILY_CAP;
        }
        
        // 不足1小时按1小时计算
        fee = Math.ceil(fee);
        
        return fee;
    }
    
    @Override
    public Map<String, Object> settleParking(Long recordId) {
        Map<String, Object> result = new HashMap<>();
        
        ParkingRecord record = getById(recordId);
        if (record == null) {
            result.put("success", false);
            result.put("message", "记录不存在");
            return result;
        }
        
        // 计算费用
        double fee = calculateFee(record.getParkTime());
        
        // 更新记录
        LambdaUpdateWrapper<ParkingRecord> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(ParkingRecord::getId, recordId)
               .set(ParkingRecord::getLeaveTime, new Date())
               .set(ParkingRecord::getFee, fee)
               .set(ParkingRecord::getIsActive, 0)
               .set(ParkingRecord::getUpdateTime, new Date());
        
        boolean updated = update(wrapper);
        
        result.put("success", updated);
        result.put("fee", fee);
        result.put("duration", (System.currentTimeMillis() - record.getParkTime().getTime()) / (1000 * 60));
        result.put("message", updated ? "结算成功" : "结算失败");
        
        return result;
    }
    
    @Override
    public List<ParkingRecord> getParkingHistory(Long userId) {
        LambdaQueryWrapper<ParkingRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ParkingRecord::getUserId, userId)
               .orderByDesc(ParkingRecord::getParkTime);
        return list(wrapper);
    }
}
