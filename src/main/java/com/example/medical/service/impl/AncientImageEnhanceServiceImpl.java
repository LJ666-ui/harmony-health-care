package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.UpdateWrapper;
import com.example.medical.entity.AncientMedicalImage;
import com.example.medical.mapper.AncientMedicalImageMapper;
import com.example.medical.service.AncientImageEnhanceService;
import com.example.medical.utils.AIClient;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Service
public class AncientImageEnhanceServiceImpl implements AncientImageEnhanceService {

    @Autowired
    private AncientMedicalImageMapper ancientMedicalImageMapper;

    @Autowired
    private AIClient aiClient;

    @Override
    public AncientMedicalImage enhanceImage(Long imageId) {
        log.info("开始AI超分辨率修复, imageId: {}", imageId);

        AncientMedicalImage image = ancientMedicalImageMapper.selectById(imageId);
        if (image == null) {
            throw new RuntimeException("图片不存在");
        }

        UpdateWrapper<AncientMedicalImage> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", imageId)
                .set("enhance_status", "ENHANCING")
                .set("enhance_progress", 10)
                .set("update_time", LocalDateTime.now());
        ancientMedicalImageMapper.update(null, updateWrapper);

        CompletableFuture.runAsync(() -> {
            try {
                simulateHiAIEnhancement(image);

                UpdateWrapper<AncientMedicalImage> successWrapper = new UpdateWrapper<>();
                successWrapper.eq("id", imageId)
                        .set("restore_url", generateRestoreUrl(image.getOriginalUrl()))
                        .set("enhance_status", "COMPLETED")
                        .set("enhance_progress", 100)
                        .set("update_time", LocalDateTime.now());
                ancientMedicalImageMapper.update(null, successWrapper);

                log.info("AI超分辨率修复完成, imageId: {}", imageId);
            } catch (Exception e) {
                log.error("AI增强失败: ", e);
                UpdateWrapper<AncientMedicalImage> failWrapper = new UpdateWrapper<>();
                failWrapper.eq("id", imageId)
                        .set("enhance_status", "FAILED")
                        .set("update_time", LocalDateTime.now());
                ancientMedicalImageMapper.update(null, failWrapper);
            }
        });

        return ancientMedicalImageMapper.selectById(imageId);
    }

    @Override
    public AncientMedicalImage generate3DModel(Long imageId) {
        log.info("开始3D场景重建, imageId: {}", imageId);

        AncientMedicalImage image = ancientMedicalImageMapper.selectById(imageId);
        if (image == null) {
            throw new RuntimeException("图片不存在");
        }

        if (image.getRestoreUrl() == null || image.getRestoreUrl().isEmpty()) {
            throw new RuntimeException("请先完成图像复原");
        }

        UpdateWrapper<AncientMedicalImage> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", imageId)
                .set("enhance_status", "ANIMATING")
                .set("enhance_progress", 50)
                .set("update_time", LocalDateTime.now());
        ancientMedicalImageMapper.update(null, updateWrapper);

        CompletableFuture.runAsync(() -> {
            try {
                Thread.sleep(3000);

                String model3dUrl = generate3DModelUrl(image.getOriginalUrl());

                UpdateWrapper<AncientMedicalImage> successWrapper = new UpdateWrapper<>();
                successWrapper.eq("id", imageId)
                        .set("model_3d_url", model3dUrl)
                        .set("enhance_status", "COMPLETED")
                        .set("enhance_progress", 100)
                        .set("update_time", LocalDateTime.now());
                ancientMedicalImageMapper.update(null, successWrapper);

                log.info("3D模型生成完成, imageId: {}", imageId);
            } catch (Exception e) {
                log.error("3D建模失败: ", e);
            }
        });

        return ancientMedicalImageMapper.selectById(imageId);
    }

    @Override
    public AncientMedicalImage generateAnimation(Long imageId) {
        log.info("开始AI动画生成, imageId: {}", imageId);

        AncientMedicalImage image = ancientMedicalImageMapper.selectById(imageId);
        if (image == null) {
            throw new RuntimeException("图片不存在");
        }

        if (image.getRestoreUrl() == null || image.getRestoreUrl().isEmpty()) {
            throw new RuntimeException("请先完成图像复原");
        }

        UpdateWrapper<AncientMedicalImage> updateWrapper = new UpdateWrapper<>();
        updateWrapper.eq("id", imageId)
                .set("enhance_status", "ANIMATING")
                .set("enhance_progress", 60)
                .set("update_time", LocalDateTime.now());
        ancientMedicalImageMapper.update(null, updateWrapper);

        CompletableFuture.runAsync(() -> {
            try {
                Thread.sleep(4000);

                String animationUrl = generateAnimationUrl(image.getOriginalUrl(), image.getTitle());

                UpdateWrapper<AncientMedicalImage> successWrapper = new UpdateWrapper<>();
                successWrapper.eq("id", imageId)
                        .set("animation_url", animationUrl)
                        .set("enhance_status", "COMPLETED")
                        .set("enhance_progress", 100)
                        .set("update_time", LocalDateTime.now());
                ancientMedicalImageMapper.update(null, successWrapper);

                log.info("AI动画生成完成, imageId: {}", imageId);
            } catch (Exception e) {
                log.error("AI动画生成失败: ", e);
            }
        });

        return ancientMedicalImageMapper.selectById(imageId);
    }

    @Override
    public AncientMedicalImage getEnhanceProgress(Long imageId) {
        return ancientMedicalImageMapper.selectById(imageId);
    }

    @Override
    public String batchEnhance(Long[] imageIds) {
        log.info("批量增强图片, count: {}", imageIds.length);

        for (Long imageId : imageIds) {
            try {
                this.enhanceImage(imageId);
                Thread.sleep(500);
            } catch (Exception e) {
                log.error("批量增强失败, imageId: {}, error: {}", imageId, e.getMessage());
            }
        }

        return String.format("已启动%d张图片的AI增强任务", imageIds.length);
    }

    private void simulateHiAIEnhancement(AncientMedicalImage image) throws InterruptedException {
        int[] progressStages = {20, 40, 60, 80, 95};

        for (int progress : progressStages) {
            Thread.sleep(800);

            UpdateWrapper<AncientMedicalImage> progressWrapper = new UpdateWrapper<>();
            progressWrapper.eq("id", image.getId())
                    .set("enhance_progress", progress)
                    .set("update_time", LocalDateTime.now());
            ancientMedicalImageMapper.update(null, progressWrapper);
        }

        Thread.sleep(1000);
    }

    private String generateRestoreUrl(String originalUrl) {
        if (originalUrl.contains("baidu.com")) {
            return originalUrl.replace("fm=253", "fm=26").replace("&app=138", "&app=26&w=1200&h=1600");
        }
        return originalUrl + "_enhanced_" + System.currentTimeMillis();
    }

    private String generate3DModelUrl(String originalUrl) {
        return "/api/3d/model_" + System.currentTimeMillis() + ".glb";
    }

    private String generateAnimationUrl(String originalUrl, String title) {
        String safeTitle = title.replaceAll("[^a-zA-Z0-9\\u4e00-\\u9fa5]", "_");
        return "/api/animation/anim_" + safeTitle + "_" + System.currentTimeMillis() + ".mp4";
    }
}
