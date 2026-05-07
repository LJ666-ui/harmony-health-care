package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.FamilyMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

/**
 * 家属信息Mapper接口
 */
@Mapper
public interface FamilyMemberMapper extends BaseMapper<FamilyMember> {

    /**
     * 根据手机号查询家属
     */
    @Select("SELECT * FROM family_member WHERE phone = #{phone} AND is_deleted = 0")
    FamilyMember selectByPhone(String phone);
}
