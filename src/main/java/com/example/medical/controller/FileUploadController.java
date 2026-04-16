package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
public class FileUploadController {

    private static final Logger log = LoggerFactory.getLogger(FileUploadController.class);
    
    // 允许的3D文件扩展名
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("stl", "obj", "3ds", "fbx", "gltf", "glb");
    // 最大文件大小（50MB）
    private static final long MAX_FILE_SIZE = 50 * 1024 * 1024;
    
    @Value("${file.upload.dir:./uploads}")
    private String uploadDir;

    @PostMapping("/3d")
    public Result upload3dFile(@RequestParam("file") MultipartFile file, HttpServletRequest request) {
        if (file.isEmpty()) {
            return Result.error("文件不能为空");
        }

        try {
            // 1. 校验Token
            String authHeader = request.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return Result.error("未登录，请先登录");
            }

            String token = authHeader.substring(7).trim();
            if (!JwtUtil.validateToken(token)) {
                return Result.error("登录已过期，请重新登录");
            }

            // 2. 校验权限
            Long userId = JwtUtil.getUserId(token);
            if (!hasPermission(userId)) {
                return Result.error("无权限上传文件");
            }

            // 3. 校验文件类型
            if (!isValidFileExtension(file.getOriginalFilename())) {
                return Result.error("不支持的文件类型，请上传3D文件（stl, obj, 3ds, fbx, gltf, glb）");
            }

            // 4. 校验文件大小
            if (!isValidFileSize(file)) {
                return Result.error("文件大小超过限制（最大50MB）");
            }

            // 5. 保存文件
            String originalFilename = file.getOriginalFilename();
            String filePath = uploadFile(file);
            log.info("3D文件上传成功：{}（原始文件名：{}），用户ID：{}", filePath, originalFilename, userId);

            // 返回包含原始文件名和保存路径的结果
            java.util.HashMap<String, Object> result = new java.util.HashMap<>();
            result.put("originalFilename", originalFilename);
            result.put("filePath", filePath);

            return Result.success(result);

        } catch (IOException e) {
            log.error("文件保存失败", e);
            return Result.error("文件保存失败：" + e.getMessage());
        } catch (SecurityException e) {
            log.error("权限不足", e);
            return Result.error("权限不足，无法保存文件");
        } catch (Exception e) {
            log.error("上传失败", e);
            return Result.error("上传失败：" + e.getMessage());
        }
    }

    // 权限校验方法
    private boolean hasPermission(Long userId) {
        // 从数据库或配置文件中获取授权用户列表
        List<Long> authorizedUsers = Arrays.asList(101L, 102L, 103L);
        return userId != null && authorizedUsers.contains(userId);
    }

    // 文件类型校验
    private boolean isValidFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return false;
        }
        String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        return ALLOWED_EXTENSIONS.contains(extension);
    }

    // 文件大小校验
    private boolean isValidFileSize(MultipartFile file) {
        return file.getSize() <= MAX_FILE_SIZE;
    }

    // 公共文件上传逻辑
    private String uploadFile(MultipartFile file) throws IOException {
        String originalFilename = file.getOriginalFilename();
        String fileExtension = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf(".")) : "";
        String newFilename = UUID.randomUUID() + fileExtension;
        
        // 确保上传目录是绝对路径
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.isAbsolute()) {
            // 如果是相对路径，使用项目根目录作为基准
            String projectRoot = System.getProperty("user.dir");
            uploadDir = projectRoot + File.separator + uploadDir;
        }
        
        String uploadPath = uploadDir + "/3d/";
        File dir = new File(uploadPath);
        if (!dir.exists()) {
            // 创建目录时包含所有父目录
            if (!dir.mkdirs()) {
                throw new IOException("无法创建上传目录：" + uploadPath);
            }
        }
        
        File dest = new File(uploadPath + newFilename);
        file.transferTo(dest);
        
        return "/uploads/3d/" + newFilename;
    }

    // 多文件上传接口
    @PostMapping("/3d/multiple")
    public Result uploadMultiple3dFiles(@RequestParam("files") MultipartFile[] files, HttpServletRequest request) {
        if (files == null || files.length == 0) {
            return Result.error("文件不能为空");
        }

        try {
            // 1. 校验Token
            String authHeader = request.getHeader("Authorization");
            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return Result.error("未登录，请先登录");
            }

            String token = authHeader.substring(7).trim();
            if (!JwtUtil.validateToken(token)) {
                return Result.error("登录已过期，请重新登录");
            }

            // 2. 校验权限
            Long userId = JwtUtil.getUserId(token);
            if (!hasPermission(userId)) {
                return Result.error("无权限上传文件");
            }

            // 3. 保存文件
            List<String> successFiles = new ArrayList<>();
            List<String> failedFiles = new ArrayList<>();
            
            for (MultipartFile file : files) {
                if (file.isEmpty()) {
                    failedFiles.add("空文件");
                    continue;
                }

                // 校验文件类型
                if (!isValidFileExtension(file.getOriginalFilename())) {
                    failedFiles.add(file.getOriginalFilename() + "：不支持的文件类型");
                    continue;
                }

                // 校验文件大小
                if (!isValidFileSize(file)) {
                    failedFiles.add(file.getOriginalFilename() + "：文件大小超过限制（最大50MB）");
                    continue;
                }

                try {
                    String originalFilename = file.getOriginalFilename();
                    String filePath = uploadFile(file);
                    Map<String, Object> fileResult = new java.util.HashMap<>();
                    fileResult.put("originalFilename", originalFilename);
                    fileResult.put("filePath", filePath);
                    successFiles.add(filePath);
                    log.info("3D文件上传成功：{}（原始文件名：{}），用户ID：{}", filePath, originalFilename, userId);
                } catch (Exception e) {
                    failedFiles.add(file.getOriginalFilename() + "：上传失败（" + e.getMessage() + "）");
                    log.error("文件上传失败：{}", file.getOriginalFilename(), e);
                }
            }

            java.util.HashMap<String, Object> resultMap = new java.util.HashMap<>();
            resultMap.put("successFiles", successFiles);
            resultMap.put("failedFiles", failedFiles);
            return Result.success(resultMap);

        } catch (IllegalStateException e) {
            log.error("文件保存失败", e);
            return Result.error("文件保存失败：" + e.getMessage());
        } catch (SecurityException e) {
            log.error("权限不足", e);
            return Result.error("权限不足，无法保存文件");
        } catch (Exception e) {
            log.error("上传失败", e);
            return Result.error("上传失败：" + e.getMessage());
        }
    }
}