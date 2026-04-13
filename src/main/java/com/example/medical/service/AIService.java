package com.example.medical.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.medical.dto.AIChatRequest;
import com.example.medical.entity.AIConversation;

import java.util.List;

public interface AIService extends IService<AIConversation> {
    String chatWithAI(AIChatRequest request);
    String generateHealthAdvice(String question, String healthProfile);
    String analyzeRiskAssessment(String riskData);
    String generateRehabGuide(String rehabInfo);
    List<AIConversation> getHistory(Long userId);
}
