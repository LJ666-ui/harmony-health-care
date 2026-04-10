package com.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.medical.entity.Medicine;

/**
 * 药品 Service 接口
 */
public interface MedicineService extends IService<Medicine> {
    // 继承 IService，自带 CRUD 方法
}