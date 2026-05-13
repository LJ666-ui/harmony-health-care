package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.ExampleEntity;
import com.example.medical.service.ExampleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

/**
 * 示例模块Controller
 * 演示标准的三层架构和RESTful API设计
 *
 * @author Nebula Medical Team
 * @date 2026-05-06
 */
@RestController
@RequestMapping("/example")
@CrossOrigin
@Validated
@Tag(name = "示例模块管理")
public class ExampleController {

    @Autowired
    private ExampleService exampleService;

    /**
     * 创建资源
     * POST /example/create
     */
    @PostMapping("/create")
    @Operation(summary = "创建资源", description = "创建新的示例资源")
    public Result<?> create(@Valid @RequestBody ExampleEntity entity) {
        // 参数校验
        if (entity.getName() == null || entity.getName().trim().isEmpty()) {
            return Result.error("名称不能为空");
        }

        // 检查重复
        ExampleEntity existing = exampleService.findByName(entity.getName());
        if (existing != null) {
            return Result.error("名称已存在");
        }

        // 调用Service保存
        if (exampleService.save(entity)) {
            Map<String, Object> result = new HashMap<>();
            result.put("id", entity.getId());
            result.put("message", "创建成功");
            return Result.success(result);
        } else {
            return Result.error("创建失败");
        }
    }

    /**
     * 分页查询列表
     * GET /example/list?current=1&size=10&keyword=xxx
     */
    @GetMapping("/list")
    @Operation(summary = "分页查询", description = "分页查询示例资源列表")
    public Result<?> list(
        @Parameter(description = "当前页") @RequestParam(defaultValue = "1") Integer current,
        @Parameter(description = "每页数量") @RequestParam(defaultValue = "10") Integer size,
        @Parameter(description = "搜索关键词") @RequestParam(required = false) String keyword,
        @Parameter(description = "状态") @RequestParam(required = false) Integer status
    ) {
        Page<ExampleEntity> page = new Page<>(current, size);
        LambdaQueryWrapper<ExampleEntity> wrapper = new LambdaQueryWrapper<>();

        // 关键词搜索
        if (keyword != null && !keyword.trim().isEmpty()) {
            wrapper.like(ExampleEntity::getName, keyword)
                   .or()
                   .like(ExampleEntity::getDescription, keyword);
        }

        // 状态筛选
        if (status != null) {
            wrapper.eq(ExampleEntity::getStatus, status);
        }

        // 排序
        wrapper.orderByDesc(ExampleEntity::getCreateTime);

        Page<ExampleEntity> result = exampleService.page(page, wrapper);
        return Result.success(result);
    }

    /**
     * 根据ID查询详情
     * GET /example/{id}
     */
    @GetMapping("/{id}")
    @Operation(summary = "查询详情", description = "根据ID查询示例资源详情")
    public Result<?> getById(@Parameter(description = "资源ID") @PathVariable Long id) {
        if (id == null || id <= 0) {
            return Result.error("ID无效");
        }

        ExampleEntity entity = exampleService.getById(id);
        if (entity == null) {
            return Result.error("资源不存在");
        }

        return Result.success(entity);
    }

    /**
     * 更新资源
     * PUT /example/{id}
     */
    @PutMapping("/{id}")
    @Operation(summary = "更新资源", description = "根据ID更新示例资源信息")
    public Result<?> update(
        @Parameter(description = "资源ID") @PathVariable Long id,
        @Valid @RequestBody ExampleEntity entity
    ) {
        if (id == null || id <= 0) {
            return Result.error("ID无效");
        }

        // 检查资源是否存在
        ExampleEntity existing = exampleService.getById(id);
        if (existing == null) {
            return Result.error("资源不存在");
        }

        // 设置ID并更新
        entity.setId(id);
        if (exampleService.updateById(entity)) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }

    /**
     * 删除资源
     * DELETE /example/{id}
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "删除资源", description = "根据ID删除示例资源")
    public Result<?> delete(@Parameter(description = "资源ID") @PathVariable Long id) {
        if (id == null || id <= 0) {
            return Result.error("ID无效");
        }

        // 检查资源是否存在
        ExampleEntity existing = exampleService.getById(id);
        if (existing == null) {
            return Result.error("资源不存在");
        }

        // 删除资源
        if (exampleService.removeById(id)) {
            return Result.success("删除成功");
        } else {
            return Result.error("删除失败");
        }
    }

    /**
     * 批量删除
     * DELETE /example/batch
     */
    @DeleteMapping("/batch")
    @Operation(summary = "批量删除", description = "批量删除示例资源")
    public Result<?> batchDelete(@RequestBody Long[] ids) {
        if (ids == null || ids.length == 0) {
            return Result.error("请选择要删除的资源");
        }

        int successCount = 0;
        for (Long id : ids) {
            if (exampleService.removeById(id)) {
                successCount++;
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("total", ids.length);
        result.put("success", successCount);
        result.put("message", String.format("成功删除%d个资源", successCount));

        return Result.success(result);
    }

    /**
     * 更新状态
     * PUT /example/{id}/status
     */
    @PutMapping("/{id}/status")
    @Operation(summary = "更新状态", description = "更新资源状态")
    public Result<?> updateStatus(
        @Parameter(description = "资源ID") @PathVariable Long id,
        @Parameter(description = "状态值") @RequestParam Integer status
    ) {
        if (id == null || id <= 0) {
            return Result.error("ID无效");
        }

        ExampleEntity entity = exampleService.getById(id);
        if (entity == null) {
            return Result.error("资源不存在");
        }

        entity.setStatus(status);
        if (exampleService.updateById(entity)) {
            return Result.success("状态更新成功");
        } else {
            return Result.error("状态更新失败");
        }
    }

    /**
     * 统计数量
     * GET /example/count
     */
    @GetMapping("/count")
    @Operation(summary = "统计数量", description = "统计资源总数")
    public Result<?> count(@Parameter(description = "状态") @RequestParam(required = false) Integer status) {
        LambdaQueryWrapper<ExampleEntity> wrapper = new LambdaQueryWrapper<>();

        if (status != null) {
            wrapper.eq(ExampleEntity::getStatus, status);
        }

        long count = exampleService.count(wrapper);
        return Result.success(count);
    }
}
