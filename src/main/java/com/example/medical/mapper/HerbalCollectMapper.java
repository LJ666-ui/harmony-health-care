package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.HerbalCollect;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface HerbalCollectMapper extends BaseMapper<HerbalCollect> {

    @Select("SELECT * FROM herbal_collect WHERE user_id = #{userId} AND herbal_id = #{herbalId} AND is_deleted = 0")
    HerbalCollect findByUserIdAndHerbalId(Long userId, Long herbalId);
}
