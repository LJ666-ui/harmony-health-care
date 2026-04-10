package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Hospital;
import com.example.medical.mapper.HospitalMapper;
import com.example.medical.service.HospitalService;
import org.springframework.stereotype.Service;

@Service
public class HospitalServiceImpl extends ServiceImpl<HospitalMapper, Hospital> implements HospitalService {
}