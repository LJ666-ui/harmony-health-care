package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.dto.FamilyLoginRequest;
import com.example.medical.dto.FamilyLoginResponse;
import com.example.medical.entity.FamilyMember;
import com.example.medical.service.FamilyAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

/**
 * 家属认证控制器
 */
@RestController
@RequestMapping("/family")
@CrossOrigin
@Validated
public class FamilyAuthController {

    @Autowired
    private FamilyAuthService familyAuthService;

    /**
     * 家属登录
     * POST /family/login
     */
    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody FamilyLoginRequest request) {
        try {
            FamilyLoginResponse response = familyAuthService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取家属信息
     * GET /family/info
     */
    @GetMapping("/info")
    public Result<?> getFamilyInfo(HttpServletRequest request) {
        try {
            // 从Token中获取家属ID
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            if (!JwtUtil.isFamilyToken(token)) {
                return Result.error("无效的家属Token");
            }

            Long familyId = JwtUtil.getFamilyId(token);
            if (familyId == null) {
                return Result.error("无法获取家属信息");
            }

            FamilyMember familyInfo = familyAuthService.getFamilyInfo(familyId);
            return Result.success(familyInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 开启/关闭家属登录权限
     * PUT /family/{familyId}/login-enabled
     */
    @PutMapping("/{familyId}/login-enabled")
    public Result<?> updateLoginEnabled(
            @PathVariable Long familyId,
            @RequestBody Map<String, Object> params) {
        try {
            Integer loginEnabled = (Integer) params.get("loginEnabled");
            String defaultPassword = (String) params.get("defaultPassword");

            boolean success = familyAuthService.updateLoginEnabled(familyId, loginEnabled, defaultPassword);
            if (success) {
                return Result.success("操作成功");
            } else {
                return Result.error("操作失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 验证家属Token
     * GET /family/verify-token
     */
    @GetMapping("/verify-token")
    public Result<?> verifyToken(HttpServletRequest request) {
        try {
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            if (!JwtUtil.validateToken(token)) {
                return Result.error("Token无效或已过期");
            }

            if (!JwtUtil.isFamilyToken(token)) {
                return Result.error("不是家属Token");
            }

            Long familyId = JwtUtil.getFamilyId(token);
            Map<String, Object> result = new HashMap<>();
            result.put("familyId", familyId);
            result.put("valid", true);

            return Result.success(result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
