package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.dto.NurseLoginRequest;
import com.example.medical.dto.NurseLoginResponse;
import com.example.medical.dto.NurseUpdateRequest;
import com.example.medical.entity.FamilyMember;
import com.example.medical.entity.Nurse;
import com.example.medical.entity.NursePatientRelation;
import com.example.medical.entity.User;
import com.example.medical.service.FamilyAuthService;
import com.example.medical.service.NursePatientRelationService;
import com.example.medical.service.NurseService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.*;
import java.util.stream.Collectors;

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

    @Autowired
    private UserService userService;

    @Autowired
    private FamilyAuthService familyAuthService;

    @Autowired
    private NursePatientRelationService nursePatientRelationService;

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
     * 获取护士列表（供家属/患者选择）
     * GET /nurse/list
     */
    @GetMapping("/list")
    public Result<?> getNurseList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String department) {
        try {
            LambdaQueryWrapper<Nurse> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Nurse::getStatus, 1);
            wrapper.eq(Nurse::getIsDeleted, 0);

            if (keyword != null && !keyword.trim().isEmpty()) {
                wrapper.like(Nurse::getNurseNo, keyword);
            }

            if (department != null && !department.trim().isEmpty()) {
                wrapper.like(Nurse::getDepartment, department);
            }

            wrapper.orderByAsc(Nurse::getId);

            List<Nurse> nurses = nurseService.list(wrapper);

            for (Nurse nurse : nurses) {
                if (nurse.getUserId() != null) {
                    User nurseUser = userService.getById(nurse.getUserId());
                    if (nurseUser != null) {
                        nurse.setName(nurseUser.getRealName());
                        nurse.setPhone(nurseUser.getPhone());
                    }
                }
            }

            return Result.success(nurses);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取护士列表失败：" + e.getMessage());
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

    /**
     * 获取护士负责的所有患者的家属列表
     * GET /nurse/families
     */
    @GetMapping("/families")
    public Result<?> getFamiliesByNurse(HttpServletRequest request) {
        try {
            Long nurseId = null;

            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);

                if (JwtUtil.isNurseToken(token)) {
                    nurseId = JwtUtil.getNurseId(token);
                }
            }

            if (nurseId == null) {
                return Result.error("无法获取护士信息");
            }

            List<Long> patientIds = nursePatientRelationService.getPatientIdsByNurseId(nurseId);

            if (patientIds == null || patientIds.isEmpty()) {
                return Result.success(new ArrayList<>());
            }

            QueryWrapper<FamilyMember> wrapper = new QueryWrapper<>();
            wrapper.in("user_id", patientIds);
            wrapper.eq("is_deleted", 0);
            wrapper.orderByDesc("is_emergency_contact");
            wrapper.orderByAsc("create_time");

            List<FamilyMember> familyMembers = familyAuthService.list(wrapper);

            Map<Long, User> userMap = new HashMap<>();
            for (Long patientId : patientIds) {
                User patient = userService.getById(patientId);
                if (patient != null) {
                    userMap.put(patientId, patient);
                }
            }

            List<Map<String, Object>> result = new ArrayList<>();
            for (FamilyMember member : familyMembers) {
                Map<String, Object> familyInfo = new HashMap<>();
                familyInfo.put("id", member.getId());
                familyInfo.put("name", member.getName());
                familyInfo.put("phone", member.getPhone());
                familyInfo.put("relation", member.getRelation());
                familyInfo.put("relatedPatientId", member.getUserId());

                User relatedUser = userMap.get(member.getUserId());
                if (relatedUser != null) {
                    familyInfo.put("relatedPatientName", relatedUser.getRealName());
                } else {
                    familyInfo.put("relatedPatientName", "未知患者");
                }

                result.add(familyInfo);
            }

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取家属列表失败：" + e.getMessage());
        }
    }
}
