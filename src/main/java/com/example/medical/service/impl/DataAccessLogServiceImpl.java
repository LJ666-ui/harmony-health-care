package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.DataAccessLog;
import com.example.medical.mapper.DataAccessLogMapper;
import com.example.medical.service.DataAccessLogService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class DataAccessLogServiceImpl extends ServiceImpl<DataAccessLogMapper, DataAccessLog> implements DataAccessLogService {
    @Override
    public DataAccessLog recordAccessLog(Long userId, Long accessUserId, String dataType, Long dataId, Integer isAuthorized, String accessIp) {
        // 创建访问日志记录
        DataAccessLog log = new DataAccessLog();
        log.setUserId(userId);
        log.setAccessUserId(accessUserId);
        log.setDataType(dataType);
        log.setDataId(dataId);
        log.setAccessTime(new Date());
        log.setAccessIp(accessIp);
        log.setIsAuthorized(isAuthorized);
        log.setIsDeleted(0);
        log.setCreateTime(new Date());

        // 保存到数据库
        save(log);
        return log;
    }

    @Override
    public List<DataAccessLog> getAccessLogsByUserId(Long userId) {
        LambdaQueryWrapper<DataAccessLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataAccessLog::getUserId, userId);
        wrapper.eq(DataAccessLog::getIsDeleted, 0);
        wrapper.orderByDesc(DataAccessLog::getAccessTime);
        return list(wrapper);
    }

    @Override
    public List<DataAccessLog> getAccessLogsByAccessUserId(Long accessUserId) {
        LambdaQueryWrapper<DataAccessLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataAccessLog::getAccessUserId, accessUserId);
        wrapper.eq(DataAccessLog::getIsDeleted, 0);
        wrapper.orderByDesc(DataAccessLog::getAccessTime);
        return list(wrapper);
    }

    @Override
    public List<DataAccessLog> getAccessLogsByDataType(String dataType) {
        LambdaQueryWrapper<DataAccessLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataAccessLog::getDataType, dataType);
        wrapper.eq(DataAccessLog::getIsDeleted, 0);
        wrapper.orderByDesc(DataAccessLog::getAccessTime);
        return list(wrapper);
    }
}