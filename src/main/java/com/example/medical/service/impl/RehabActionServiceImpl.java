package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.RehabAction;
import com.example.medical.mapper.RehabActionMapper;
import com.example.medical.service.RehabActionService;
import org.springframework.stereotype.Service;

import java.util.Date; // 【关键修复】导入 Date 类
import java.util.HashMap;
import java.util.Map;

@Service
public class RehabActionServiceImpl extends ServiceImpl<RehabActionMapper, RehabAction> implements RehabActionService {

    @Override
    public Page<RehabAction> getActionList(int pageNum, int pageSize, String keyword) {
        if (pageSize <= 0) {
            pageSize = 20;
        }

        QueryWrapper<RehabAction> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_deleted", 0);

        if (keyword != null && !keyword.trim().isEmpty()) {
            queryWrapper.and(w -> w.like("action_name", keyword.trim())
                    .or().like("action_desc", keyword.trim()));
        }

        queryWrapper.orderByAsc("id");

        return this.page(new Page<>(pageNum, pageSize), queryWrapper);
    }

    @Override
    public Map<String, Object> getActionDetail(Long id) {
        RehabAction action = this.getById(id);
        if (action == null) {
            return null;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("action", action);
        result.put("difficulty", calculateDifficulty(action));

        return result;
    }

    @Override
    public String calculateDifficulty(RehabAction action) {
        if (action == null) {
            return "未知";
        }

        // 处理null值：使用Objects.requireNonNullElse简化代码
        Integer duration = action.getDuration() != null ? action.getDuration() : 0;
        Integer sets = action.getSets() != null ? action.getSets() : 0;
        Integer reps = action.getReps() != null ? action.getReps() : 0;

        // 困难：满足任意一项
        if (duration > 60 || sets > 3 || reps > 15) {
            return "困难";
        }
        // 中等：满足任意一项
        else if ((duration > 30 && duration <= 60) || (sets > 2 && sets <= 3) || (reps > 10 && reps <= 15)) {
            return "中等";
        }
        // 容易
        else {
            return "容易";
        }
    }

    @Override
    public boolean createAction(RehabAction action) {
        action.setIsDeleted(0);
        action.setCreateTime(new Date());
        action.setUpdateTime(new Date());
        return this.save(action);
    }

    @Override
    public boolean updateAction(RehabAction action) {
        action.setUpdateTime(new Date());
        return this.updateById(action);
    }

    @Override
    public boolean deleteAction(Long id) {
        RehabAction action = new RehabAction();
        action.setId(id);
        action.setIsDeleted(1);
        action.setUpdateTime(new Date());
        return this.updateById(action);
    }
}