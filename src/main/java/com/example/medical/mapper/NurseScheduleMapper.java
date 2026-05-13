package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.NurseSchedule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.Date;
import java.util.List;

@Mapper
public interface NurseScheduleMapper extends BaseMapper<NurseSchedule> {

    @Select("SELECT * FROM nurse_schedule WHERE nurse_id = #{nurseId} AND schedule_date >= #{startDate} AND schedule_date <= #{endDate} AND is_deleted = 0 ORDER BY schedule_date, shift_type")
    List<NurseSchedule> findByNurseIdAndDateRange(@Param("nurseId") Long nurseId, @Param("startDate") Date startDate, @Param("endDate") Date endDate);

    @Select("SELECT * FROM nurse_schedule WHERE schedule_date = #{date} AND shift_type = #{shiftType} AND is_deleted = 0 ORDER BY nurse_id")
    List<NurseSchedule> findByDateAndShift(@Param("date") Date date, @Param("shiftType") Integer shiftType);

    @Select("SELECT * FROM nurse_schedule WHERE schedule_date = #{date} AND is_deleted = 0 ORDER BY shift_type, nurse_id")
    List<NurseSchedule> findByDate(@Param("date") Date date);

    @Select("SELECT * FROM nurse_schedule WHERE department = #{department} AND schedule_date = #{date} AND is_deleted = 0 ORDER BY shift_type, nurse_id")
    List<NurseSchedule> findByDepartmentAndDate(@Param("department") String department, @Param("date") Date date);
}
