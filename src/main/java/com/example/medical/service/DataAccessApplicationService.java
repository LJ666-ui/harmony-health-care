package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.BusinessException;
import com.example.medical.common.ResponseCode;
import com.example.medical.entity.DataAccessApplication;
import com.example.medical.mapper.DataAccessApplicationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 数据访问审批服务类
 */
@Service
public class DataAccessApplicationService {

    @Autowired
    private DataAccessApplicationMapper dataAccessApplicationMapper;

    /**
     * 申请数据访问
     */
    public DataAccessApplication apply(DataAccessApplication application) {
        // 设置初始状态
        application.setStatus("pending");
        application.setCreatedAt(LocalDateTime.now());
        application.setUpdatedAt(LocalDateTime.now());
        
        // 保存申请
        dataAccessApplicationMapper.insert(application);
        return application;
    }

    /**
     * 审批数据访问
     */
    public DataAccessApplication approve(Long id, Long approverId, boolean approved, String comment) {
        DataAccessApplication application = dataAccessApplicationMapper.selectById(id);
        if (application == null) {
            throw new BusinessException(ResponseCode.DATA_ACCESS_APPLICATION_NOT_FOUND);
        }
        
        if (!"pending".equals(application.getStatus())) {
            throw new BusinessException(ResponseCode.DATA_ACCESS_ALREADY_APPROVED);
        }
        
        // 更新审批信息
        application.setApproverId(approverId);
        application.setStatus(approved ? "approved" : "rejected");
        application.setApprovedAt(LocalDateTime.now());
        
        // 如果批准，设置过期时间
        if (approved) {
            application.setExpiresAt(LocalDateTime.now().plusHours(application.getDuration()));
        }
        
        application.setUpdatedAt(LocalDateTime.now());
        dataAccessApplicationMapper.updateById(application);
        
        return application;
    }

    /**
     * 获取待审批列表
     */
    public Page<DataAccessApplication> getPendingList(Long approverId, int page, int pageSize) {
        Page<DataAccessApplication> pageParam = new Page<>(page, pageSize);
        QueryWrapper<DataAccessApplication> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "pending");
        queryWrapper.orderByDesc("created_at");
        
        return dataAccessApplicationMapper.selectPage(pageParam, queryWrapper);
    }

    /**
     * 获取申请详情
     */
    public DataAccessApplication getById(Long id) {
        return dataAccessApplicationMapper.selectById(id);
    }

    /**
     * 获取用户的申请列表
     */
    public List<DataAccessApplication> getByRequesterId(Long requesterId) {
        QueryWrapper<DataAccessApplication> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("requester_id", requesterId);
        queryWrapper.orderByDesc("created_at");
        
        return dataAccessApplicationMapper.selectList(queryWrapper);
    }

    /**
     * 检查访问权限
     */
    public boolean checkAccessPermission(Long requesterId, String dataType, Long dataId) {
        QueryWrapper<DataAccessApplication> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("requester_id", requesterId);
        queryWrapper.eq("data_type", dataType);
        queryWrapper.eq("data_id", dataId);
        queryWrapper.eq("status", "approved");
        queryWrapper.gt("expires_at", LocalDateTime.now());
        
        return dataAccessApplicationMapper.selectCount(queryWrapper) > 0;
    }
}
