package com.example.medical.dto.medicalimage;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class AnalyzeImageResponse implements Serializable {

    private static final long serialVersionUID = 1L;

    private String resultId;
    private Integer lesionCount;
    private Double overallConfidence;
    private List<LesionResponse> lesions;
    private List<String> recommendations;
    private Integer analysisDuration;

    @Data
    public static class LesionResponse implements Serializable {
        private static final long serialVersionUID = 1L;

        private String lesionId;
        private String lesionType;
        private String lesionName;
        private Double confidence;
        private String severity;
        private String description;
        private String boundingBox;
    }
}
