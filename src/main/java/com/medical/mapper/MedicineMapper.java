package com.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.medical.entity.Medicine;
import org.apache.ibatis.annotations.Mapper;

/**
 * 药品 Mapper 接口，继承 MyBatis-Plus 的 BaseMapper，自带 CRUD
 */
@Mapper
public interface MedicineMapper extends BaseMapper<Medicine> {
    // 无需写方法，BaseMapper 自带：selectList、insert、update、delete 等
}