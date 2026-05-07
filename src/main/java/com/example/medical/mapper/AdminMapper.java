package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Admin;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AdminMapper extends BaseMapper<Admin> {
}
