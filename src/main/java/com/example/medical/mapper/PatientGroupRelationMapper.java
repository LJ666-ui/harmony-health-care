package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.PatientGroupRelation;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 患者分组关系Mapper接口
 */
@Mapper
public interface PatientGroupRelationMapper extends BaseMapper<PatientGroupRelation> {

    /**
     * 根据分组ID查询患者ID列表
     * @param groupId 分组ID
     * @return 患者ID列表
     */
    @Select("SELECT patient_id FROM patient_group_relation WHERE group_id = #{groupId}")
    List<Long> selectPatientIdsByGroupId(@Param("groupId") Long groupId);

    /**
     * 根据患者ID查询分组ID列表
     * @param patientId 患者ID
     * @return 分组ID列表
     */
    @Select("SELECT group_id FROM patient_group_relation WHERE patient_id = #{patientId}")
    List<Long> selectGroupIdsByPatientId(@Param("patientId") Long patientId);

    /**
     * 统计分组中的患者数量
     * @param groupId 分组ID
     * @return 患者数量
     */
    @Select("SELECT COUNT(*) FROM patient_group_relation WHERE group_id = #{groupId}")
    int countPatientsByGroupId(@Param("groupId") Long groupId);

    /**
     * 删除分组中的所有患者关系
     * @param groupId 分组ID
     * @return 删除数量
     */
    @Select("DELETE FROM patient_group_relation WHERE group_id = #{groupId}")
    int deleteByGroupId(@Param("groupId") Long groupId);
}
