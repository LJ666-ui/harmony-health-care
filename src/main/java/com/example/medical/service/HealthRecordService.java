package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.common.PageResult;
import com.example.medical.entity.HealthRecord;

import java.util.Date;
import java.util.List;

public interface HealthRecordService extends IService<HealthRecord> {
    /**
     * 新增健康记录
     * @param healthRecord 健康记录信息
     * @return 是否添加成功
     */
    boolean addHealthRecord(HealthRecord healthRecord);

    /**
     * 查询当前用户的所有记录
     * @param userId 用户ID
     * @return 健康记录列表
     */
    List<HealthRecord> findByUserId(Long userId);

    /**
     * 按用户ID + 时间范围筛选记录
     * @param userId 用户ID
     * @param startTime 开始时间
     * @param endTime 结束时间
     * @return 健康记录列表
     */
    List<HealthRecord> findByUserIdAndTimeRange(Long userId, Date startTime, Date endTime);

    /**
     * 分页查询个人记录
     * @param userId 用户ID
     * @param page 当前页
     * @param size 每页条数
     * @return 分页结果
     */
    PageResult<HealthRecord> findByUserIdWithPage(Long userId, Integer page, Integer size);
}