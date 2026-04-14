package com.example.medical.dto;

import lombok.Data;

@Data
public class KnowledgeExploreRequest {
    private String query;
    private Long centerId;
    private Integer depth;
}
