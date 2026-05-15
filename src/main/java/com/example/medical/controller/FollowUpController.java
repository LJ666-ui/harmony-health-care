package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.FollowUp;
import com.example.medical.service.DataShareAuthService;
import com.example.medical.service.FollowUpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/medical")
@CrossOrigin
public class FollowUpController {

    @Autowired
    private FollowUpService followUpService;

    @Autowired
    private DataShareAuthService dataShareAuthService;

    private Long getCurrentUserId(String token) {
        if (token == null || token.isEmpty()) {
            return null;
        }
        if (JwtUtil.isDoctorToken(token)) {
            return JwtUtil.getDoctorId(token);
        }
        return JwtUtil.getUserId(token);
    }

    @GetMapping("/follow-up/list")
    public Result<List<FollowUp>> getPatientFollowUps(
            @RequestParam Long userId,
            @RequestHeader(value = "Token", required = false) String token) {
        try {
            Long accessUserId = getCurrentUserId(token);
            if (accessUserId != null && !userId.equals(accessUserId)) {
                boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, userId, "follow_up");
                if (!hasAuth) {
                    return Result.error("无权限查看该患者的复诊信息");
                }
            }
            List<FollowUp> followUps = followUpService.getPatientFollowUps(userId);
            return Result.success(followUps);
        } catch (Exception e) {
            return Result.error("获取复诊列表失败: " + e.getMessage());
        }
    }

    @PostMapping("/follow-up")
    public Result<FollowUp> createFollowUp(@RequestBody FollowUp followUp) {
        try {
            FollowUp result = followUpService.createFollowUp(followUp);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("创建复诊安排失败: " + e.getMessage());
        }
    }

    @PutMapping("/follow-up/{id}/status")
    public Result<FollowUp> updateFollowUpStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        try {
            String status = body.get("status");
            FollowUp result = followUpService.updateFollowUpStatus(id, status);
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("更新状态失败: " + e.getMessage());
        }
    }

    @GetMapping("/follow-up/{id}")
    public Result<FollowUp> getFollowUpDetail(
            @PathVariable Long id,
            @RequestHeader(value = "Token", required = false) String token) {
        try {
            FollowUp followUp = followUpService.getById(id);
            if (followUp == null) {
                return Result.error("复诊记录不存在");
            }

            Long accessUserId = getCurrentUserId(token);
            if (accessUserId != null && !followUp.getPatientId().equals(accessUserId)) {
                boolean hasAuth = dataShareAuthService.checkAuth(accessUserId, followUp.getPatientId(), "follow_up");
                if (!hasAuth) {
                    return Result.error("无权限查看该复诊记录");
                }
            }

            return Result.success(followUp);
        } catch (Exception e) {
            return Result.error("获取详情失败: " + e.getMessage());
        }
    }
}
