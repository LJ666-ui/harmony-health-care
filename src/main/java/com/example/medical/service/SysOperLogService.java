package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.SysOperLog;

import java.util.Date;
import java.util.List;

public interface SysOperLogService extends IService<SysOperLog> {
    /**
     * 新增操作日志
     * @param userId 操作用户ID
     * @param operationType 操作类型
     * @param operationDesc 操作描述
     * @param ipAddress IP地址
     * @param deviceInfo 设备信息
     * @return 记录的日志
     */
    SysOperLog addOperLog(Long userId, String operationType, String operationDesc, String ipAddress, String deviceInfo);

    /**
     * 查询操作日志列表
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    List<SysOperLog> getOperLogs(int page, int pageSize);

    /**
     * 按用户筛选操作日志
     * @param userId 用户ID
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    List<SysOperLog> getOperLogsByUserId(Long userId, int page, int pageSize);

    /**
     * 按时间范围筛选操作日志
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @param page 页码
     * @param pageSize 每页条数
     * @return 操作日志列表
     */
    List<SysOperLog> getOperLogsByTimeRange(Date startTime, Date endTime, int page, int pageSize);

    /**
     * 按操作类型统计
     * @return 操作类型统计结果
     */
    List<Object> getOperTypeStatistics();
}