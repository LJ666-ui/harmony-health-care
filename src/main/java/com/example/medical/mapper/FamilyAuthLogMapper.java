package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.FamilyAuthLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 家属认证日志Mapper接口
 */
@Mapper
public interface FamilyAuthLogMapper extends BaseMapper<FamilyAuthLog> {
}
