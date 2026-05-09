package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.dto.HospitalDistanceDTO;
import com.example.medical.dto.HospitalQueryDTO;
import com.example.medical.entity.Hospital;
import com.example.medical.entity.HospitalDepartment;
import com.example.medical.mapper.HospitalDepartmentMapper;
import com.example.medical.mapper.HospitalMapper;
import com.example.medical.service.HospitalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class HospitalServiceImpl extends ServiceImpl<HospitalMapper, Hospital> implements HospitalService {

    @Autowired
    private HospitalDepartmentMapper hospitalDepartmentMapper;

    private static final double EARTH_RADIUS = 6371.0;

    @Override
    public Page<Hospital> queryHospitalsWithPage(HospitalQueryDTO queryDTO) {
        Page<Hospital> page = new Page<>(queryDTO.getPage(), queryDTO.getSize());
        LambdaQueryWrapper<Hospital> wrapper = buildSearchWrapper(queryDTO);
        return page(page, wrapper);
    }

    @Override
    public List<Hospital> searchHospitals(HospitalQueryDTO queryDTO) {
        LambdaQueryWrapper<Hospital> wrapper = buildSearchWrapper(queryDTO);
        return list(wrapper);
    }

    private LambdaQueryWrapper<Hospital> buildSearchWrapper(HospitalQueryDTO queryDTO) {
        LambdaQueryWrapper<Hospital> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Hospital::getIsDeleted, 0);

        if (queryDTO.getProvince() != null && !queryDTO.getProvince().isEmpty()) {
            wrapper.like(Hospital::getAddress, queryDTO.getProvince());
        }

        if (queryDTO.getCity() != null && !queryDTO.getCity().isEmpty()) {
            wrapper.like(Hospital::getAddress, queryDTO.getCity());
        }

        if (queryDTO.getLevel() != null && !queryDTO.getLevel().isEmpty()) {
            wrapper.eq(Hospital::getDepartment, queryDTO.getLevel());
        }

        return wrapper;
    }

    @Override
    public List<HospitalDistanceDTO> getNearbyHospitals(BigDecimal userLongitude, BigDecimal userLatitude, BigDecimal radius) {
        LambdaQueryWrapper<Hospital> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Hospital::getIsDeleted, 0);
        wrapper.isNotNull(Hospital::getLongitude);
        wrapper.isNotNull(Hospital::getLatitude);
        List<Hospital> hospitals = list(wrapper);

        List<HospitalDistanceDTO> result = new ArrayList<>();
        for (Hospital hospital : hospitals) {
            if (hospital.getLongitude() != null && hospital.getLatitude() != null) {
                double distance = calculateDistance(userLongitude, userLatitude,
                        hospital.getLongitude(), hospital.getLatitude());

                if (radius == null || distance <= radius.doubleValue()) {
                    HospitalDistanceDTO dto = new HospitalDistanceDTO();
                    dto.setId(hospital.getId());
                    dto.setName(hospital.getName());
                    dto.setAddress(hospital.getAddress());
                    dto.setPhone(hospital.getPhone());
                    dto.setLevel(hospital.getLevel());
                    dto.setDescription(hospital.getDescription());
                    dto.setLongitude(hospital.getLongitude());
                    dto.setLatitude(hospital.getLatitude());
                    dto.setDistance(Math.round(distance * 100) / 100.0);
                    result.add(dto);
                }
            }
        }

        return result.stream()
                .sorted(Comparator.comparingDouble(HospitalDistanceDTO::getDistance))
                .limit(10)
                .collect(Collectors.toList());
    }

    @Override
    public List<HospitalDepartment> getDepartmentsByHospitalId(Long hospitalId) {
        LambdaQueryWrapper<HospitalDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HospitalDepartment::getHospitalId, hospitalId);
        wrapper.eq(HospitalDepartment::getIsDeleted, 0);
        return hospitalDepartmentMapper.selectList(wrapper);
    }

    @Override
    public Hospital getHospitalDetailWithDepartments(Long hospitalId) {
        Hospital hospital = getById(hospitalId);
        if (hospital != null) {
            List<HospitalDepartment> departments = getDepartmentsByHospitalId(hospitalId);
            hospital.setDepartments(departments);
        }
        return hospital;
    }

    @Override
    public double calculateDistance(BigDecimal lon1, BigDecimal lat1, BigDecimal lon2, BigDecimal lat2) {
        if (lon1 == null || lat1 == null || lon2 == null || lat2 == null) {
            return 0;
        }

        double latRad1 = Math.toRadians(lat1.doubleValue());
        double latRad2 = Math.toRadians(lat2.doubleValue());
        double deltaLat = Math.toRadians(lat2.doubleValue() - lat1.doubleValue());
        double deltaLon = Math.toRadians(lon2.doubleValue() - lon1.doubleValue());

        double a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
                Math.cos(latRad1) * Math.cos(latRad2) *
                        Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS * c;
    }
}
