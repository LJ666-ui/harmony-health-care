package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.entity.Medicine;
import com.example.medical.mapper.MedicineMapper;
import com.example.medical.service.MedicineService;
import org.springframework.stereotype.Service;

@Service
public class MedicineServiceImpl extends ServiceImpl<MedicineMapper, Medicine> implements MedicineService {
}