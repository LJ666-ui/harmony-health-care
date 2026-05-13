package com.example.medical.controller.medicalimage;

import com.example.medical.dto.medicalimage.*;
import com.example.medical.service.medicalimage.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "医学影像AI识别")
@RestController
@RequestMapping("/api/v1/medical-image")
public class MedicalImageController {

    @Autowired
    private ImageUploadService imageUploadService;

    @Autowired
    private AIDiagnosisService aiDiagnosisService;

    @Operation(summary = "上传医学影像")
    @PostMapping("/upload")
    public ApiResponse<UploadImageResponse> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("imageType") String imageType,
            @RequestParam("userId") Long userId) {
        try {
            ImageUploadService.UploadResult result = 
                    imageUploadService.uploadImage(file, imageType, userId);

            UploadImageResponse response = new UploadImageResponse();
            response.setImageId(result.getImageId());
            response.setPreviewUrl(result.getPreviewUrl());
            response.setOriginalSize(result.getOriginalSize());
            response.setCompressedSize(result.getCompressedSize());
            response.setCompressionRatio(result.getCompressionRatio());

            return ApiResponse.success(response);

        } catch (IllegalArgumentException e) {
            return ApiResponse.error(40001, e.getMessage());
        } catch (Exception e) {
            return ApiResponse.error(50001, "影像上传失败: " + e.getMessage());
        }
    }

    @Operation(summary = "AI诊断分析")
    @PostMapping("/analyze")
    public ApiResponse<AnalyzeImageResponse> analyzeImage(
            @RequestParam("imageId") String imageId,
            @RequestParam("imageType") String imageType,
            @RequestParam("userId") Long userId) {
        try {
            AIDiagnosisService.DiagnosisResult result = 
                    aiDiagnosisService.analyzeImage(imageId, imageType, userId);

            AnalyzeImageResponse response = new AnalyzeImageResponse();
            response.setResultId(result.getResultId());
            response.setLesionCount(result.getLesionCount());
            response.setOverallConfidence(result.getOverallConfidence());
            response.setAnalysisDuration(result.getAnalysisDuration());
            response.setRecommendations(result.getRecommendations());

            return ApiResponse.success(response);

        } catch (RuntimeException e) {
            if (e.getMessage().contains("不存在")) {
                return ApiResponse.error(40401, e.getMessage());
            }
            return ApiResponse.error(50101, "AI分析失败: " + e.getMessage());
        } catch (Exception e) {
            return ApiResponse.error(50102, "AI分析异常: " + e.getMessage());
        }
    }

    @Operation(summary = "查询诊断结果")
    @GetMapping("/result/{resultId}")
    public ApiResponse<Object> getResult(@PathVariable String resultId) {
        return ApiResponse.error(40403, "结果不存在");
    }

    @Operation(summary = "查询病灶详情")
    @GetMapping("/lesion/{lesionId}")
    public ApiResponse<Object> getLesionDetail(@PathVariable String lesionId) {
        return ApiResponse.error(40404, "病灶不存在");
    }

    @Operation(summary = "生成诊断报告")
    @GetMapping("/report/{resultId}")
    public ApiResponse<Object> generateReport(@PathVariable String resultId) {
        return ApiResponse.error(40403, "结果不存在");
    }

    @Operation(summary = "查询历史记录")
    @GetMapping("/history")
    public ApiResponse<Object> getHistory(
            @RequestParam("userId") Long userId,
            @RequestParam(value = "page", defaultValue = "1") Integer page,
            @RequestParam(value = "size", defaultValue = "10") Integer size) {
        return ApiResponse.success("暂无历史记录");
    }
}
