package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.Consultation;
import com.example.medical.entity.ConsultationParticipant;
import com.example.medical.entity.ConsultationRecord;
import com.example.medical.service.ConsultationService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 会诊控制器
 */
@Api(tags = "会诊管理")
@RestController
@RequestMapping("/api/doctor")
public class ConsultationController {

    @Autowired
    private ConsultationService consultationService;

    /**
     * 发起会诊
     */
    @ApiOperation("发起会诊")
    @PostMapping("/consultation")
    public Result<Consultation> initiate(@RequestBody Consultation consultation,
                                          @RequestParam List<Long> doctorIds,
                                          @RequestParam List<Long> departmentIds) {
        Consultation result = consultationService.initiate(consultation, doctorIds, departmentIds);
        return Result.success(result);
    }

    /**
     * 获取医生的会诊列表
     */
    @ApiOperation("获取医生的会诊列表")
    @GetMapping("/{doctorId}/consultations")
    public Result<Page<Consultation>> getByDoctorId(@PathVariable Long doctorId,
                                                     @RequestParam(required = false) String status,
                                                     @RequestParam(defaultValue = "1") int page,
                                                     @RequestParam(defaultValue = "10") int pageSize) {
        Page<Consultation> result = consultationService.getByDoctorId(doctorId, status, page, pageSize);
        return Result.success(result);
    }

    /**
     * 获取会诊详情
     */
    @ApiOperation("获取会诊详情")
    @GetMapping("/consultation/{id}")
    public Result<Consultation> getById(@PathVariable Long id) {
        Consultation result = consultationService.getById(id);
        return Result.success(result);
    }

    /**
     * 开始会诊
     */
    @ApiOperation("开始会诊")
    @PutMapping("/consultation/{id}/start")
    public Result<Consultation> start(@PathVariable Long id) {
        Consultation result = consultationService.start(id);
        return Result.success(result);
    }

    /**
     * 结束会诊
     */
    @ApiOperation("结束会诊")
    @PutMapping("/consultation/{id}/end")
    public Result<Consultation> end(@PathVariable Long id) {
        Consultation result = consultationService.end(id);
        return Result.success(result);
    }

    /**
     * 取消会诊
     */
    @ApiOperation("取消会诊")
    @PutMapping("/consultation/{id}/cancel")
    public Result<Consultation> cancel(@PathVariable Long id) {
        Consultation result = consultationService.cancel(id);
        return Result.success(result);
    }

    /**
     * 添加会诊记录
     */
    @ApiOperation("添加会诊记录")
    @PostMapping("/consultation/{consultationId}/record")
    public Result<ConsultationRecord> addRecord(@PathVariable Long consultationId,
                                                 @RequestBody ConsultationRecord record) {
        record.setConsultationId(consultationId);
        ConsultationRecord result = consultationService.addRecord(record);
        return Result.success(result);
    }

    /**
     * 获取会诊记录列表
     */
    @ApiOperation("获取会诊记录列表")
    @GetMapping("/consultation/{consultationId}/records")
    public Result<List<ConsultationRecord>> getRecords(@PathVariable Long consultationId) {
        List<ConsultationRecord> result = consultationService.getRecords(consultationId);
        return Result.success(result);
    }

    /**
     * 获取会诊参与人列表
     */
    @ApiOperation("获取会诊参与人列表")
    @GetMapping("/consultation/{consultationId}/participants")
    public Result<List<ConsultationParticipant>> getParticipants(@PathVariable Long consultationId) {
        List<ConsultationParticipant> result = consultationService.getParticipants(consultationId);
        return Result.success(result);
    }

    /**
     * 接受会诊邀请
     */
    @ApiOperation("接受会诊邀请")
    @PutMapping("/consultation/{consultationId}/accept")
    public Result<ConsultationParticipant> acceptInvitation(@PathVariable Long consultationId,
                                                            @RequestParam Long doctorId) {
        ConsultationParticipant result = consultationService.acceptInvitation(consultationId, doctorId);
        return Result.success(result);
    }
}
