package com.example.medical.dto.medicalimage;

import lombok.Data;

import java.io.Serializable;

@Data
public class UploadImageResponse implements Serializable {

    private static final long serialVersionUID = 1L;

    private String imageId;
    private String previewUrl;
    private Long originalSize;
    private Long compressedSize;
    private Double compressionRatio;
}
