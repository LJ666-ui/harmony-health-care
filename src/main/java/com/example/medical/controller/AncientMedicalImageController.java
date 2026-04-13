package com.example.medical.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.Result;
import com.example.medical.entity.AncientMedicalImage;
import com.example.medical.service.AncientMedicalImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/ancient-image")
public class AncientMedicalImageController {

    @Autowired
    private AncientMedicalImageService ancientMedicalImageService;

    @PostMapping("/upload")
    public Result<?> uploadImage(@RequestParam("file") MultipartFile file,
                                 @RequestParam(value = "title", required = false) String title,
                                 @RequestParam(value = "desc", required = false) String desc) {
        try {
            if (file.isEmpty()) {
                return Result.error("上传文件不能为空");
            }
            AncientMedicalImage image = ancientMedicalImageService.uploadImage(file, title, desc);
            return Result.success(image);
        } catch (Exception e) {
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    @GetMapping("/list")
    public Result<?> getImageList(@RequestParam(defaultValue = "1") int page,
                                  @RequestParam(defaultValue = "10") int size) {
        try {
            Page<AncientMedicalImage> pageResult = ancientMedicalImageService.getImageList(page, size);
            return Result.success(pageResult);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public Result<?> getImageDetail(@PathVariable Long id) {
        try {
            AncientMedicalImage image = ancientMedicalImageService.getImageDetail(id);
            if (image == null) {
                return Result.error("图片不存在");
            }
            return Result.success(image);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }

    @PostMapping("/{id}/restore")
    public Result<?> startRestoration(@PathVariable Long id) {
        try {
            ancientMedicalImageService.startRestoration(id);
            return Result.success("复原任务已启动");
        } catch (Exception e) {
            return Result.error("启动失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    public Result<?> deleteImage(@PathVariable Long id) {
        try {
            ancientMedicalImageService.deleteImage(id);
            return Result.success("删除成功");
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }
}