package com.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.medical.entity.Medicine;
import com.medical.mapper.MedicineMapper;
import com.medical.service.MedicineService;
import org.springframework.stereotype.Service;

/**
 * 药品 Service 实现类
 */
@Service
public class MedicineServiceImpl extends ServiceImpl<MedicineMapper, Medicine> implements MedicineService {
    // 无需写方法，ServiceImpl 自带 CRUD 实现
}