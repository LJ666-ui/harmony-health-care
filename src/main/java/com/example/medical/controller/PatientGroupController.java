package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.dto.DoctorPatientDTO;
import com.example.medical.entity.PatientGroup;
import com.example.medical.service.PatientGroupService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 患者分组控制器
 */
@Api(tags = "患者分组管理")
@RestController
@RequestMapping("/api/doctor")
public class PatientGroupController {

    @Autowired
    private PatientGroupService patientGroupService;

    /**
     * 创建患者分组
     */
    @ApiOperation("创建患者分组")
    @PostMapping("/{doctorId}/patient-groups")
    public Result<PatientGroup> createGroup(@PathVariable Long doctorId,
                                            @RequestBody PatientGroup group) {
        group.setDoctorId(doctorId);
        PatientGroup result = patientGroupService.createGroup(group);
        return Result.success(result);
    }

    /**
     * 获取医生的所有分组
     */
    @ApiOperation("获取医生的所有分组")
    @GetMapping("/{doctorId}/patient-groups")
    public Result<List<PatientGroup>> getGroups(@PathVariable Long doctorId) {
        List<PatientGroup> groups = patientGroupService.getGroupsByDoctorId(doctorId);
        return Result.success(groups);
    }

    /**
     * 更新分组信息
     */
    @ApiOperation("更新分组信息")
    @PutMapping("/patient-group/{groupId}")
    public Result<PatientGroup> updateGroup(@PathVariable Long groupId,
                                            @RequestBody PatientGroup group) {
        group.setId(groupId);
        PatientGroup result = patientGroupService.updateGroup(group);
        return Result.success(result);
    }

    /**
     * 删除分组
     */
    @ApiOperation("删除分组")
    @DeleteMapping("/patient-group/{groupId}")
    public Result<Void> deleteGroup(@PathVariable Long groupId) {
        patientGroupService.deleteGroup(groupId);
        return Result.success();
    }

    /**
     * 添加患者到分组
     */
    @ApiOperation("添加患者到分组")
    @PostMapping("/patient-group/{groupId}/patients")
    public Result<Void> addPatientToGroup(@PathVariable Long groupId,
                                          @RequestParam Long patientId) {
        patientGroupService.addPatientToGroup(groupId, patientId);
        return Result.success();
    }

    /**
     * 批量添加患者到分组
     */
    @ApiOperation("批量添加患者到分组")
    @PostMapping("/patient-group/{groupId}/patients/batch")
    public Result<Void> addPatientsToGroup(@PathVariable Long groupId,
                                           @RequestBody List<Long> patientIds) {
        patientGroupService.addPatientsToGroup(groupId, patientIds);
        return Result.success();
    }

    /**
     * 从分组中移除患者
     */
    @ApiOperation("从分组中移除患者")
    @DeleteMapping("/patient-group/{groupId}/patient/{patientId}")
    public Result<Void> removePatientFromGroup(@PathVariable Long groupId,
                                               @PathVariable Long patientId) {
        patientGroupService.removePatientFromGroup(groupId, patientId);
        return Result.success();
    }

    /**
     * 获取分组中的患者ID列表
     */
    @ApiOperation("获取分组中的患者ID列表")
    @GetMapping("/patient-group/{groupId}/patients")
    public Result<List<Long>> getPatientsInGroup(@PathVariable Long groupId) {
        List<Long> patientIds = patientGroupService.getPatientIdsByGroupId(groupId);
        return Result.success(patientIds);
    }

    /**
     * 获取患者所属的分组列表
     */
    @ApiOperation("获取患者所属的分组列表")
    @GetMapping("/patient/{patientId}/groups")
    public Result<List<PatientGroup>> getPatientGroups(@PathVariable Long patientId) {
        List<PatientGroup> groups = patientGroupService.getGroupsByPatientId(patientId);
        return Result.success(groups);
    }

    /**
     * 统计分组中的患者数量
     */
    @ApiOperation("统计分组中的患者数量")
    @GetMapping("/patient-group/{groupId}/patient-count")
    public Result<Integer> countPatientsInGroup(@PathVariable Long groupId) {
        int count = patientGroupService.countPatientsInGroup(groupId);
        return Result.success(count);
    }

    /**
     * 获取医生的所有患者详细信息（包含用户信息和分组信息）
     * 前端医生端页面调用此接口显示患者列表
     */
    @ApiOperation("获取医生的所有患者详细信息")
    @GetMapping("/{doctorId}/patients")
    public Result<List<DoctorPatientDTO>> getDoctorPatients(@PathVariable Long doctorId) {
        List<DoctorPatientDTO> patients = patientGroupService.getDoctorPatientsWithDetails(doctorId);
        return Result.success(patients);
    }
}
