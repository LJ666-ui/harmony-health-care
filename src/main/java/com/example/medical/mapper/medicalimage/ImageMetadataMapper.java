package com.example.medical.mapper.medicalimage;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.medical.entity.medicalimage.ImageMetadata;
import org.apache.ibatis.annotations.Mapper;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface ImageMetadataMapper extends BaseMapper<ImageMetadata> {

    List<ImageMetadata> findByUserId(Long userId);

    List<ImageMetadata> findByUploadTimeBetween(LocalDateTime startTime, LocalDateTime endTime);

    ImageMetadata findByImageId(String imageId);
}
