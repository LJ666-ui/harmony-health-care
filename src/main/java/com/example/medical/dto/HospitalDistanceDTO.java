package com.example.medical.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class HospitalDistanceDTO {
    private Long id;
    private String name;
    private String address;
    private String phone;
    private String level;
    private String description;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private Double distance;
}
