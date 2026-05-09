package com.example.medical.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.AbnormalLogin;
import com.example.medical.mapper.AbnormalLoginMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 异常登录检测服务类
 */
@Service
public class AbnormalLoginService {

    @Autowired
    private AbnormalLoginMapper abnormalLoginMapper;

    /**
     * 记录异常登录
     */
    public AbnormalLogin record(AbnormalLogin abnormalLogin) {
        abnormalLogin.setIsHandled(0);
        abnormalLogin.setCreatedAt(LocalDateTime.now());
        abnormalLoginMapper.insert(abnormalLogin);
        return abnormalLogin;
    }

    /**
     * 获取异常登录列表
     */
    public Page<AbnormalLogin> getList(Long userId, LocalDateTime startDate, LocalDateTime endDate, int page, int pageSize) {
        Page<AbnormalLogin> pageParam = new Page<>(page, pageSize);
        QueryWrapper<AbnormalLogin> queryWrapper = new QueryWrapper<>();
        
        if (userId != null) {
            queryWrapper.eq("user_id", userId);
        }
        
        if (startDate != null) {
            queryWrapper.ge("login_time", startDate);
        }
        
        if (endDate != null) {
            queryWrapper.le("login_time", endDate);
        }
        
        queryWrapper.orderByDesc("login_time");
        
        return abnormalLoginMapper.selectPage(pageParam, queryWrapper);
    }

    /**
     * 处理异常登录
     */
    public AbnormalLogin handle(Long id) {
        AbnormalLogin abnormalLogin = abnormalLoginMapper.selectById(id);
        if (abnormalLogin == null) {
            throw new IllegalArgumentException("异常登录记录不存在");
        }
        
        abnormalLogin.setIsHandled(1);
        abnormalLoginMapper.updateById(abnormalLogin);
        
        return abnormalLogin;
    }

    /**
     * 获取未处理的异常登录数量
     */
    public long getUnhandledCount() {
        QueryWrapper<AbnormalLogin> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_handled", 0);
        return abnormalLoginMapper.selectCount(queryWrapper);
    }

    /**
     * 获取高风险异常登录列表
     */
    public List<AbnormalLogin> getHighRiskList() {
        QueryWrapper<AbnormalLogin> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("risk_level", "high");
        queryWrapper.eq("is_handled", 0);
        queryWrapper.orderByDesc("login_time");
        
        return abnormalLoginMapper.selectList(queryWrapper);
    }
}
