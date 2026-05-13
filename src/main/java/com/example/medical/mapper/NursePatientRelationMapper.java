package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.NursePatientRelation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface NursePatientRelationMapper extends BaseMapper<NursePatientRelation> {
    
    @Select("SELECT patient_id FROM nurse_patient_relation " +
            "WHERE nurse_id = #{nurseId} AND is_deleted = 0")
    List<Long> selectPatientIdsByNurseId(@Param("nurseId") Long nurseId);
}
