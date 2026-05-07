package com.example.medical.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.AncientMedicalImage;
import org.springframework.web.multipart.MultipartFile;

public interface AncientMedicalImageService {

    AncientMedicalImage uploadImage(MultipartFile file, String title, String desc, String source);

    Page<AncientMedicalImage> getImageList(int page, int size, String source);

    AncientMedicalImage getImageDetail(Long id);

    void startRestoration(Long id);

    void deleteImage(Long id);
}