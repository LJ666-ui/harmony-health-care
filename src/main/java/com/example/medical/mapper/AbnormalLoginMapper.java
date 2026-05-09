package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.AbnormalLogin;
import org.apache.ibatis.annotations.Mapper;

/**
 * 异常登录记录Mapper接口
 */
@Mapper
public interface AbnormalLoginMapper extends BaseMapper<AbnormalLogin> {
}
