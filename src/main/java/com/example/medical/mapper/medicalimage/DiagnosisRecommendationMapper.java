package com.example.medical.mapper.medicalimage;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.medicalimage.DiagnosisRecommendation;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface DiagnosisRecommendationMapper extends BaseMapper<DiagnosisRecommendation> {

    List<DiagnosisRecommendation> findByResultId(String resultId);

    List<DiagnosisRecommendation> findByLesionId(String lesionId);
}
