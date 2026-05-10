package com.example.medical.service.medicalimage;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AIEngineAdapter {

    @Value("${ai.engine.url}")
    private String aiEngineUrl;

    @Value("${ai.engine.timeout:30000}")
    private int timeout;

    @Value("${ai.engine.retry-count:1}")
    private int retryCount;

    @Value("${ai.engine.version:1.0.0}")
    private String aiEngineVersion;

    private final RestTemplate restTemplate;

    public AIEngineAdapter() {
        this.restTemplate = new RestTemplate();
    }

    public AIAnalysisResult analyze(String imageStorageUrl, String imageType) {
        String url = aiEngineUrl + "/analyze";

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("image_url", imageStorageUrl);
        requestBody.put("image_type", imageType);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-Request-Id", generateRequestId());

        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);

        Exception lastException = null;
        for (int i = 0; i <= retryCount; i++) {
            try {
                ResponseEntity<String> response = restTemplate.exchange(
                        url,
                        HttpMethod.POST,
                        request,
                        String.class
                );

                if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                    return parseResponse(response.getBody());
                }
            } catch (Exception e) {
                lastException = e;
                if (i < retryCount) {
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        }

        throw new RuntimeException("AI引擎调用失败: " + (lastException != null ? lastException.getMessage() : "未知错误"));
    }

    private AIAnalysisResult parseResponse(String responseBody) {
        JSONObject response = JSON.parseObject(responseBody);
        AIAnalysisResult result = new AIAnalysisResult();
        result.setSuccess(response.getBoolean("success"));

        if (!result.isSuccess()) {
            result.setErrorMessage(response.getString("error"));
            return result;
        }

        JSONArray lesionsArray = response.getJSONArray("lesions");
        List<LesionInfo> lesions = new ArrayList<>();

        if (lesionsArray != null) {
            for (int i = 0; i < lesionsArray.size(); i++) {
                JSONObject lesionObj = lesionsArray.getJSONObject(i);
                LesionInfo lesion = new LesionInfo();
                lesion.setLesionType(lesionObj.getString("type"));
                lesion.setLesionName(lesionObj.getString("name"));
                lesion.setConfidence(lesionObj.getDouble("confidence"));
                lesion.setSeverity(lesionObj.getString("severity"));
                lesion.setDescription(lesionObj.getString("description"));

                JSONObject bbox = lesionObj.getJSONObject("bounding_box");
                if (bbox != null) {
                    lesion.setBoundingBox(bbox.toJSONString());
                    lesion.setPositionX(bbox.getDouble("x"));
                    lesion.setPositionY(bbox.getDouble("y"));
                }

                JSONObject features = lesionObj.getJSONObject("features");
                if (features != null) {
                    lesion.setSizeMm(features.getDouble("size_mm"));
                    lesion.setShape(features.getString("shape"));
                    lesion.setDensity(features.getString("density"));
                    lesion.setEdge(features.getString("edge"));
                    lesion.setInternalStructure(features.getString("internal_structure"));
                }

                lesions.add(lesion);
            }
        }

        result.setLesions(lesions);
        result.setOverallConfidence(response.getDouble("overall_confidence"));
        result.setAiEngineVersion(aiEngineVersion);

        return result;
    }

    private String generateRequestId() {
        return "REQ-" + System.currentTimeMillis() + "-" + (int) (Math.random() * 10000);
    }

    public static class AIAnalysisResult {
        private boolean success;
        private String errorMessage;
        private List<LesionInfo> lesions;
        private Double overallConfidence;
        private String aiEngineVersion;

        public boolean isSuccess() {
            return success;
        }

        public void setSuccess(boolean success) {
            this.success = success;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public void setErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
        }

        public List<LesionInfo> getLesions() {
            return lesions;
        }

        public void setLesions(List<LesionInfo> lesions) {
            this.lesions = lesions;
        }

        public Double getOverallConfidence() {
            return overallConfidence;
        }

        public void setOverallConfidence(Double overallConfidence) {
            this.overallConfidence = overallConfidence;
        }

        public String getAiEngineVersion() {
            return aiEngineVersion;
        }

        public void setAiEngineVersion(String aiEngineVersion) {
            this.aiEngineVersion = aiEngineVersion;
        }
    }

    public static class LesionInfo {
        private String lesionType;
        private String lesionName;
        private Double confidence;
        private String severity;
        private String description;
        private Double positionX;
        private Double positionY;
        private String boundingBox;
        private Double sizeMm;
        private String shape;
        private String density;
        private String edge;
        private String internalStructure;

        public String getLesionType() {
            return lesionType;
        }

        public void setLesionType(String lesionType) {
            this.lesionType = lesionType;
        }

        public String getLesionName() {
            return lesionName;
        }

        public void setLesionName(String lesionName) {
            this.lesionName = lesionName;
        }

        public Double getConfidence() {
            return confidence;
        }

        public void setConfidence(Double confidence) {
            this.confidence = confidence;
        }

        public String getSeverity() {
            return severity;
        }

        public void setSeverity(String severity) {
            this.severity = severity;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public Double getPositionX() {
            return positionX;
        }

        public void setPositionX(Double positionX) {
            this.positionX = positionX;
        }

        public Double getPositionY() {
            return positionY;
        }

        public void setPositionY(Double positionY) {
            this.positionY = positionY;
        }

        public String getBoundingBox() {
            return boundingBox;
        }

        public void setBoundingBox(String boundingBox) {
            this.boundingBox = boundingBox;
        }

        public Double getSizeMm() {
            return sizeMm;
        }

        public void setSizeMm(Double sizeMm) {
            this.sizeMm = sizeMm;
        }

        public String getShape() {
            return shape;
        }

        public void setShape(String shape) {
            this.shape = shape;
        }

        public String getDensity() {
            return density;
        }

        public void setDensity(String density) {
            this.density = density;
        }

        public String getEdge() {
            return edge;
        }

        public void setEdge(String edge) {
            this.edge = edge;
        }

        public String getInternalStructure() {
            return internalStructure;
        }

        public void setInternalStructure(String internalStructure) {
            this.internalStructure = internalStructure;
        }
    }
}
