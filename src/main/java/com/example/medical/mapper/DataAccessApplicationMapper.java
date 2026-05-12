package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.DataAccessApplication;
import org.apache.ibatis.annotations.Mapper;

/**
 * 数据访问申请Mapper接口
 */
@Mapper
public interface DataAccessApplicationMapper extends BaseMapper<DataAccessApplication> {
}
