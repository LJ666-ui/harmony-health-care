package com.example.medical.service.medicalimage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;

@Service
public class ImageCompressor {

    @Value("${medical-image.compression-quality:0.5}")
    private float compressionQuality;

    @Value("${medical-image.preview-width:800}")
    private int previewWidth;

    @Value("${medical-image.preview-height:600}")
    private int previewHeight;

    public byte[] compressJpeg(byte[] originalData) throws IOException {
        return compressImage(originalData, "jpg", compressionQuality);
    }

    public byte[] compressPng(byte[] originalData) throws IOException {
        return compressImage(originalData, "png", compressionQuality);
    }

    public byte[] compressImage(byte[] originalData, String format, float quality) throws IOException {
        ByteArrayInputStream bais = new ByteArrayInputStream(originalData);
        BufferedImage originalImage = ImageIO.read(bais);

        if (originalImage == null) {
            throw new IOException("无法读取影像数据");
        }

        BufferedImage resizedImage = resizeImage(originalImage, previewWidth, previewHeight);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        if ("jpg".equalsIgnoreCase(format) || "jpeg".equalsIgnoreCase(format)) {
            ImageIO.write(resizedImage, "jpg", baos);
        } else {
            ImageIO.write(resizedImage, "png", baos);
        }

        return baos.toByteArray();
    }

    public byte[] generatePreview(byte[] originalData, String format) throws IOException {
        ByteArrayInputStream bais = new ByteArrayInputStream(originalData);
        BufferedImage originalImage = ImageIO.read(bais);

        if (originalImage == null) {
            throw new IOException("无法读取影像数据");
        }

        int targetWidth = Math.min(originalImage.getWidth(), previewWidth);
        int targetHeight = Math.min(originalImage.getHeight(), previewHeight);

        double aspectRatio = (double) originalImage.getWidth() / originalImage.getHeight();
        if (aspectRatio > 1) {
            targetHeight = (int) (targetWidth / aspectRatio);
        } else {
            targetWidth = (int) (targetHeight * aspectRatio);
        }

        BufferedImage previewImage = resizeImage(originalImage, targetWidth, targetHeight);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        String outputFormat = "jpg".equalsIgnoreCase(format) || "jpeg".equalsIgnoreCase(format) ? "jpg" : "png";
        ImageIO.write(previewImage, outputFormat, baos);

        return baos.toByteArray();
    }

    private BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) {
        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();

        if (originalWidth <= targetWidth && originalHeight <= targetHeight) {
            return originalImage;
        }

        BufferedImage resizedImage = new BufferedImage(targetWidth, targetHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics2D = resizedImage.createGraphics();

        graphics2D.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        graphics2D.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        graphics2D.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        graphics2D.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
        graphics2D.dispose();

        return resizedImage;
    }

    public CompressionResult compress(byte[] originalData, String format) throws IOException {
        long startTime = System.currentTimeMillis();

        byte[] compressedData;
        if ("jpg".equalsIgnoreCase(format) || "jpeg".equalsIgnoreCase(format)) {
            compressedData = compressJpeg(originalData);
        } else if ("png".equalsIgnoreCase(format)) {
            compressedData = compressPng(originalData);
        } else {
            compressedData = compressImage(originalData, "jpg", compressionQuality);
        }

        long duration = System.currentTimeMillis() - startTime;
        double compressionRatio = (1 - (double) compressedData.length / originalData.length) * 100;

        return new CompressionResult(compressedData, duration, compressionRatio);
    }

    public static class CompressionResult {
        private final byte[] compressedData;
        private final long duration;
        private final double compressionRatio;

        public CompressionResult(byte[] compressedData, long duration, double compressionRatio) {
            this.compressedData = compressedData;
            this.duration = duration;
            this.compressionRatio = compressionRatio;
        }

        public byte[] getCompressedData() {
            return compressedData;
        }

        public long getDuration() {
            return duration;
        }

        public double getCompressionRatio() {
            return compressionRatio;
        }
    }
}
