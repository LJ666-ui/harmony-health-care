package com.medical.test.services.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.test.entity.RehabPlan;
import com.medical.test.mapper.RehabPlanMapper;
import com.medical.test.services.RehabPlanService;
import org.springframework.stereotype.Service;

@Service // 必须加，注入Spring容器
public class RehabPlanServiceImpl extends ServiceImpl<RehabPlanMapper, RehabPlan>
        implements RehabPlanService {
}
