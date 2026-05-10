package com.example.medical.service.medicalimage;

import io.minio.*;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.concurrent.TimeUnit;

@Service
public class FileStorageAdapter {

    private static final Logger logger = LoggerFactory.getLogger(FileStorageAdapter.class);

    @Value("${minio.endpoint}")
    private String endpoint;

    @Value("${minio.access-key}")
    private String accessKey;

    @Value("${minio.secret-key}")
    private String secretKey;

    @Value("${minio.bucket-name}")
    private String bucketName;

    @Value("${minio.preview-url-expiry:3600}")
    private int previewUrlExpiry;

    private MinioClient minioClient;
    private boolean initialized = false;
    private String initializationError = null;

    @PostConstruct
    public void init() {
        try {
            logger.info("正在初始化MinIO客户端...");
            logger.info("MinIO Endpoint: {}", endpoint);
            logger.info("Bucket Name: {}", bucketName);

            minioClient = MinioClient.builder()
                    .endpoint(endpoint)
                    .credentials(accessKey, secretKey)
                    .build();

            boolean bucketExists = minioClient.bucketExists(BucketExistsArgs.builder()
                    .bucket(bucketName)
                    .build());

            if (!bucketExists) {
                logger.info("Bucket '{}' 不存在，正在创建...", bucketName);
                minioClient.makeBucket(MakeBucketArgs.builder()
                        .bucket(bucketName)
                        .build());
                logger.info("Bucket '{}' 创建成功", bucketName);
            } else {
                logger.info("Bucket '{}' 已存在", bucketName);
            }

            initialized = true;
            logger.info("✅ MinIO初始化成功！文件存储功能已就绪");

        } catch (Exception e) {
            initialized = false;
            initializationError = e.getMessage();
            logger.error("❌ MinIO初始化失败，文件存储功能将不可用");
            logger.error("   错误详情: {}", e.getMessage());
            logger.error("   Endpoint: {}", endpoint);
            logger.error("   可能的原因:");
            logger.error("   1. MinIO服务未启动");
            logger.error("   2. MinIO端口配置错误 (当前: {})", endpoint);
            logger.error("   3. 网络连接问题");
            logger.error("   4. 访问密钥配置错误");
            logger.error("");
            logger.error("   解决方案:");
            logger.error("   方案1 - 启动MinIO服务 (推荐):");
            logger.error("     Docker: docker run -p 9000:9000 minio/minio server /data");
            logger.error("     或查看项目中的 docker-compose.yml 文件");
            logger.error("");
            logger.error("   方案2 - 临时禁用文件存储功能:");
            logger.error("     应用仍可正常运行，但医学影像上传功能将不可用");
            logger.error("");
            logger.error("   详细异常信息:", e);
        }
    }

    private void checkInitialized() {
        if (!initialized) {
            throw new RuntimeException(
                "MinIO服务未初始化，文件存储功能不可用。" +
                "原因: " + initializationError +
                "。请检查MinIO服务是否启动（Endpoint: " + endpoint + "）"
            );
        }
    }

    public boolean isInitialized() {
        return initialized;
    }

    public String getInitializationError() {
        return initializationError;
    }

    public String store(byte[] fileData, String objectName, String contentType) {
        checkInitialized();
        try {
            InputStream inputStream = new ByteArrayInputStream(fileData);

            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .stream(inputStream, fileData.length, -1)
                            .contentType(contentType)
                            .build()
            );

            return getStorageUrl(objectName);
        } catch (Exception e) {
            throw new RuntimeException("文件存储失败: " + e.getMessage(), e);
        }
    }

    public InputStream retrieve(String objectName) {
        checkInitialized();
        try {
            return minioClient.getObject(
                    GetObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("文件获取失败: " + e.getMessage(), e);
        }
    }

    public String generatePreviewUrl(String objectName) {
        checkInitialized();
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(bucketName)
                            .object(objectName)
                            .expiry(previewUrlExpiry, TimeUnit.SECONDS)
                            .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("预览URL生成失败: " + e.getMessage(), e);
        }
    }

    public void delete(String objectName) {
        checkInitialized();
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("文件删除失败: " + e.getMessage(), e);
        }
    }

    private String getStorageUrl(String objectName) {
        return endpoint + "/" + bucketName + "/" + objectName;
    }
}
