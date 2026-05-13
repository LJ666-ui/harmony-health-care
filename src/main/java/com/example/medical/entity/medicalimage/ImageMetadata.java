package com.example.medical.entity.medicalimage;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("image_metadata")
public class ImageMetadata implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "image_id", type = IdType.ASSIGN_ID)
    private String imageId;

    @TableField("user_id")
    private Long userId;

    @TableField("image_type")
    private String imageType;

    @TableField("original_format")
    private String originalFormat;

    @TableField("original_size")
    private Long originalSize;

    @TableField("compressed_size")
    private Long compressedSize;

    @TableField("storage_url")
    private String storageUrl;

    @TableField("preview_url")
    private String previewUrl;

    @TableField("upload_time")
    private LocalDateTime uploadTime;

    @TableField("status")
    private String status;

    @TableField("error_message")
    private String errorMessage;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
