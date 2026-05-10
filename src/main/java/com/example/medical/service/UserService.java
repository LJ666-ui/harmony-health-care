package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.entity.User;

public interface UserService extends IService<User> {
    User findByUsername(String username);
    User findByPhone(String phone);
}