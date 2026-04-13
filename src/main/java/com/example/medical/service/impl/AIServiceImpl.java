package com.example.medical.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.dto.AIChatRequest;
import com.example.medical.entity.AIConversation;
import com.example.medical.mapper.AIConversationMapper;
import com.example.medical.service.AIService;
import com.example.medical.utils.AIClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class AIServiceImpl extends com.baomidou.mybatisplus.extension.service.impl.ServiceImpl<AIConversationMapper, AIConversation> implements AIService {

    @Autowired
    private AIClient aiClient;

    @Override
    public String chatWithAI(AIChatRequest request) {
        String answer = generateHealthAdvice(request.getQuestion(), request.getHealthProfile());
        saveConversation(null, request.getQuestion(), answer, "chat");
        return answer;
    }

    @Override
    public String generateHealthAdvice(String question, String healthProfile) {
        String prompt = buildHealthConsultPrompt(question, healthProfile);
        String answer = aiClient.chat(prompt);
        saveConversation(null, question, answer, "health_consult");
        return answer;
    }

    private String buildHealthConsultPrompt(String question, String healthProfile) {
        StringBuilder sb = new StringBuilder();
        sb.append("你是专业医疗助手，专门服务老年人群体。\n");
        sb.append("用户问题：").append(question).append("\n");
        if (healthProfile != null && !healthProfile.isEmpty()) {
            sb.append("用户健康档案：").append(healthProfile).append("\n");
        }
        sb.append("\n请遵循以下要求回答：\n");
        sb.append("1. 使用通俗易懂的语言，避免专业医学术语\n");
        sb.append("2. 提供具体可行的建议\n");
        sb.append("3. 如果涉及严重症状，务必建议及时就医\n");
        sb.append("4. 回答控制在200字以内\n");
        sb.append("5. 语气温暖亲切，像家人一样关心\n");
        return sb.toString();
    }

    @Override
    public String analyzeRiskAssessment(String riskData) {
        String prompt = buildRiskAnalysisPrompt(riskData);
        String answer = aiClient.chat(prompt);
        saveConversation(null, riskData, answer, "risk_analysis");
        return answer;
    }

    private String buildRiskAnalysisPrompt(String riskData) {
        StringBuilder sb = new StringBuilder();
        sb.append("【角色设定】你是一位经验丰富的老年健康风险评估专家。\n\n");
        sb.append("【核心任务】解读以下健康风险数据，给出专业、准确、有分寸的评估意见。\n\n");
        sb.append("【语气分级标准 - 必须严格执行】\n");
        sb.append("═══════════════════════════════════════\n");
        sb.append("🔴 极高风险（出现'极高''严重'等词汇）：\n");
        sb.append("   → 语气：严肃、紧迫、警示性强\n");
        sb.append("   → 开头必须用：⚠️⚠️⚠️ 紧急提醒 ⚠️⚠️⚠️\n");
        sb.append("   → 必须包含：'请立即就医''不可拖延''需要重视'\n");
        sb.append("   → 禁止：任何轻松、庆祝、开心的表达\n");
        sb.append("   → 结尾强调：健康第一，尽快行动\n\n");
        sb.append("🟡 中等风险：\n");
        sb.append("   → 语气：认真、关切、督促改善\n");
        sb.append("   → 重点：提出具体改善方案\n\n");
        sb.append("🟢 低风险：\n");
        sb.append("   → 语气：温和、鼓励、肯定\n");
        sb.append("   → 重点：继续保持良好习惯\n");
        sb.append("═══════════════════════════════════════\n\n");
        sb.append("【用户的评估结果】\n").append(riskData).append("\n\n");
        sb.append("【输出要求】\n");
        sb.append("1. 首先明确判断风险等级，用对应语气回复\n");
        sb.append("2. 简要解释各项指标的含义（用老人能懂的话）\n");
        sb.append("3. 给出3条具体可操作的建议\n");
        sb.append("4. 高风险时必须在开头和结尾双重强调就医重要性\n");
        sb.append("5. 控制在250字以内\n\n");
        sb.append("【示例 - 极高风险回复风格】\n");
        sb.append("\"⚠️⚠️⚠️ 紧急提醒 ⚠️⚠️⚠️\n");
        sb.append("您的评估结果显示多项指标处于极高水平！这绝不是危言耸听...\n");
        sb.append("请务必在3天内前往医院就诊...\"\n");
        return sb.toString();
    }

    @Override
    public String generateRehabGuide(String rehabInfo) {
        String prompt = buildRehabGuidePrompt(rehabInfo);
        String answer = aiClient.chat(prompt);
        saveConversation(null, rehabInfo, answer, "rehab_guide");
        return answer;
    }

    private String buildRehabGuidePrompt(String rehabInfo) {
        StringBuilder sb = new StringBuilder();
        sb.append("你是一位专业的康复教练，擅长指导老年人进行康复训练。\n");
        sb.append("用户康复信息：").append(rehabInfo).append("\n\n");
        sb.append("请提供以下康复指导：\n");
        sb.append("1. 热身建议（5-10分钟简单活动）\n");
        sb.append("2. 核心康复动作要领（分步骤详细说明）\n");
        sb.append("3. 训练后放松建议\n");
        sb.append("4. 出现不适时的处理方法\n");
        sb.append("5. 注意事项提醒\n");
        sb.append("\n要求：语言简洁明了，动作描述具体，考虑老年人身体特点，控制在300字以内");
        return sb.toString();
    }

    @Override
    public List<AIConversation> getHistory(Long userId) {
        QueryWrapper<AIConversation> wrapper = new QueryWrapper<>();
        if (userId != null) {
            wrapper.eq("user_id", userId);
        }
        wrapper.orderByDesc("create_time");
        wrapper.last("LIMIT 50");
        return list(wrapper);
    }

    private void saveConversation(Long userId, String question, String answer, String type) {
        if (answer == null || answer.isEmpty()) {
            return;
        }
        AIConversation conversation = new AIConversation();
        conversation.setUserId(userId);
        conversation.setQuestion(question);
        conversation.setAnswer(answer);
        conversation.setType(type);
        conversation.setCreateTime(new Date());
        save(conversation);
    }
}
