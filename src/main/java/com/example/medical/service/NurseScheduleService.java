package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.NurseSchedule;

import java.util.Date;
import java.util.List;
import java.util.Map;

public interface NurseScheduleService extends IService<NurseSchedule> {

    List<NurseSchedule> getByNurseIdAndDateRange(Long nurseId, Date startDate, Date endDate);

    List<NurseSchedule> getByDateAndShift(Date date, Integer shiftType);

    List<NurseSchedule> getByDate(Date date);

    List<NurseSchedule> getByDepartmentAndDate(String department, Date date);

    Map<String, Object> getWeeklySchedule(Long nurseId, Date startDate);

    Map<String, Object> getDailyOverview(Date date);

    List<Map<String, Object>> getNurseScheduleDetail(Long nurseId, int days);
}
