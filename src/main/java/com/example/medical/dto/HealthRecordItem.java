package com.example.medical.dto;

import lombok.Data;

@Data
public class HealthRecordItem {
    private Long id;
    private String recordType;
    private String value;
    private String unit;
    private java.util.Date recordTime;
    private String remark;
    private Long userId;
}
