package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.entity.AncientMedicalImage;
import com.example.medical.mapper.AncientMedicalImageMapper;
import com.example.medical.service.AncientMedicalImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class AncientMedicalImageServiceImpl implements AncientMedicalImageService {

    @Autowired
    private AncientMedicalImageMapper ancientMedicalImageMapper;

    @Value("${file.upload.path:./uploads/}")
    private String uploadPath;

    @Override
    public AncientMedicalImage uploadImage(MultipartFile file, String title, String desc, String source) {
        if (file.isEmpty()) {
            throw new RuntimeException("上传文件不能为空");
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String newFilename = UUID.randomUUID().toString() + extension;

            File destFile = new File(uploadPath + "ancient/" + newFilename);
            if (!destFile.getParentFile().exists()) {
                destFile.getParentFile().mkdirs();
            }
            file.transferTo(destFile);

            AncientMedicalImage image = new AncientMedicalImage();
            image.setTitle(title);
            image.setOriginalUrl("/uploads/ancient/" + newFilename);
            image.setDesc(desc);
            image.setSource(source);
            image.setIsDeleted(0);
            image.setCreateTime(LocalDateTime.now());
            image.setUpdateTime(LocalDateTime.now());

            ancientMedicalImageMapper.insert(image);
            return image;

        } catch (IOException e) {
            throw new RuntimeException("文件上传失败：" + e.getMessage());
        }
    }

    @Override
    public Page<AncientMedicalImage> getImageList(int page, int size, String source) {
        Page<AncientMedicalImage> pageParam = new Page<>(page, size);
        QueryWrapper<AncientMedicalImage> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("is_deleted", 0);
        if (source != null && !source.isEmpty() && !"全部".equals(source)) {
            queryWrapper.like("source", source);
        }
        queryWrapper.orderByDesc("create_time");
        return ancientMedicalImageMapper.selectPage(pageParam, queryWrapper);
    }

    @Override
    public AncientMedicalImage getImageDetail(Long id) {
        return ancientMedicalImageMapper.selectById(id);
    }

    @Override
    public void startRestoration(Long id) {
        AncientMedicalImage image = ancientMedicalImageMapper.selectById(id);
        if (image == null) {
            throw new RuntimeException("图片不存在");
        }
        Thread thread = new Thread(() -> {
            try {
                for (int i = 20; i <= 100; i += 10) {
                    Thread.sleep(500);
                }
                image.setRestoreUrl(image.getOriginalUrl().replace("original", "restored"));
                image.setUpdateTime(LocalDateTime.now());
                ancientMedicalImageMapper.updateById(image);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        thread.start();
    }

    @Override
    public void deleteImage(Long id) {
        AncientMedicalImage image = ancientMedicalImageMapper.selectById(id);
        if (image != null) {
            image.setIsDeleted(1);
            ancientMedicalImageMapper.updateById(image);
        }
    }
}