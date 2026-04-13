package com.example.medical.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.dto.HospitalDistanceDTO;
import com.example.medical.dto.HospitalQueryDTO;
import com.example.medical.entity.Hospital;
import com.example.medical.entity.HospitalDepartment;
import java.math.BigDecimal;
import java.util.List;

public interface HospitalService extends IService<Hospital> {

    Page<Hospital> queryHospitalsWithPage(HospitalQueryDTO queryDTO);

    List<Hospital> searchHospitals(HospitalQueryDTO queryDTO);

    List<HospitalDistanceDTO> getNearbyHospitals(BigDecimal userLongitude, BigDecimal userLatitude, BigDecimal radius);

    List<HospitalDepartment> getDepartmentsByHospitalId(Long hospitalId);

    Hospital getHospitalDetailWithDepartments(Long hospitalId);

    double calculateDistance(BigDecimal lon1, BigDecimal lat1, BigDecimal lon2, BigDecimal lat2);
}
