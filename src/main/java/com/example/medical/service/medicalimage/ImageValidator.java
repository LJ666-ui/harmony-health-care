package com.example.medical.service.medicalimage;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Arrays;
import java.util.List;

@Service
public class ImageValidator {

    private static final List<String> SUPPORTED_FORMATS = Arrays.asList("JPG", "PNG", "DICOM", "DCM");
    private static final long MAX_FILE_SIZE = 20 * 1024 * 1024L;

    public void validateFormat(MultipartFile file) {
        String originalFilename = file.getOriginalFilename();
        if (originalFilename == null || originalFilename.isEmpty()) {
            throw new IllegalArgumentException("文件名不能为空");
        }

        String extension = getFileExtension(originalFilename).toUpperCase();
        if (!SUPPORTED_FORMATS.contains(extension)) {
            throw new IllegalArgumentException("不支持的文件格式: " + extension + "。支持的格式: JPG, PNG, DICOM");
        }
    }

    public void validateSize(MultipartFile file) {
        long fileSize = file.getSize();
        if (fileSize > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("文件大小超过限制。最大支持20MB，当前文件大小: " + formatFileSize(fileSize));
        }
    }

    public void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("文件不能为空");
        }

        validateFormat(file);
        validateSize(file);

        String contentType = file.getContentType();
        if (contentType == null || contentType.isEmpty()) {
            throw new IllegalArgumentException("无法识别文件类型");
        }
    }

    public boolean isValidFormat(MultipartFile file) {
        try {
            validateFormat(file);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public String getFileExtension(String filename) {
        if (filename == null || filename.lastIndexOf(".") == -1) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1);
    }

    public String getFileFormat(MultipartFile file) {
        String extension = getFileExtension(file.getOriginalFilename()).toUpperCase();
        if ("DCM".equals(extension)) {
            return "DICOM";
        }
        return extension;
    }

    private String formatFileSize(long size) {
        if (size < 1024) {
            return size + " B";
        } else if (size < 1024 * 1024) {
            return String.format("%.2f KB", size / 1024.0);
        } else {
            return String.format("%.2f MB", size / (1024.0 * 1024.0));
        }
    }
}
