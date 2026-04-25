package com.example.medical.dto;

import lombok.Data;

import java.util.List;

@Data
public class RiskAssessDTO {
    private String age;
    private String gender;
    private String height;
    private String weight;
    private Double bmi;
    private String systolic;
    private String diastolic;
    private String fastingGlucose;
    private String postprandialGlucose;
    private String smoking;
    private String drinking;
    private String exercise;
    private List<String> medicalHistory;
}
