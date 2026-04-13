package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.SysStatistics;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface SysStatisticsService extends IService<SysStatistics> {
    /**
     * 首页系统统计
     * @return 系统统计数据
     */
    Map<String, Object> getSystemStatistics();

    /**
     * 个人7天健康趋势
     * @param userId 用户ID
     * @return 健康趋势数据
     */
    Map<String, Object> getPersonalHealthTrend(Long userId);

    /**
     * 个人30天统计汇总
     * @param userId 用户ID
     * @return 统计汇总数据
     */
    Map<String, Object> getPersonal30DaySummary(Long userId);

    /**
     * 健康曲线完整数据
     * @param userId 用户ID
     * @param startDate 开始日期
     * @param endDate 结束日期
     * @return 健康曲线数据
     */
    Map<String, Object> getHealthCurveData(Long userId, Date startDate, Date endDate);

    /**
     * 更新系统统计数据
     */
    void updateSystemStatistics();

    /**
     * 更新个人统计数据
     * @param userId 用户ID
     */
    void updatePersonalStatistics(Long userId);
}