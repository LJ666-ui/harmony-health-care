package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.SysOperLog;
import com.example.medical.mapper.SysOperLogMapper;
import com.example.medical.service.SysOperLogService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class SysOperLogServiceImpl extends ServiceImpl<SysOperLogMapper, SysOperLog> implements SysOperLogService {
    @Override
    public SysOperLog addOperLog(Long userId, String operationType, String operationDesc, String ipAddress, String deviceInfo) {
        // 创建操作日志记录
        SysOperLog log = new SysOperLog();
        log.setUserId(userId);
        log.setOperationType(operationType);
        log.setOperationDesc(operationDesc);
        log.setOperationTime(new Date());
        log.setIpAddress(ipAddress);
        log.setDeviceInfo(deviceInfo);
        log.setIsDeleted(0);
        log.setCreateTime(new Date());

        // 保存到数据库
        save(log);
        return log;
    }

    @Override
    public List<SysOperLog> getOperLogs(int page, int pageSize) {
        Page<SysOperLog> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOperLog::getIsDeleted, 0);
        wrapper.orderByDesc(SysOperLog::getOperationTime);
        Page<SysOperLog> result = page(pageInfo, wrapper);
        return result.getRecords();
    }

    @Override
    public List<SysOperLog> getOperLogsByUserId(Long userId, int page, int pageSize) {
        Page<SysOperLog> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOperLog::getUserId, userId);
        wrapper.eq(SysOperLog::getIsDeleted, 0);
        wrapper.orderByDesc(SysOperLog::getOperationTime);
        Page<SysOperLog> result = page(pageInfo, wrapper);
        return result.getRecords();
    }

    @Override
    public List<SysOperLog> getOperLogsByTimeRange(Date startTime, Date endTime, int page, int pageSize) {
        Page<SysOperLog> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.between(SysOperLog::getOperationTime, startTime, endTime);
        wrapper.eq(SysOperLog::getIsDeleted, 0);
        wrapper.orderByDesc(SysOperLog::getOperationTime);
        Page<SysOperLog> result = page(pageInfo, wrapper);
        return result.getRecords();
    }

    @Override
    public List<Object> getOperTypeStatistics() {
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysOperLog::getIsDeleted, 0);
        List<SysOperLog> logs = list(wrapper);

        // 按操作类型分组统计
        Map<String, Long> statistics = logs.stream()
                .collect(Collectors.groupingBy(SysOperLog::getOperationType, Collectors.counting()));

        // 转换为列表格式
        return statistics.entrySet().stream()
                .map(entry -> {
                    Map<String, Object> item = new java.util.HashMap<>();
                    item.put("type", entry.getKey());
                    item.put("count", entry.getValue());
                    return item;
                })
                .collect(Collectors.toList());
    }
}