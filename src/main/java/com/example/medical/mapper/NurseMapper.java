package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.Nurse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

/**
 * 护士Mapper接口
 */
@Mapper
public interface NurseMapper extends BaseMapper<Nurse> {

    /**
     * 根据手机号查询护士信息
     */
    @Select("SELECT n.* FROM nurse n " +
            "INNER JOIN user u ON n.user_id = u.id " +
            "WHERE u.phone = #{phone} AND n.is_deleted = 0 LIMIT 1")
    Nurse selectByPhone(@Param("phone") String phone);

    /**
     * 根据用户ID查询护士信息
     */
    @Select("SELECT * FROM nurse WHERE user_id = #{userId} AND is_deleted = 0")
    Nurse selectByUserId(@Param("userId") Long userId);

    /**
     * 根据护士工号查询护士信息
     */
    @Select("SELECT * FROM nurse WHERE nurse_no = #{nurseNo} AND is_deleted = 0")
    Nurse selectByNurseNo(@Param("nurseNo") String nurseNo);
}
