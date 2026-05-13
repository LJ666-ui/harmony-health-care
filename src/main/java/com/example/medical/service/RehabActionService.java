package com.example.medical.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.RehabAction;

import java.util.Map;

public interface RehabActionService extends IService<RehabAction> {
    /**
     * 分页查询动作列表
     * @param pageNum 页码
     * @param pageSize 每页大小（默认10条）
     * @return 分页结果
     */
    Page<RehabAction> getActionList(int pageNum, int pageSize, String keyword);

    /**
     * 根据ID查询动作详情
     * @param id 动作ID
     * @return 动作详情（包含难度分级）
     */
    Map<String, Object> getActionDetail(Long id);

    /**
     * 计算动作难度分级
     * @param action 动作实体
     * @return 难度分级（容易、中等、困难）
     */
    String calculateDifficulty(RehabAction action);

    /**
     * 创建动作
     * @param action 动作实体
     * @return 创建结果
     */
    boolean createAction(RehabAction action);

    /**
     * 更新动作
     * @param action 动作实体
     * @return 更新结果
     */
    boolean updateAction(RehabAction action);

    /**
     * 删除动作（逻辑删除）
     * @param id 动作ID
     * @return 删除结果
     */
    boolean deleteAction(Long id);
}