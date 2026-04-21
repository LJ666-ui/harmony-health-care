package com.example.medical.service;

import com.example.medical.entity.AncientMedicalImage;

public interface AncientImageEnhanceService {

    AncientMedicalImage enhanceImage(Long imageId);

    AncientMedicalImage generate3DModel(Long imageId);

    AncientMedicalImage generateAnimation(Long imageId);

    AncientMedicalImage getEnhanceProgress(Long imageId);

    String batchEnhance(Long[] imageIds);
}
