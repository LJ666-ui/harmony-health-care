package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.NursingRecord;
import com.example.medical.service.NursingRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * 护理记录控制器
 */
@RestController
@RequestMapping("/api/nursing-record")
@CrossOrigin
@Tag(name = "护理记录管理", description = "护理记录相关接口")
public class NursingRecordController {

    @Autowired
    private NursingRecordService nursingRecordService;

    @PostMapping
    @Operation(summary = "创建护理记录")
    public Result<NursingRecord> createRecord(
            @RequestBody NursingRecord record,
            HttpServletRequest request) {
        try {
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
                try {
                    // 尝试获取护士ID
                    Long nurseId = JwtUtil.getNurseId(token);
                    if (nurseId != null) {
                        record.setNurseId(nurseId);
                    } else {
                        // 如果不是护士Token，尝试获取普通用户ID
                        Long userId = JwtUtil.getUserId(token);
                        if (userId != null) {
                            // 使用用户ID作为护士ID（或根据业务逻辑调整）
                            record.setNurseId(userId);
                        }
                    }
                } catch (Exception e) {
                    System.out.println("[NursingRecordController] Token解析失败，继续执行: " + e.getMessage());
                }
            }
            
            // 如果前端传入了nurseId，使用前端的值
            // 注意：这里优先使用Token中的nurseId，如果没有则使用请求体中的
            
            if (record.getPatientId() == null) {
                return Result.error("患者ID不能为空");
            }
            if (record.getRecordType() == null) {
                return Result.error("护理记录类型不能为空");
            }
            if (record.getRecordContent() == null || record.getRecordContent().trim().isEmpty()) {
                return Result.error("护理记录内容不能为空");
            }
            
            NursingRecord created = nursingRecordService.createRecord(record);
            return Result.success(created);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("创建护理记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据ID获取护理记录")
    public Result<NursingRecord> getRecordById(@PathVariable Long id) {
        try {
            NursingRecord record = nursingRecordService.getById(id);
            if (record == null || record.getIsDeleted() == 1) {
                return Result.error("护理记录不存在");
            }
            return Result.success(record);
        } catch (Exception e) {
            return Result.error("获取护理记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/patient/{patientId}")
    @Operation(summary = "获取患者的护理记录列表")
    public Result<List<NursingRecord>> getRecordsByPatientId(@PathVariable Long patientId) {
        try {
            List<NursingRecord> records = nursingRecordService.getRecordsByPatientId(patientId);
            return Result.success(records);
        } catch (Exception e) {
            return Result.error("获取护理记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/nurse/{nurseId}")
    @Operation(summary = "获取护士的护理记录列表")
    public Result<List<NursingRecord>> getRecordsByNurseId(@PathVariable Long nurseId) {
        try {
            List<NursingRecord> records = nursingRecordService.getRecordsByNurseId(nurseId);
            return Result.success(records);
        } catch (Exception e) {
            return Result.error("获取护理记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/list")
    @Operation(summary = "分页查询护理记录")
    public Result<Page<NursingRecord>> getRecordsPage(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) Long nurseId,
            @RequestParam(required = false) Integer recordType) {
        try {
            Page<NursingRecord> page = new Page<>(pageNum, pageSize);
            LambdaQueryWrapper<NursingRecord> wrapper = new LambdaQueryWrapper<>();
            
            wrapper.eq(NursingRecord::getIsDeleted, 0);
            
            if (patientId != null) {
                wrapper.eq(NursingRecord::getPatientId, patientId);
            }
            if (nurseId != null) {
                wrapper.eq(NursingRecord::getNurseId, nurseId);
            }
            if (recordType != null) {
                wrapper.eq(NursingRecord::getRecordType, recordType);
            }
            
            wrapper.orderByDesc(NursingRecord::getCareTime);
            
            Page<NursingRecord> resultPage = nursingRecordService.page(page, wrapper);
            return Result.success(resultPage);
        } catch (Exception e) {
            return Result.error("获取护理记录失败：" + e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新护理记录")
    public Result<NursingRecord> updateRecord(
            @PathVariable Long id,
            @RequestBody NursingRecord record) {
        try {
            NursingRecord updated = nursingRecordService.updateRecord(id, record);
            if (updated == null) {
                return Result.error("护理记录不存在或已被删除");
            }
            return Result.success(updated);
        } catch (Exception e) {
            return Result.error("更新护理记录失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除护理记录")
    public Result<Boolean> deleteRecord(@PathVariable Long id) {
        try {
            boolean success = nursingRecordService.deleteRecord(id);
            if (!success) {
                return Result.error("护理记录不存在");
            }
            return Result.success(true);
        } catch (Exception e) {
            return Result.error("删除护理记录失败：" + e.getMessage());
        }
    }
}
