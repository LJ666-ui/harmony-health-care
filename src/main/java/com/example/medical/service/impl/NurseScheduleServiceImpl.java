package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.NurseSchedule;
import com.example.medical.mapper.NurseScheduleMapper;
import com.example.medical.service.NurseScheduleService;
import org.springframework.stereotype.Service;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class NurseScheduleServiceImpl extends ServiceImpl<NurseScheduleMapper, NurseSchedule> implements NurseScheduleService {

    @Override
    public List<NurseSchedule> getByNurseIdAndDateRange(Long nurseId, Date startDate, Date endDate) {
        return baseMapper.findByNurseIdAndDateRange(nurseId, startDate, endDate);
    }

    @Override
    public List<NurseSchedule> getByDateAndShift(Date date, Integer shiftType) {
        return baseMapper.findByDateAndShift(date, shiftType);
    }

    @Override
    public List<NurseSchedule> getByDate(Date date) {
        return baseMapper.findByDate(date);
    }

    @Override
    public List<NurseSchedule> getByDepartmentAndDate(String department, Date date) {
        return baseMapper.findByDepartmentAndDate(department, date);
    }

    @Override
    public Map<String, Object> getWeeklySchedule(Long nurseId, Date startDate) {
        Map<String, Object> result = new HashMap<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(startDate);

        List<Map<String, Object>> weekSchedule = new ArrayList<>();
        String[] weekdays = {"周日", "周一", "周二", "周三", "周四", "周五", "周六"};

        for (int i = 0; i < 7; i++) {
            Date currentDate = calendar.getTime();
            List<NurseSchedule> daySchedules = this.getByNurseIdAndDateRange(nurseId, currentDate, currentDate);

            Map<String, Object> dayInfo = new HashMap<>();
            dayInfo.put("date", sdf.format(currentDate));
            dayInfo.put("weekday", weekdays[calendar.get(Calendar.DAY_OF_WEEK) - 1]);
            dayInfo.put("schedules", daySchedules);
            dayInfo.put("hasWork", !daySchedules.isEmpty());

            if (!daySchedules.isEmpty()) {
                String shifts = daySchedules.stream()
                    .map(s -> getShiftName(s.getShiftType()))
                    .collect(Collectors.joining("/"));
                dayInfo.put("shiftText", shifts);
                dayInfo.put("wardArea", daySchedules.get(0).getWardArea());
            } else {
                dayInfo.put("shiftText", "休息");
                dayInfo.put("wardArea", "-");
            }

            weekSchedule.add(dayInfo);
            calendar.add(Calendar.DATE, 1);
        }

        result.put("nurseId", nurseId);
        result.put("weekStart", sdf.format(startDate));
        result.put("schedule", weekSchedule);

        return result;
    }

    @Override
    public Map<String, Object> getDailyOverview(Date date) {
        Map<String, Object> result = new HashMap<>();
        List<NurseSchedule> allSchedules = this.getByDate(date);

        long morningCount = allSchedules.stream().filter(s -> s.getShiftType() == 1).count();
        long afternoonCount = allSchedules.stream().filter(s -> s.getShiftType() == 2).count();
        long nightCount = allSchedules.stream().filter(s -> s.getShiftType() == 3).count();

        Map<String, Long> shiftStats = new LinkedHashMap<>();
        shiftStats.put("早班(07:00-15:00)", morningCount);
        shiftStats.put("中班(15:00-23:00)", afternoonCount);
        shiftStats.put("夜班(23:00-07:00)", nightCount);

        Map<String, List<NurseSchedule>> byDepartment = allSchedules.stream()
            .collect(Collectors.groupingBy(NurseSchedule::getDepartment, LinkedHashMap::new, Collectors.toList()));

        List<Map<String, Object>> departmentList = new ArrayList<>();
        byDepartment.forEach((dept, schedules) -> {
            Map<String, Object> deptInfo = new HashMap<>();
            deptInfo.put("department", dept);
            deptInfo.put("nurseCount", schedules.size());
            deptInfo.put("totalPatients", schedules.stream().mapToInt(s -> {
                if (s.getPatientIds() != null && !s.getPatientIds().isEmpty()) {
                    return s.getPatientIds().split(",").length;
                }
                return 0;
            }).sum());
            departmentList.add(deptInfo);
        });

        result.put("date", new SimpleDateFormat("yyyy-MM-dd").format(date));
        result.put("totalCount", (int) allSchedules.size());
        result.put("shiftStats", shiftStats);
        result.put("departments", departmentList);
        result.put("schedules", allSchedules);

        return result;
    }

    @Override
    public List<Map<String, Object>> getNurseScheduleDetail(Long nurseId, int days) {
        List<Map<String, Object>> detailList = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Calendar calendar = Calendar.getInstance();

        for (int i = 0; i < days; i++) {
            Date currentDate = calendar.getTime();
            List<NurseSchedule> daySchedules = this.getByNurseIdAndDateRange(nurseId, currentDate, currentDate);

            Map<String, Object> dayDetail = new HashMap<>();
            dayDetail.put("date", sdf.format(currentDate));
            dayDetail.put("schedules", daySchedules);

            if (!daySchedules.isEmpty()) {
                NurseSchedule first = daySchedules.get(0);
                dayDetail.put("nurseName", first.getNurseName());
                dayDetail.put("department", first.getDepartment());

                List<Map<String, Object>> shiftDetails = new ArrayList<>();
                for (NurseSchedule schedule : daySchedules) {
                    Map<String, Object> shiftDetail = new HashMap<>();
                    shiftDetail.put("shiftType", schedule.getShiftType());
                    shiftDetail.put("shiftName", getShiftName(schedule.getShiftType()));
                    shiftDetail.put("wardArea", schedule.getWardArea());
                    shiftDetail.put("bedCount", schedule.getBedCount());
                    shiftDetail.put("patientCount", schedule.getPatientIds() != null ? schedule.getPatientIds().split(",").length : 0);
                    shiftDetail.put("status", schedule.getStatus());
                    shiftDetail.put("statusText", getStatusText(schedule.getStatus()));
                    shiftDetail.put("remark", schedule.getRemark());
                    shiftDetails.add(shiftDetail);
                }
                dayDetail.put("shifts", shiftDetails);
            } else {
                dayDetail.put("isRest", true);
            }

            detailList.add(dayDetail);
            calendar.add(Calendar.DATE, 1);
        }

        return detailList;
    }

    private String getShiftName(Integer shiftType) {
        if (shiftType == null) return "未知";
        switch (shiftType) {
            case 1: return "早班";
            case 2: return "中班";
            case 3: return "夜班";
            default: return "未知";
        }
    }

    private String getStatusText(Integer status) {
        if (status == null) return "未知";
        switch (status) {
            case 0: return "请假/调休";
            case 1: return "正常排班";
            case 2: return "替班";
            case 3: return "加班";
            default: return "未知";
        }
    }
}
