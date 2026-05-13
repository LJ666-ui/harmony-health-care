package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.SensitiveOperation;
import org.apache.ibatis.annotations.Mapper;

/**
 * 敏感操作Mapper接口
 */
@Mapper
public interface SensitiveOperationMapper extends BaseMapper<SensitiveOperation> {
}
