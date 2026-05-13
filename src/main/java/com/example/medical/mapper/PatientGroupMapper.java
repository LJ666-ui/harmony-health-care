package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.PatientGroup;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 患者分组Mapper接口
 */
@Mapper
public interface PatientGroupMapper extends BaseMapper<PatientGroup> {

    /**
     * 根据医生ID查询分组列表
     * @param doctorId 医生ID
     * @return 分组列表
     */
    @Select("SELECT * FROM patient_group WHERE doctor_id = #{doctorId} AND is_deleted = 0 ORDER BY sort_order ASC")
    List<PatientGroup> selectByDoctorId(@Param("doctorId") Long doctorId);

    /**
     * 根据医生ID统计分组数量
     * @param doctorId 医生ID
     * @return 分组数量
     */
    @Select("SELECT COUNT(*) FROM patient_group WHERE doctor_id = #{doctorId} AND is_deleted = 0")
    int countByDoctorId(@Param("doctorId") Long doctorId);
}
