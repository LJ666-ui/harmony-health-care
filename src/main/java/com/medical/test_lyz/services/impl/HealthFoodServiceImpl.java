package com.medical.test_lyz.services.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.test_lyz.entity.HealthFood;
import com.medical.test_lyz.mapper.HealthFoodMapper;
import com.medical.test_lyz.services.HealthFoodService;
import org.springframework.stereotype.Service;

@Service // 必须加，注入Spring容器
public class HealthFoodServiceImpl extends ServiceImpl<HealthFoodMapper, HealthFood>
        implements HealthFoodService {
}