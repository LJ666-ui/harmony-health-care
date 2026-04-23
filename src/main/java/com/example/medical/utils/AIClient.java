package com.example.medical.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class AIClient {

    private static final Logger log = LoggerFactory.getLogger(AIClient.class);
    private static final String API_URL = "https://api.siliconflow.cn/v1/chat/completions";
    private static final String API_KEY = "sk-nyvarnxvnqlheyvsvtqvkmdxjjsqaoacnududnkwjadpxhfv";
    private static final String MODEL = "deepseek-ai/DeepSeek-V3";
    private static final int TIMEOUT = 15;

    private final RestTemplate restTemplate;

    public AIClient() {
        this.restTemplate = new RestTemplate();
    }

    public String chat(String prompt) {
        if (prompt == null || prompt.trim().isEmpty()) {
            log.warn("[AI] prompt为空");
            return null;
        }
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + API_KEY);

            JSONObject body = new JSONObject();
            body.put("model", MODEL);
            body.put("max_tokens", 512);
            body.put("temperature", 0.7);

            JSONArray messages = new JSONArray();
            JSONObject message = new JSONObject();
            message.put("role", "user");
            message.put("content", prompt);
            messages.add(message);
            body.put("messages", messages);

            HttpEntity<String> entity = new HttpEntity<>(body.toJSONString(), headers);

            log.info("[AI] 发送请求, prompt长度={}", prompt.length());
            String response = restTemplate.postForObject(API_URL, entity, String.class);

            if (response != null) {
                JSONObject jsonResponse = JSON.parseObject(response);
                JSONArray choices = jsonResponse.getJSONArray("choices");
                if (choices != null && !choices.isEmpty()) {
                    JSONObject choice = choices.getJSONObject(0);
                    JSONObject messageObj = choice.getJSONObject("message");
                    if (messageObj != null) {
                        String content = messageObj.getString("content");
                        log.info("[AI] 响应成功, 内容长度={}", content != null ? content.length() : 0);
                        return content;
                    }
                }
                log.warn("[AI] 响应格式异常: {}", response.substring(0, Math.min(response.length(), 200)));
            } else {
                log.warn("[AI] 响应为空");
            }
            return null;
        } catch (Exception e) {
            log.error("[AI] AI服务调用失败: {}", e.getMessage(), e);
            return null;
        }
    }
}
