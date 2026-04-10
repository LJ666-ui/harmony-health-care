package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.HealthFood;
import com.example.medical.mapper.HealthFoodMapper;
import com.example.medical.service.HealthFoodService;
import org.springframework.stereotype.Service;

@Service
public class HealthFoodServiceImpl extends ServiceImpl<HealthFoodMapper, HealthFood> implements HealthFoodService {
}