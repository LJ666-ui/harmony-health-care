package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.Admin;

public interface AdminService extends IService<Admin> {
    Admin findByUsername(String username);
}
