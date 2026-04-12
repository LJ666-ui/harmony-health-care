package com.example.medical.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.TransferApply;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface TransferApplyMapper extends BaseMapper<TransferApply> {

    @Select("SELECT * FROM transfer_apply WHERE user_id = #{userId} AND is_deleted = 0 ORDER BY apply_time DESC")
    List<TransferApply> findByUserId(Long userId);

    @Select("SELECT * FROM transfer_apply WHERE status = 0 AND is_deleted = 0 ORDER BY apply_time ASC")
    List<TransferApply> findPendingApprovals();

    @Select("SELECT * FROM transfer_apply WHERE approver_id = #{approverId} AND is_deleted = 0 ORDER BY approve_time DESC")
    List<TransferApply> findByApproverId(Long approverId);

    @Select("SELECT * FROM transfer_apply WHERE status IN (1, 2) AND is_deleted = 0 ORDER BY apply_time DESC")
    List<TransferApply> findHistory();
}
