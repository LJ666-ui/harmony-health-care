package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.RehabAction;
import com.example.medical.service.RehabActionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/rehab/action")
public class RehabActionController {

    @Autowired
    private RehabActionService rehabActionService;

    /**
     * 分页查询动作列表
     * @param pageNum 页码（默认1）
     * @param pageSize 每页大小（默认10）
     * @return 分页结果
     */
    @GetMapping("/list")
    public Result getActionList(
            @RequestParam(defaultValue = "1") int pageNum,
            @RequestParam(defaultValue = "10") int pageSize) {
        Page<RehabAction> page = rehabActionService.getActionList(pageNum, pageSize);
        return Result.success(page);
    }

    /**
     * 查询动作详情
     * @param id 动作ID
     * @return 动作详情（包含难度分级）
     */
    @GetMapping("/detail/{id}")
    public Result getActionDetail(@PathVariable Long id) {
        Map<String, Object> detail = rehabActionService.getActionDetail(id);
        if (detail == null) {
            return Result.error("动作不存在");
        }
        return Result.success(detail);
    }

    /**
     * 计算动作难度
     * @param action 动作实体
     * @return 难度分级
     */
    @PostMapping("/difficulty")
    public Result calculateDifficulty(@RequestBody RehabAction action) {
        String difficulty = rehabActionService.calculateDifficulty(action);

        return Result.success(difficulty);
    }

    /**
     * 创建动作
     * @param action 动作实体
     * @return 创建结果
     */
    @PostMapping("/create")
    public Result createAction(@RequestBody RehabAction action) {
        boolean success = rehabActionService.createAction(action);
        if (success) {
            return Result.success("动作创建成功");
        } else {
            return Result.error("动作创建失败");
        }
    }

    /**
     * 更新动作
     * @param action 动作实体
     * @return 更新结果
     */
    @PostMapping("/update")
    public Result updateAction(@RequestBody RehabAction action) {
        boolean success = rehabActionService.updateAction(action);
        if (success) {
            return Result.success("动作更新成功");
        } else {
            return Result.error("动作更新失败");
        }
    }

    /**
     * 删除动作
     * @param id 动作ID
     * @return 删除结果
     */
    @PostMapping("/delete/{id}")
    public Result deleteAction(@PathVariable Long id) {
        boolean success = rehabActionService.deleteAction(id);
        if (success) {
            return Result.success("动作删除成功");
        } else {
            return Result.error("动作删除失败");
        }
    }
}