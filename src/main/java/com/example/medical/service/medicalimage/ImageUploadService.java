package com.example.medical.service.medicalimage;

import com.example.medical.entity.medicalimage.ImageMetadata;
import com.example.medical.entity.medicalimage.OperationAuditLog;
import com.example.medical.mapper.medicalimage.ImageMetadataMapper;
import com.example.medical.mapper.medicalimage.OperationAuditLogMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class ImageUploadService {

    @Autowired
    private ImageValidator imageValidator;

    @Autowired
    private ImageCompressor imageCompressor;

    @Autowired
    private FileStorageAdapter fileStorageAdapter;

    @Autowired
    private ImageMetadataMapper imageMetadataMapper;

    @Autowired
    private OperationAuditLogMapper auditLogMapper;

    @Transactional
    public UploadResult uploadImage(MultipartFile file, String imageType, Long userId) {
        try {
            if (!fileStorageAdapter.isInitialized()) {
                throw new RuntimeException(
                    "文件存储服务不可用。MinIO连接失败: " + fileStorageAdapter.getInitializationError() +
                    "。请检查MinIO服务是否启动（配置地址: localhost:9000）" +
                    "。参考文档: MINIO_SETUP_GUIDE.md"
                );
            }

            imageValidator.validateFile(file);

            byte[] originalData = file.getBytes();
            String format = imageValidator.getFileFormat(file);

            ImageCompressor.CompressionResult compressionResult = 
                    imageCompressor.compress(originalData, format);
            byte[] compressedData = compressionResult.getCompressedData();

            byte[] previewData = imageCompressor.generatePreview(originalData, format);
            String previewFormat = "jpg".equalsIgnoreCase(format) ? "jpg" : "png";

            String imageId = generateImageId();
            String objectName = "images/" + imageId + "." + format.toLowerCase();
            String previewObjectName = "previews/" + imageId + "." + previewFormat;

            String storageUrl = fileStorageAdapter.store(
                    compressedData, 
                    objectName, 
                    getContentType(format)
            );

            String previewUrl = fileStorageAdapter.store(
                    previewData, 
                    previewObjectName, 
                    getContentType(previewFormat)
            );

            String fullPreviewUrl = fileStorageAdapter.generatePreviewUrl(previewObjectName);

            ImageMetadata metadata = new ImageMetadata();
            metadata.setImageId(imageId);
            metadata.setUserId(userId);
            metadata.setImageType(imageType);
            metadata.setOriginalFormat(format);
            metadata.setOriginalSize((long) originalData.length);
            metadata.setCompressedSize((long) compressedData.length);
            metadata.setStorageUrl(storageUrl);
            metadata.setPreviewUrl(fullPreviewUrl);
            metadata.setUploadTime(LocalDateTime.now());
            metadata.setStatus("UPLOADED");
            metadata.setCreatedAt(LocalDateTime.now());
            metadata.setUpdatedAt(LocalDateTime.now());

            imageMetadataMapper.insert(metadata);

            recordAuditLog(userId, "UPLOAD", "IMAGE", imageId, 
                    "{\"originalSize\":" + originalData.length + 
                    ",\"compressedSize\":" + compressedData.length + 
                    ",\"compressionRatio\":" + compressionResult.getCompressionRatio() + "}");

            return new UploadResult(
                    imageId, 
                    fullPreviewUrl, 
                    (long) originalData.length, 
                    (long) compressedData.length,
                    compressionResult.getCompressionRatio()
            );

        } catch (Exception e) {
            throw new RuntimeException("影像上传失败: " + e.getMessage(), e);
        }
    }

    public String generateImageId() {
        return "IMG-" + System.currentTimeMillis() + "-" + 
                UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private String getContentType(String format) {
        switch (format.toUpperCase()) {
            case "JPG":
            case "JPEG":
                return "image/jpeg";
            case "PNG":
                return "image/png";
            case "DICOM":
            case "DCM":
                return "application/dicom";
            default:
                return "application/octet-stream";
        }
    }

    private void recordAuditLog(Long userId, String operationType, String resourceType, 
                               String resourceId, String operationDetail) {
        OperationAuditLog auditLog = new OperationAuditLog();
        auditLog.setUserId(userId);
        auditLog.setOperationType(operationType);
        auditLog.setResourceType(resourceType);
        auditLog.setResourceId(resourceId);
        auditLog.setOperationDetail(operationDetail);
        auditLog.setOperationTime(LocalDateTime.now());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogMapper.insert(auditLog);
    }

    public static class UploadResult {
        private final String imageId;
        private final String previewUrl;
        private final Long originalSize;
        private final Long compressedSize;
        private final Double compressionRatio;

        public UploadResult(String imageId, String previewUrl, Long originalSize, 
                           Long compressedSize, Double compressionRatio) {
            this.imageId = imageId;
            this.previewUrl = previewUrl;
            this.originalSize = originalSize;
            this.compressedSize = compressedSize;
            this.compressionRatio = compressionRatio;
        }

        public String getImageId() {
            return imageId;
        }

        public String getPreviewUrl() {
            return previewUrl;
        }

        public Long getOriginalSize() {
            return originalSize;
        }

        public Long getCompressedSize() {
            return compressedSize;
        }

        public Double getCompressionRatio() {
            return compressionRatio;
        }
    }
}
