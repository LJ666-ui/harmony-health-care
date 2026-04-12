package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.DataShareAuth;
import com.example.medical.mapper.DataShareAuthMapper;
import com.example.medical.service.DataShareAuthService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class DataShareAuthServiceImpl extends ServiceImpl<DataShareAuthMapper, DataShareAuth> implements DataShareAuthService {
    @Override
    public DataShareAuth createAuth(Long userId, Long authUserId, String dataType, Date authStartTime, Date authEndTime) {
        // 校验时间是否合法
        if (authEndTime.before(authStartTime)) {
            throw new IllegalArgumentException("结束时间不能早于开始时间");
        }

        // 创建授权记录
        DataShareAuth auth = new DataShareAuth();
        auth.setUserId(userId);
        auth.setAuthUserId(authUserId);
        auth.setDataType(dataType);
        auth.setAuthStartTime(authStartTime);
        auth.setAuthEndTime(authEndTime);
        auth.setStatus(1); // 1=有效
        auth.setIsDeleted(0);
        auth.setCreateTime(new Date());
        auth.setUpdateTime(new Date());

        // 保存到数据库
        save(auth);
        return auth;
    }

    @Override
    public boolean revokeAuth(Long authId) {
        // 查找授权记录
        DataShareAuth auth = getById(authId);
        if (auth == null || auth.getIsDeleted() == 1) {
            return false;
        }

        // 修改状态为已撤销
        auth.setStatus(0);
        auth.setUpdateTime(new Date());
        return updateById(auth);
    }

    @Override
    public List<DataShareAuth> getAuthList(Long userId, Long authUserId, String dataType) {
        LambdaQueryWrapper<DataShareAuth> wrapper = new LambdaQueryWrapper<>();
        
        // 过滤已删除的记录
        wrapper.eq(DataShareAuth::getIsDeleted, 0);
        
        // 按条件筛选
        if (userId != null) {
            wrapper.eq(DataShareAuth::getUserId, userId);
        }
        if (authUserId != null) {
            wrapper.eq(DataShareAuth::getAuthUserId, authUserId);
        }
        if (dataType != null && !dataType.isEmpty()) {
            wrapper.eq(DataShareAuth::getDataType, dataType);
        }

        return list(wrapper);
    }

    @Override
    public boolean checkAuth(Long accessUserId, Long targetUserId, String dataType) {
        // 构建查询条件
        LambdaQueryWrapper<DataShareAuth> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DataShareAuth::getUserId, targetUserId);
        wrapper.eq(DataShareAuth::getAuthUserId, accessUserId);
        wrapper.eq(DataShareAuth::getDataType, dataType);
        wrapper.eq(DataShareAuth::getStatus, 1); // 状态有效
        wrapper.eq(DataShareAuth::getIsDeleted, 0); // 未删除
        
        // 时间范围检查
        Date now = new Date();
        wrapper.le(DataShareAuth::getAuthStartTime, now);
        wrapper.ge(DataShareAuth::getAuthEndTime, now);

        // 查询是否存在有效的授权记录
        return count(wrapper) > 0;
    }
}