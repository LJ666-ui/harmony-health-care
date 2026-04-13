package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.dto.AIChatRequest;
import com.example.medical.entity.AIConversation;
import com.example.medical.service.AIService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/ai")
@CrossOrigin
@Validated
public class AIAssistantController {

    @Autowired
    private AIService aiService;

    @PostMapping("/chat")
    public Result<?> chat(@RequestBody AIChatRequest request) {
        try {
            if (request.getQuestion() == null || request.getQuestion().trim().isEmpty()) {
                return Result.error("问题不能为空");
            }
            String answer = aiService.chatWithAI(request);
            if (answer != null) {
                return Result.success(answer);
            }
            return Result.error("AI暂时无法回答，请稍后重试");
        } catch (Exception e) {
            return Result.error("AI服务繁忙，请稍后再试");
        }
    }

    @PostMapping("/health-consult")
    public Result<?> healthConsult(@RequestBody AIChatRequest request) {
        try {
            if (request.getQuestion() == null || request.getQuestion().trim().isEmpty()) {
                return Result.error("健康问题不能为空");
            }
            request.setType("health_consult");
            String advice = aiService.generateHealthAdvice(request.getQuestion(), request.getHealthProfile());
            if (advice != null) {
                return Result.success(advice);
            }
            return Result.error("AI暂时无法提供咨询建议");
        } catch (Exception e) {
            return Result.error("咨询服务繁忙，请稍后再试");
        }
    }

    @PostMapping("/risk-analysis")
    public Result<?> riskAnalysis(@RequestBody String riskData) {
        try {
            if (riskData == null || riskData.trim().isEmpty()) {
                return Result.error("风险评估数据不能为空");
            }
            String analysis = aiService.analyzeRiskAssessment(riskData);
            if (analysis != null) {
                return Result.success(analysis);
            }
            return Result.error("AI暂时无法分析风险数据");
        } catch (Exception e) {
            return Result.error("风险分析服务繁忙，请稍后再试");
        }
    }

    @PostMapping("/rehab-guide")
    public Result<?> rehabGuide(@RequestBody String rehabInfo) {
        try {
            if (rehabInfo == null || rehabInfo.trim().isEmpty()) {
                return Result.error("康复信息不能为空");
            }
            String guide = aiService.generateRehabGuide(rehabInfo);
            if (guide != null) {
                return Result.success(guide);
            }
            return Result.error("AI暂时无法生成康复指导");
        } catch (Exception e) {
            return Result.error("康复指导服务繁忙，请稍后再试");
        }
    }

    @GetMapping("/history")
    public Result<?> getHistory(@RequestParam(required = false) Long userId) {
        try {
            List<AIConversation> history = aiService.getHistory(userId);
            return Result.success(history);
        } catch (Exception e) {
            return Result.error("获取历史记录失败");
        }
    }
}
