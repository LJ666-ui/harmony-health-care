package com.example.medical.utils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class AIClient {

    private static final String API_URL = "https://api.siliconflow.cn/v1/chat/completions";
    private static final String API_KEY = "sk-nyvarnxvnqlheyvsvtqvkmdxjjsqaoacnududnkwjadpxhfv";
    private static final String MODEL = "deepseek-ai/DeepSeek-V3";
    private static final int TIMEOUT = 10;

    private final RestTemplate restTemplate;

    public AIClient() {
        this.restTemplate = new RestTemplate();
    }

    public String chat(String prompt) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + API_KEY);

            JSONObject body = new JSONObject();
            body.put("model", MODEL);
            body.put("max_tokens", 1024);
            body.put("temperature", 0.7);

            JSONArray messages = new JSONArray();
            JSONObject message = new JSONObject();
            message.put("role", "user");
            message.put("content", prompt);
            messages.add(message);
            body.put("messages", messages);

            HttpEntity<String> entity = new HttpEntity<>(body.toJSONString(), headers);

            String response = restTemplate.postForObject(API_URL, entity, String.class);

            if (response != null) {
                JSONObject jsonResponse = JSON.parseObject(response);
                JSONArray choices = jsonResponse.getJSONArray("choices");
                if (choices != null && !choices.isEmpty()) {
                    JSONObject choice = choices.getJSONObject(0);
                    JSONObject messageObj = choice.getJSONObject("message");
                    if (messageObj != null) {
                        return messageObj.getString("content");
                    }
                }
            }
            return null;
        } catch (Exception e) {
            throw new RuntimeException("AI服务调用失败: " + e.getMessage());
        }
    }
}
