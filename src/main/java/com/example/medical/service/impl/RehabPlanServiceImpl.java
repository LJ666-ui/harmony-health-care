package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.RehabPlan;
import com.example.medical.mapper.RehabPlanMapper;
import com.example.medical.service.RehabPlanService;
import org.springframework.stereotype.Service;

@Service
public class RehabPlanServiceImpl extends ServiceImpl<RehabPlanMapper, RehabPlan> implements RehabPlanService {
}