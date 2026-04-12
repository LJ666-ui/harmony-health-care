package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HealthRecord;
import com.example.medical.entity.SysStatistics;
import com.example.medical.mapper.HealthRecordMapper;
import com.example.medical.mapper.SysStatisticsMapper;
import com.example.medical.service.SysStatisticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class SysStatisticsServiceImpl extends ServiceImpl<SysStatisticsMapper, SysStatistics> implements SysStatisticsService {
    @Autowired
    private HealthRecordMapper healthRecordMapper;

    @Override
    public Map<String, Object> getSystemStatistics() {
        Map<String, Object> statistics = new HashMap<>();

        // 计算今日新增记录数
        Date today = new Date();
        Date startOfDay = getStartOfDay(today);
        LambdaQueryWrapper<HealthRecord> todayWrapper = new LambdaQueryWrapper<>();
        todayWrapper.ge(HealthRecord::getCreateTime, startOfDay);
        todayWrapper.eq(HealthRecord::getIsDeleted, 0);
        long todayCount = healthRecordMapper.selectCount(todayWrapper);
        statistics.put("todayNewRecords", todayCount);

        // 计算本周活跃用户数
        Date startOfWeek = getStartOfWeek(today);
        LambdaQueryWrapper<HealthRecord> weekWrapper = new LambdaQueryWrapper<>();
        weekWrapper.ge(HealthRecord::getCreateTime, startOfWeek);
        weekWrapper.eq(HealthRecord::getIsDeleted, 0);
        List<HealthRecord> weekRecords = healthRecordMapper.selectList(weekWrapper);
        long activeUsers = weekRecords.stream().map(HealthRecord::getUserId).distinct().count();
        statistics.put("weeklyActiveUsers", activeUsers);

        // 模拟月度评估次数和计划完成率
        statistics.put("monthlyEvaluations", 120);
        statistics.put("planCompletionRate", 85.5);

        return statistics;
    }

    @Override
    public Map<String, Object> getPersonalHealthTrend(Long userId) {
        Map<String, Object> trend = new HashMap<>();

        // 计算近7天的开始时间
        Date today = new Date();
        Date startOf7Days = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

        // 查询近7天的健康记录
        LambdaQueryWrapper<HealthRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthRecord::getUserId, userId);
        wrapper.ge(HealthRecord::getCreateTime, startOf7Days);
        wrapper.eq(HealthRecord::getIsDeleted, 0);
        wrapper.orderByAsc(HealthRecord::getCreateTime);
        List<HealthRecord> records = healthRecordMapper.selectList(wrapper);

        // 提取血压和心率数据
        List<String> dates = records.stream()
                .map(record -> record.getCreateTime().toString().substring(0, 10))
                .collect(java.util.stream.Collectors.toList());

        List<String> bloodPressures = records.stream()
                .map(HealthRecord::getBloodPressure)
                .collect(java.util.stream.Collectors.toList());

        List<Integer> heartRates = records.stream()
                .map(HealthRecord::getHeartRate)
                .collect(java.util.stream.Collectors.toList());

        trend.put("dates", dates);
        trend.put("bloodPressures", bloodPressures);
        trend.put("heartRates", heartRates);

        return trend;
    }

    @Override
    public Map<String, Object> getPersonal30DaySummary(Long userId) {
        Map<String, Object> summary = new HashMap<>();

        // 计算近30天的开始时间
        Date today = new Date();
        Date startOf30Days = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

        // 查询近30天的健康记录
        LambdaQueryWrapper<HealthRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthRecord::getUserId, userId);
        wrapper.ge(HealthRecord::getCreateTime, startOf30Days);
        wrapper.eq(HealthRecord::getIsDeleted, 0);
        List<HealthRecord> records = healthRecordMapper.selectList(wrapper);

        // 计算血糖均值
        double avgBloodSugar = records.stream()
                .filter(record -> record.getBloodSugar() != null)
                .mapToDouble(record -> record.getBloodSugar().doubleValue())
                .average()
                .orElse(0.0);
        summary.put("avgBloodSugar", avgBloodSugar);

        // 统计运动达标天数（假设步数 >= 8000 为达标）
        long exerciseDays = records.stream()
                .filter(record -> record.getStepCount() != null && record.getStepCount() >= 8000)
                .count();
        summary.put("exerciseDays", exerciseDays);

        // 计算睡眠均值
        double avgSleepDuration = records.stream()
                .filter(record -> record.getSleepDuration() != null)
                .mapToDouble(record -> record.getSleepDuration().doubleValue())
                .average()
                .orElse(0.0);
        summary.put("avgSleepDuration", avgSleepDuration);

        return summary;
    }

    @Override
    public Map<String, Object> getHealthCurveData(Long userId, Date startDate, Date endDate) {
        Map<String, Object> curveData = new HashMap<>();

        // 查询指定时间范围内的健康记录
        LambdaQueryWrapper<HealthRecord> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HealthRecord::getUserId, userId);
        wrapper.between(HealthRecord::getCreateTime, startDate, endDate);
        wrapper.eq(HealthRecord::getIsDeleted, 0);
        wrapper.orderByAsc(HealthRecord::getCreateTime);
        List<HealthRecord> records = healthRecordMapper.selectList(wrapper);

        // 提取时间序列数据
        List<String> timestamps = records.stream()
                .map(record -> record.getCreateTime().toString())
                .collect(java.util.stream.Collectors.toList());

        List<Double> bloodSugars = records.stream()
                .map(record -> record.getBloodSugar() != null ? record.getBloodSugar().doubleValue() : 0.0)
                .collect(java.util.stream.Collectors.toList());

        List<Double> weights = records.stream()
                .map(record -> record.getWeight() != null ? record.getWeight().doubleValue() : 0.0)
                .collect(java.util.stream.Collectors.toList());

        curveData.put("timestamps", timestamps);
        curveData.put("bloodSugars", bloodSugars);
        curveData.put("weights", weights);

        return curveData;
    }

    @Override
    public void updateSystemStatistics() {
        // 这里可以实现系统统计数据的更新逻辑
        // 例如，定时计算并更新到 sys_statistics 表
    }

    @Override
    public void updatePersonalStatistics(Long userId) {
        // 这里可以实现个人统计数据的更新逻辑
        // 例如，定时计算并更新到 sys_statistics 表
    }

    // 辅助方法：获取某天的开始时间
    private Date getStartOfDay(Date date) {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.setTime(date);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }

    // 辅助方法：获取本周的开始时间（周一）
    private Date getStartOfWeek(Date date) {
        java.util.Calendar calendar = java.util.Calendar.getInstance();
        calendar.setTime(date);
        int dayOfWeek = calendar.get(java.util.Calendar.DAY_OF_WEEK);
        int daysToSubtract = dayOfWeek == 1 ? 6 : dayOfWeek - 2;
        calendar.add(java.util.Calendar.DAY_OF_MONTH, -daysToSubtract);
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0);
        calendar.set(java.util.Calendar.MINUTE, 0);
        calendar.set(java.util.Calendar.SECOND, 0);
        calendar.set(java.util.Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }
}