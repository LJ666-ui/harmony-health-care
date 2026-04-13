package com.example.medical.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class HospitalQueryDTO {
    private String province;
    private String city;
    private String level;
    private String deptName;
    private BigDecimal userLongitude;
    private BigDecimal userLatitude;
    private Integer page = 1;
    private Integer size = 10;
}
