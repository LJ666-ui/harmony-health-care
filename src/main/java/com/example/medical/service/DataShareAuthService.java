package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DataShareAuth;

import java.util.Date;
import java.util.List;

public interface DataShareAuthService extends IService<DataShareAuth> {
    /**
     * 创建授权
     * @param userId 数据所属用户ID（患者本人）
     * @param authUserId 被授权用户ID（医生）
     * @param dataType 授权数据类型
     * @param authStartTime 授权开始时间
     * @param authEndTime 授权结束时间
     * @return 创建的授权记录
     */
    DataShareAuth createAuth(Long userId, Long authUserId, String dataType, Date authStartTime, Date authEndTime);

    /**
     * 撤销授权
     * @param authId 授权ID
     * @return 是否撤销成功
     */
    boolean revokeAuth(Long authId);

    /**
     * 查询授权列表
     * @param userId 患者ID
     * @param authUserId 医生ID
     * @param dataType 数据类型
     * @return 授权列表
     */
    List<DataShareAuth> getAuthList(Long userId, Long authUserId, String dataType);

    /**
     * 授权校验核心逻辑
     * @param accessUserId 当前访问者ID
     * @param targetUserId 患者ID
     * @param dataType 数据类型
     * @return 是否有访问权限
     */
    boolean checkAuth(Long accessUserId, Long targetUserId, String dataType);
}