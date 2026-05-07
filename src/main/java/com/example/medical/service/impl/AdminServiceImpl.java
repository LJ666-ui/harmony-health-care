package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Admin;
import com.example.medical.mapper.AdminMapper;
import com.example.medical.service.AdminService;
import org.springframework.stereotype.Service;

@Service
public class AdminServiceImpl extends ServiceImpl<AdminMapper, Admin> implements AdminService {

    @Override
    public Admin findByUsername(String username) {
        LambdaQueryWrapper<Admin> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Admin::getUsername, username)
                    .eq(Admin::getIsDeleted, 0);
        return this.getOne(queryWrapper);
    }
}
