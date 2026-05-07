package com.example.medical.controller;

import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.entity.Nurse;
import com.example.medical.service.NurseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.HashMap;
import java.util.Map;

/**
 * 护士控制器
 */
@RestController
@RequestMapping("/nurse")
@CrossOrigin
@Validated
public class NurseController {

    @Autowired
    private NurseService nurseService;

    /**
     * 护士登录
     * POST /nurse/login
     */
    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody NurseLoginRequest request) {
        try {
            NurseLoginResponse response = nurseService.login(request);
            return Result.success(response);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 获取护士信息
     * GET /nurse/info
     */
    @GetMapping("/info")
    public Result<?> getNurseInfo(HttpServletRequest request) {
        try {
            // 从Token中获取护士ID
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            if (!JwtUtil.isNurseToken(token)) {
                return Result.error("无效的护士Token");
            }

            Long nurseId = JwtUtil.getNurseId(token);
            if (nurseId == null) {
                return Result.error("无法获取护士信息");
            }

            Nurse nurseInfo = nurseService.getById(nurseId);
            return Result.success(nurseInfo);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 更新护士信息
     * PUT /nurse/info
     */
    @PutMapping("/info")
    public Result<?> updateNurseInfo(
            HttpServletRequest request,
            @Valid @RequestBody NurseUpdateRequest updateRequest) {
        try {
            // 从Token中获取护士ID
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            if (!JwtUtil.isNurseToken(token)) {
                return Result.error("无效的护士Token");
            }

            Long nurseId = JwtUtil.getNurseId(token);
            if (nurseId == null) {
                return Result.error("无法获取护士信息");
            }

            Nurse updatedNurse = nurseService.updateNurseInfo(nurseId, updateRequest);
            return Result.success(updatedNurse);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 验证护士Token
     * GET /nurse/verify-token
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

            if (!JwtUtil.isNurseToken(token)) {
                return Result.error("不是护士Token");
            }

            Long nurseId = JwtUtil.getNurseId(token);
            Map<String, Object> result = new HashMap<>();
            result.put("nurseId", nurseId);
            result.put("valid", true);

            return Result.success(result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    /**
     * 根据护士工号查询护士信息
     * GET /nurse/by-no/{nurseNo}
     */
    @GetMapping("/by-no/{nurseNo}")
    public Result<?> getNurseByNo(@PathVariable String nurseNo) {
        try {
            Nurse nurse = nurseService.findByNurseNo(nurseNo);
            if (nurse == null) {
                return Result.error("护士工号不存在");
            }
            return Result.success(nurse);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
