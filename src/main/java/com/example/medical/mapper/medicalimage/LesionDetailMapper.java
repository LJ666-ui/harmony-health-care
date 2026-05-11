package com.example.medical.mapper.medicalimage;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.medicalimage.LesionDetail;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface LesionDetailMapper extends BaseMapper<LesionDetail> {

    List<LesionDetail> findByResultId(String resultId);

    LesionDetail findByLesionId(String lesionId);
}
