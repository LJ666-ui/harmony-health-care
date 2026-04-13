package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HospitalDepartment;
import com.example.medical.mapper.HospitalDepartmentMapper;
import com.example.medical.service.HospitalDepartmentService;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class HospitalDepartmentServiceImpl extends ServiceImpl<HospitalDepartmentMapper, HospitalDepartment> implements HospitalDepartmentService {

    @Override
    public List<HospitalDepartment> getDepartmentsByHospitalId(Long hospitalId) {
        LambdaQueryWrapper<HospitalDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HospitalDepartment::getHospitalId, hospitalId);
        wrapper.eq(HospitalDepartment::getIsDeleted, 0);
        wrapper.orderByAsc(HospitalDepartment::getId);
        return list(wrapper);
    }

    @Override
    public HospitalDepartment getDepartmentDetail(Long id) {
        LambdaQueryWrapper<HospitalDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HospitalDepartment::getId, id);
        wrapper.eq(HospitalDepartment::getIsDeleted, 0);
        return getOne(wrapper);
    }

    @Override
    public boolean addDepartment(HospitalDepartment department) {
        department.setCreateTime(new Date());
        department.setUpdateTime(new Date());
        department.setIsDeleted(0);
        return save(department);
    }

    @Override
    public boolean updateDepartment(HospitalDepartment department) {
        department.setUpdateTime(new Date());
        return updateById(department);
    }

    @Override
    public boolean deleteDepartment(Long id) {
        HospitalDepartment department = getById(id);
        if (department != null) {
            department.setIsDeleted(1);
            department.setUpdateTime(new Date());
            return updateById(department);
        }
        return false;
    }

    @Override
    public List<HospitalDepartment> getDepartmentsByHospitalIdWithLocation(Long hospitalId) {
        LambdaQueryWrapper<HospitalDepartment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(HospitalDepartment::getHospitalId, hospitalId);
        wrapper.eq(HospitalDepartment::getIsDeleted, 0);
        wrapper.isNotNull(HospitalDepartment::getLocation);
        wrapper.orderByAsc(HospitalDepartment::getLocation);
        return list(wrapper);
    }
}
