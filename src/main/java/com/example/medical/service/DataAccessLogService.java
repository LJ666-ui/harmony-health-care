package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.DataAccessLog;

import java.util.List;

public interface DataAccessLogService extends IService<DataAccessLog> {
    /**
     * 记录访问日志
     * @param userId 数据所属用户ID
     * @param accessUserId 访问者用户ID
     * @param dataType 数据类型
     * @param dataId 访问数据ID
     * @param isAuthorized 是否授权访问
     * @param accessIp 访问IP
     * @return 记录的日志
     */
    DataAccessLog recordAccessLog(Long userId, Long accessUserId, String dataType, Long dataId, Integer isAuthorized, String accessIp);

    /**
     * 查询用户的访问日志
     * @param userId 数据所属用户ID
     * @return 访问日志列表
     */
    List<DataAccessLog> getAccessLogsByUserId(Long userId);

    /**
     * 查询访问者的访问日志
     * @param accessUserId 访问者用户ID
     * @return 访问日志列表
     */
    List<DataAccessLog> getAccessLogsByAccessUserId(Long accessUserId);

    /**
     * 按数据类型查询访问日志
     * @param dataType 数据类型
     * @return 访问日志列表
     */
    List<DataAccessLog> getAccessLogsByDataType(String dataType);
}