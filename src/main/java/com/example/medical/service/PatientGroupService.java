package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.common.BusinessException;
import com.example.medical.common.ResponseCode;
import com.example.medical.dto.DoctorPatientDTO;
import com.example.medical.entity.PatientGroup;
import com.example.medical.entity.PatientGroupRelation;
import com.example.medical.entity.User;
import com.example.medical.mapper.PatientGroupMapper;
import com.example.medical.mapper.PatientGroupRelationMapper;
import com.example.medical.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 患者分组服务类
 */
@Service
public class PatientGroupService {

    @Autowired
    private PatientGroupMapper patientGroupMapper;

    @Autowired
    private PatientGroupRelationMapper patientGroupRelationMapper;

    @Autowired
    private UserMapper userMapper;

    /**
     * 创建患者分组
     */
    public PatientGroup createGroup(PatientGroup group) {
        // 检查分组名称是否重复
        QueryWrapper<PatientGroup> wrapper = new QueryWrapper<>();
        wrapper.eq("doctor_id", group.getDoctorId())
               .eq("group_name", group.getGroupName())
               .eq("is_deleted", 0);
        
        if (patientGroupMapper.selectCount(wrapper) > 0) {
            throw new BusinessException(ResponseCode.PARAM_ERROR.getCode(), "分组名称已存在");
        }

        group.setCreateTime(new Date());
        group.setUpdateTime(new Date());
        group.setIsDeleted(0);
        
        patientGroupMapper.insert(group);
        return group;
    }

    /**
     * 获取医生的所有分组
     */
    public List<PatientGroup> getGroupsByDoctorId(Long doctorId) {
        return patientGroupMapper.selectByDoctorId(doctorId);
    }

    /**
     * 更新分组信息
     */
    public PatientGroup updateGroup(PatientGroup group) {
        group.setUpdateTime(new Date());
        patientGroupMapper.updateById(group);
        return group;
    }

    /**
     * 删除分组（逻辑删除）
     */
    @Transactional
    public void deleteGroup(Long groupId) {
        // 逻辑删除分组
        PatientGroup group = patientGroupMapper.selectById(groupId);
        if (group == null) {
            throw new BusinessException(ResponseCode.NOT_FOUND.getCode(), "分组不存在");
        }

        group.setIsDeleted(1);
        group.setUpdateTime(new Date());
        patientGroupMapper.updateById(group);

        // 删除分组关系
        patientGroupRelationMapper.deleteByGroupId(groupId);
    }

    /**
     * 添加患者到分组
     */
    @Transactional
    public void addPatientToGroup(Long groupId, Long patientId) {
        // 检查分组是否存在
        PatientGroup group = patientGroupMapper.selectById(groupId);
        if (group == null || group.getIsDeleted() == 1) {
            throw new BusinessException(ResponseCode.NOT_FOUND.getCode(), "分组不存在");
        }

        // 检查是否已在分组中
        QueryWrapper<PatientGroupRelation> wrapper = new QueryWrapper<>();
        wrapper.eq("group_id", groupId).eq("patient_id", patientId);
        
        if (patientGroupRelationMapper.selectCount(wrapper) > 0) {
            throw new BusinessException(ResponseCode.PARAM_ERROR.getCode(), "患者已在分组中");
        }

        // 添加关系
        PatientGroupRelation relation = new PatientGroupRelation();
        relation.setGroupId(groupId);
        relation.setPatientId(patientId);
        relation.setCreateTime(new Date());
        
        patientGroupRelationMapper.insert(relation);
    }

    /**
     * 批量添加患者到分组
     */
    @Transactional
    public void addPatientsToGroup(Long groupId, List<Long> patientIds) {
        for (Long patientId : patientIds) {
            try {
                addPatientToGroup(groupId, patientId);
            } catch (BusinessException e) {
                // 忽略已存在的患者
                if (!e.getMessage().contains("已在分组中")) {
                    throw e;
                }
            }
        }
    }

    /**
     * 从分组中移除患者
     */
    public void removePatientFromGroup(Long groupId, Long patientId) {
        QueryWrapper<PatientGroupRelation> wrapper = new QueryWrapper<>();
        wrapper.eq("group_id", groupId).eq("patient_id", patientId);
        
        patientGroupRelationMapper.delete(wrapper);
    }

    /**
     * 获取分组中的患者ID列表
     */
    public List<Long> getPatientIdsByGroupId(Long groupId) {
        return patientGroupRelationMapper.selectPatientIdsByGroupId(groupId);
    }

    /**
     * 获取患者所属的分组列表
     */
    public List<PatientGroup> getGroupsByPatientId(Long patientId) {
        List<Long> groupIds = patientGroupRelationMapper.selectGroupIdsByPatientId(patientId);
        
        if (groupIds.isEmpty()) {
            return new ArrayList<>();
        }

        QueryWrapper<PatientGroup> wrapper = new QueryWrapper<>();
        wrapper.in("id", groupIds).eq("is_deleted", 0);
        
        return patientGroupMapper.selectList(wrapper);
    }

    /**
     * 统计分组中的患者数量
     */
    public int countPatientsInGroup(Long groupId) {
        return patientGroupRelationMapper.countPatientsByGroupId(groupId);
    }

    /**
     * 获取医生的所有患者详细信息（包含用户信息和分组信息）
     */
    public List<DoctorPatientDTO> getDoctorPatientsWithDetails(Long doctorId) {
        // 1. 获取医生的所有分组
        List<PatientGroup> groups = patientGroupMapper.selectByDoctorId(doctorId);
        
        List<DoctorPatientDTO> result = new ArrayList<>();
        
        // 2. 遍历每个分组，获取其中的患者
        for (PatientGroup group : groups) {
            if (group.getIsDeleted() != null && group.getIsDeleted() == 1) {
                continue; // 跳过已删除的分组
            }
            
            // 3. 获取该分组中的所有患者ID
            List<Long> patientIds = patientGroupRelationMapper.selectPatientIdsByGroupId(group.getId());
            
            // 4. 根据患者ID查询用户详细信息（只查询user_type=0的患者）
            if (!patientIds.isEmpty()) {
                QueryWrapper<User> userWrapper = new QueryWrapper<>();
                userWrapper.in("id", patientIds)
                          .eq("user_type", 0)  // 只查询患者类型
                          .eq("is_deleted", 0);
                
                List<User> patients = userMapper.selectList(userWrapper);
                
                // 5. 组装返回结果
                for (User patient : patients) {
                    DoctorPatientDTO dto = new DoctorPatientDTO();
                    dto.setPatientId(patient.getId());
                    dto.setUsername(patient.getUsername());
                    dto.setPhone(patient.getPhone());
                    dto.setAge(patient.getAge());
                    dto.setIdCard(patient.getIdCard());
                    dto.setGroupId(group.getId());
                    dto.setGroupName(group.getGroupName());
                    
                    result.add(dto);
                }
            }
        }
        
        return result;
    }
}
