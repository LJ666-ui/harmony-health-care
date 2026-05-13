package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.dto.HospitalDistanceDTO;
import com.example.medical.dto.HospitalQueryDTO;
import com.example.medical.entity.Hospital;
import com.example.medical.entity.HospitalDepartment;
import com.example.medical.service.HospitalDepartmentService;
import com.example.medical.service.HospitalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/hospital")
public class HospitalController {

    @Autowired
    private HospitalService hospitalService;

    @Autowired
    private HospitalDepartmentService hospitalDepartmentService;

    @GetMapping("/list")
    public Result<List<Hospital>> getHospitalList() {
        try {
            LambdaQueryWrapper<Hospital> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Hospital::getIsDeleted, 0);
            List<Hospital> hospitals = hospitalService.list(wrapper);
            return Result.success(hospitals);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医院列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/department/list")
    public Result<List<HospitalDepartment>> getDepartmentList(@RequestParam Long hospitalId) {
        try {
            List<HospitalDepartment> departments = hospitalDepartmentService.getDepartmentsByHospitalId(hospitalId);
            return Result.success(departments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取科室列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/info/{id}")
    public Result<Hospital> getHospitalInfo(@PathVariable Long id) {
        try {
            Hospital hospital = hospitalService.getHospitalDetailWithDepartments(id);
            if (hospital == null) {
                return Result.error("医院不存在");
            }
            return Result.success(hospital);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医院详情失败：" + e.getMessage());
        }
    }

    @GetMapping("/page")
    public Result<Page<Hospital>> getHospitalPage(
            @RequestParam(required = false) String province,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String level,
            @RequestParam(required = false) String deptName,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        try {
            HospitalQueryDTO queryDTO = new HospitalQueryDTO();
            queryDTO.setProvince(province);
            queryDTO.setCity(city);
            queryDTO.setLevel(level);
            queryDTO.setDeptName(deptName);
            queryDTO.setPage(page);
            queryDTO.setSize(size);

            Page<Hospital> hospitalPage = hospitalService.queryHospitalsWithPage(queryDTO);
            return Result.success(hospitalPage);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医院分页列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/nearby")
    public Result<List<HospitalDistanceDTO>> getNearbyHospitals(
            @RequestParam BigDecimal longitude,
            @RequestParam BigDecimal latitude,
            @RequestParam(required = false) BigDecimal radius) {
        try {
            if (radius == null) {
                radius = new BigDecimal("50");
            }
            List<HospitalDistanceDTO> nearbyHospitals = hospitalService.getNearbyHospitals(longitude, latitude, radius);
            return Result.success(nearbyHospitals);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取附近医院失败：" + e.getMessage());
        }
    }

    @PostMapping("/department/add")
    public Result<Boolean> addDepartment(@RequestBody HospitalDepartment department) {
        try {
            boolean result = hospitalDepartmentService.addDepartment(department);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加科室失败：" + e.getMessage());
        }
    }

    @PostMapping("/department/update")
    public Result<Boolean> updateDepartment(@RequestBody HospitalDepartment department) {
        try {
            boolean result = hospitalDepartmentService.updateDepartment(department);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新科室失败：" + e.getMessage());
        }
    }

    @PostMapping("/department/delete")
    public Result<Boolean> deleteDepartment(@RequestParam Long id) {
        try {
            boolean result = hospitalDepartmentService.deleteDepartment(id);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除科室失败：" + e.getMessage());
        }
    }

    @GetMapping("/department/all")
    public Result<List<HospitalDepartment>> getAllDepartments() {
        try {
            List<HospitalDepartment> departments = hospitalDepartmentService.list();
            return Result.success(departments);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取所有科室失败：" + e.getMessage());
        }
    }

    @GetMapping("/department/info/{id}")
    public Result<HospitalDepartment> getDepartmentInfo(@PathVariable Long id) {
        try {
            HospitalDepartment department = hospitalDepartmentService.getDepartmentDetail(id);
            if (department == null) {
                return Result.error("科室不存在");
            }
            return Result.success(department);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取科室详情失败：" + e.getMessage());
        }
    }
}
