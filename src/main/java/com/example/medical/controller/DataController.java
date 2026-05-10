package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.service.DataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/data")
public class DataController {

    @Autowired
    private DataService dataService;

    /**
     * 获取患者列表
     */
    @GetMapping("/patients")
    public Result getPatients(
            @RequestHeader(value = "Token", required = false) String token,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer size) {
        try {
            List<Map<String, Object>> patients = dataService.searchPatients(keyword, page, size);
            return Result.success(patients);
        } catch (Exception e) {
            return Result.error("获取患者列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取医生列表
     */
    @GetMapping("/doctors")
    public Result getDoctors(
            @RequestHeader(value = "Token", required = false) String token,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String department,
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer size) {
        try {
            List<Map<String, Object>> doctors = dataService.searchDoctors(keyword, department, page, size);
            return Result.success(doctors);
        } catch (Exception e) {
            return Result.error("获取医生列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取医院列表
     */
    @GetMapping("/hospitals")
    public Result getHospitals(
            @RequestHeader(value = "Token", required = false) String token,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String city,
            @RequestParam(required = false, defaultValue = "1") Integer page,
            @RequestParam(required = false, defaultValue = "20") Integer size) {
        try {
            List<Map<String, Object>> hospitals = dataService.searchHospitals(keyword, city, page, size);
            return Result.success(hospitals);
        } catch (Exception e) {
            return Result.error("获取医院列表失败: " + e.getMessage());
        }
    }

    /**
     * 获取科室列表
     */
    @GetMapping("/departments")
    public Result getDepartments(
            @RequestHeader(value = "Token", required = false) String token,
            @RequestParam(required = false) Long hospitalId) {
        try {
            List<Map<String, Object>> departments = dataService.getDepartments(hospitalId);
            return Result.success(departments);
        } catch (Exception e) {
            return Result.error("获取科室列表失败: " + e.getMessage());
        }
    }
}
