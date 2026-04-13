package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.HospitalDepartment;
import java.util.List;

public interface HospitalDepartmentService extends IService<HospitalDepartment> {

    List<HospitalDepartment> getDepartmentsByHospitalId(Long hospitalId);

    HospitalDepartment getDepartmentDetail(Long id);

    boolean addDepartment(HospitalDepartment department);

    boolean updateDepartment(HospitalDepartment department);

    boolean deleteDepartment(Long id);

    List<HospitalDepartment> getDepartmentsByHospitalIdWithLocation(Long hospitalId);
}
