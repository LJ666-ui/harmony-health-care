package com.example.medical.dto;

import lombok.Data;

@Data
public class AIChatRequest {
    private String question;
    private String healthProfile;
    private String type;
}
