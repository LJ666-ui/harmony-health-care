package com.example.medical.service.medicalimage;

import com.example.medical.entity.medicalimage.*;
import com.example.medical.mapper.medicalimage.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class AIDiagnosisService {

    private static final double CONFIDENCE_THRESHOLD = 50.0;

    @Autowired
    private ImageMetadataMapper imageMetadataMapper;

    @Autowired
    private AIEngineAdapter aiEngineAdapter;

    @Autowired
    private DiagnosisRecordMapper diagnosisRecordMapper;

    @Autowired
    private LesionDetailMapper lesionDetailMapper;

    @Autowired
    private DiagnosisRecommendationMapper recommendationMapper;

    @Autowired
    private OperationAuditLogMapper auditLogMapper;

    @Transactional
    public DiagnosisResult analyzeImage(String imageId, String imageType, Long userId) {
        long startTime = System.currentTimeMillis();

        try {
            ImageMetadata metadata = imageMetadataMapper.selectById(imageId);
            if (metadata == null) {
                throw new RuntimeException("影像不存在: " + imageId);
            }

            AIEngineAdapter.AIAnalysisResult aiResult = 
                    aiEngineAdapter.analyze(metadata.getStorageUrl(), imageType);

            if (!aiResult.isSuccess()) {
                throw new RuntimeException("AI分析失败: " + aiResult.getErrorMessage());
            }

            List<AIEngineAdapter.LesionInfo> filteredLesions = filterLowConfidence(
                    aiResult.getLesions(), 
                    CONFIDENCE_THRESHOLD
            );

            Double overallConfidence = calculateOverallConfidence(filteredLesions);

            String resultId = generateResultId();

            DiagnosisRecord record = new DiagnosisRecord();
            record.setResultId(resultId);
            record.setImageId(imageId);
            record.setUserId(userId);
            record.setImageType(imageType);
            record.setLesionCount(filteredLesions.size());
            record.setOverallConfidence(BigDecimal.valueOf(overallConfidence));
            record.setAnalysisStatus("COMPLETED");
            record.setAnalysisTime(LocalDateTime.now());
            record.setAnalysisDuration((int) (System.currentTimeMillis() - startTime));
            record.setAiEngineVersion(aiResult.getAiEngineVersion());
            record.setCreatedAt(LocalDateTime.now());
            record.setUpdatedAt(LocalDateTime.now());

            diagnosisRecordMapper.insert(record);

            saveLesionDetails(resultId, filteredLesions);

            List<String> recommendations = generateRecommendations(filteredLesions);
            saveRecommendations(resultId, recommendations);

            recordAuditLog(userId, "ANALYZE", "DIAGNOSIS", resultId, 
                    "{\"lesionCount\":" + filteredLesions.size() + 
                    ",\"overallConfidence\":" + overallConfidence + "}");

            return new DiagnosisResult(
                    resultId,
                    filteredLesions.size(),
                    overallConfidence,
                    filteredLesions,
                    recommendations,
                    (int) (System.currentTimeMillis() - startTime)
            );

        } catch (Exception e) {
            throw new RuntimeException("AI诊断失败: " + e.getMessage(), e);
        }
    }

    private List<AIEngineAdapter.LesionInfo> filterLowConfidence(
            List<AIEngineAdapter.LesionInfo> lesions, double threshold) {
        if (lesions == null) {
            return new ArrayList<>();
        }

        return lesions.stream()
                .filter(l -> l.getConfidence() != null && l.getConfidence() >= threshold)
                .collect(Collectors.toList());
    }

    private Double calculateOverallConfidence(List<AIEngineAdapter.LesionInfo> lesions) {
        if (lesions == null || lesions.isEmpty()) {
            return 0.0;
        }

        double sum = lesions.stream()
                .mapToDouble(l -> l.getConfidence() != null ? l.getConfidence() : 0.0)
                .sum();

        return sum / lesions.size();
    }

    private void saveLesionDetails(String resultId, List<AIEngineAdapter.LesionInfo> lesions) {
        for (AIEngineAdapter.LesionInfo lesionInfo : lesions) {
            LesionDetail lesion = new LesionDetail();
            lesion.setLesionId(generateLesionId());
            lesion.setResultId(resultId);
            lesion.setLesionType(lesionInfo.getLesionType());
            lesion.setLesionName(lesionInfo.getLesionName());
            lesion.setPositionX(lesionInfo.getPositionX() != null ? 
                    BigDecimal.valueOf(lesionInfo.getPositionX()) : null);
            lesion.setPositionY(lesionInfo.getPositionY() != null ? 
                    BigDecimal.valueOf(lesionInfo.getPositionY()) : null);
            lesion.setBoundingBox(lesionInfo.getBoundingBox());
            lesion.setConfidence(BigDecimal.valueOf(lesionInfo.getConfidence()));
            lesion.setSeverity(lesionInfo.getSeverity());
            lesion.setDescription(lesionInfo.getDescription());
            lesion.setSizeMm(lesionInfo.getSizeMm() != null ? 
                    BigDecimal.valueOf(lesionInfo.getSizeMm()) : null);
            lesion.setShape(lesionInfo.getShape());
            lesion.setDensity(lesionInfo.getDensity());
            lesion.setEdge(lesionInfo.getEdge());
            lesion.setInternalStructure(lesionInfo.getInternalStructure());
            lesion.setCreatedAt(LocalDateTime.now());

            lesionDetailMapper.insert(lesion);
        }
    }

    private List<String> generateRecommendations(List<AIEngineAdapter.LesionInfo> lesions) {
        List<String> recommendations = new ArrayList<>();

        if (lesions.isEmpty()) {
            recommendations.add("未发现明显异常病灶，建议定期复查");
            return recommendations;
        }

        boolean hasCritical = lesions.stream()
                .anyMatch(l -> "CRITICAL".equals(l.getSeverity()));
        boolean hasSevere = lesions.stream()
                .anyMatch(l -> "SEVERE".equals(l.getSeverity()));

        if (hasCritical) {
            recommendations.add("发现危急病灶，建议立即就医进行进一步检查");
        } else if (hasSevere) {
            recommendations.add("发现重度异常，建议尽快就医咨询专业医生");
        } else {
            recommendations.add("发现异常病灶，建议咨询专业医生进行诊断");
        }

        recommendations.add("建议结合临床症状和其他检查结果综合判断");
        recommendations.add("如有不适症状，请及时就医");

        return recommendations;
    }

    private void saveRecommendations(String resultId, List<String> recommendations) {
        for (int i = 0; i < recommendations.size(); i++) {
            DiagnosisRecommendation recommendation = new DiagnosisRecommendation();
            recommendation.setResultId(resultId);
            recommendation.setRecommendationType("DIAGNOSIS");
            recommendation.setRecommendationText(recommendations.get(i));
            recommendation.setPriority(i + 1);
            recommendation.setCreatedAt(LocalDateTime.now());

            recommendationMapper.insert(recommendation);
        }
    }

    private String generateResultId() {
        return "RES-" + System.currentTimeMillis() + "-" + 
                UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private String generateLesionId() {
        return "LES-" + System.currentTimeMillis() + "-" + 
                UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private void recordAuditLog(Long userId, String operationType, String resourceType, 
                               String resourceId, String operationDetail) {
        OperationAuditLog auditLog = new OperationAuditLog();
        auditLog.setUserId(userId);
        auditLog.setOperationType(operationType);
        auditLog.setResourceType(resourceType);
        auditLog.setResourceId(resourceId);
        auditLog.setOperationDetail(operationDetail);
        auditLog.setOperationTime(LocalDateTime.now());
        auditLog.setCreatedAt(LocalDateTime.now());

        auditLogMapper.insert(auditLog);
    }

    public static class DiagnosisResult {
        private final String resultId;
        private final int lesionCount;
        private final Double overallConfidence;
        private final List<AIEngineAdapter.LesionInfo> lesions;
        private final List<String> recommendations;
        private final int analysisDuration;

        public DiagnosisResult(String resultId, int lesionCount, Double overallConfidence, 
                              List<AIEngineAdapter.LesionInfo> lesions, 
                              List<String> recommendations, int analysisDuration) {
            this.resultId = resultId;
            this.lesionCount = lesionCount;
            this.overallConfidence = overallConfidence;
            this.lesions = lesions;
            this.recommendations = recommendations;
            this.analysisDuration = analysisDuration;
        }

        public String getResultId() {
            return resultId;
        }

        public int getLesionCount() {
            return lesionCount;
        }

        public Double getOverallConfidence() {
            return overallConfidence;
        }

        public List<AIEngineAdapter.LesionInfo> getLesions() {
            return lesions;
        }

        public List<String> getRecommendations() {
            return recommendations;
        }

        public int getAnalysisDuration() {
            return analysisDuration;
        }
    }
}
