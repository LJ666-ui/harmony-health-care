package com.example.medical.mapper.medicalimage;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.medicalimage.DiagnosisRecord;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface DiagnosisRecordMapper extends BaseMapper<DiagnosisRecord> {

    DiagnosisRecord findByResultId(String resultId);

    List<DiagnosisRecord> findByUserId(Long userId);

    DiagnosisRecord findByImageId(String imageId);
}
