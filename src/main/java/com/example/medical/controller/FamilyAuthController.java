package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
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
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 家属认证控制器（包含CRUD操作）
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

    /**
     * 添加家属
     * POST /family
     */
    @PostMapping("")
    public Result<?> addFamilyMember(@RequestBody Map<String, Object> params, HttpServletRequest request) {
        try {
            Long userId = null;
            
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
                
                if (JwtUtil.isUserToken(token)) {
                    userId = JwtUtil.getUserId(token);
                } else if (JwtUtil.isFamilyToken(token)) {
                    Long familyId = JwtUtil.getFamilyId(token);
                    FamilyMember family = familyAuthService.getById(familyId);
                    if (family != null) {
                        userId = family.getUserId();
                    }
                }
            }
            
            if (userId == null) {
                userId = params.get("userId") != null ? Long.valueOf(params.get("userId").toString()) : 1L;
            }

            FamilyMember member = new FamilyMember();
            member.setUserId(userId);
            member.setName(params.get("name") != null ? params.get("name").toString() : "");
            member.setRelation(params.get("relation") != null ? params.get("relation").toString() : "其他");
            member.setPhone(params.get("phone") != null ? params.get("phone").toString() : "");
            
            if (params.get("idCard") != null) {
                member.setIdCard(params.get("idCard").toString());
            }
            if (params.get("gender") != null) {
                member.setGender(Integer.valueOf(params.get("gender").toString()));
            }
            if (params.get("age") != null) {
                member.setAge(Integer.valueOf(params.get("age").toString()));
            }
            if (params.get("address") != null) {
                member.setAddress(params.get("address").toString());
            }
            if (params.get("isEmergencyContact") != null) {
                Object emergencyObj = params.get("isEmergencyContact");
                if (emergencyObj instanceof Boolean) {
                    member.setIsEmergencyContact((Boolean) emergencyObj ? 1 : 0);
                } else if (emergencyObj instanceof Integer) {
                    member.setIsEmergencyContact((Integer) emergencyObj);
                } else {
                    member.setIsEmergencyContact(Boolean.valueOf(emergencyObj.toString()) ? 1 : 0);
                }
            } else {
                member.setIsEmergencyContact(0);
            }
            
            member.setCreateTime(new Date());
            member.setUpdateTime(new Date());
            member.setIsDeleted(0);

            boolean success = familyAuthService.save(member);
            if (success) {
                Map<String, Object> result = new HashMap<>();
                result.put("id", member.getId());
                result.put("message", "添加成功");
                return Result.success(result);
            } else {
                return Result.error("添加失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加失败：" + e.getMessage());
        }
    }

    /**
     * 获取我的家属列表
     * GET /family/my
     */
    @GetMapping("/my")
    public Result<?> getMyFamilyMembers(HttpServletRequest request) {
        try {
            Long userId = null;
            
            String token = request.getHeader("Authorization");
            if (token != null && token.startsWith("Bearer ")) {
                token = token.substring(7);
                
                if (JwtUtil.isUserToken(token)) {
                    userId = JwtUtil.getUserId(token);
                } else if (JwtUtil.isFamilyToken(token)) {
                    Long familyId = JwtUtil.getFamilyId(token);
                    FamilyMember family = familyAuthService.getById(familyId);
                    if (family != null) {
                        userId = family.getUserId();
                    }
                }
            }
            
            if (userId == null) {
                userId = 1L;
            }

            QueryWrapper<FamilyMember> wrapper = new QueryWrapper<>();
            wrapper.eq("user_id", userId);
            wrapper.eq("is_deleted", 0);
            wrapper.orderByDesc("create_time");

            List<FamilyMember> members = familyAuthService.list(wrapper);
            return Result.success(members);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取家属列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取单个家属详情
     * GET /family/{id}
     */
    @GetMapping("/{id}")
    public Result<?> getFamilyMemberById(@PathVariable Long id) {
        try {
            FamilyMember member = familyAuthService.getById(id);
            if (member == null) {
                return Result.error("家属不存在");
            }
            return Result.success(member);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取家属信息失败：" + e.getMessage());
        }
    }

    /**
     * 更新家属信息
     * PUT /family/{id}
     */
    @PutMapping("/{id}")
    public Result<?> updateFamilyMember(@PathVariable Long id, @RequestBody Map<String, Object> params) {
        try {
            FamilyMember member = familyAuthService.getById(id);
            if (member == null) {
                return Result.error("家属不存在");
            }

            if (params.get("name") != null) {
                member.setName(params.get("name").toString());
            }
            if (params.get("relation") != null) {
                member.setRelation(params.get("relation").toString());
            }
            if (params.get("phone") != null) {
                member.setPhone(params.get("phone").toString());
            }
            if (params.get("idCard") != null) {
                member.setIdCard(params.get("idCard").toString());
            }
            if (params.get("gender") != null) {
                member.setGender(Integer.valueOf(params.get("gender").toString()));
            }
            if (params.get("age") != null) {
                member.setAge(Integer.valueOf(params.get("age").toString()));
            }
            if (params.get("address") != null) {
                member.setAddress(params.get("address").toString());
            }
            if (params.get("healthCondition") != null) {
                member.setHealthCondition(params.get("healthCondition").toString());
            }
            
            member.setUpdateTime(new Date());

            boolean success = familyAuthService.updateById(member);
            if (success) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    /**
     * 删除家属
     * DELETE /family/{id}
     */
    @DeleteMapping("/{id}")
    public Result<?> deleteFamilyMember(@PathVariable Long id) {
        try {
            FamilyMember member = familyAuthService.getById(id);
            if (member == null) {
                return Result.error("家属不存在");
            }

            member.setIsDeleted(1);
            member.setUpdateTime(new Date());
            
            boolean success = familyAuthService.updateById(member);
            if (success) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除失败：" + e.getMessage());
        }
    }

    /**
     * 设置/取消紧急联系人
     * PUT /family/{id}/emergency
     */
    @PutMapping("/{id}/emergency")
    public Result<?> setEmergencyContact(@PathVariable Long id, @RequestBody Map<String, Object> params) {
        try {
            FamilyMember member = familyAuthService.getById(id);
            if (member == null) {
                return Result.error("家属不存在");
            }

            Object isEmergencyObj = params.get("isEmergencyContact");
            int isEmergency;
            if (isEmergencyObj instanceof Boolean) {
                isEmergency = ((Boolean) isEmergencyObj) ? 1 : 0;
            } else if (isEmergencyObj instanceof Integer) {
                isEmergency = (Integer) isEmergencyObj;
            } else {
                isEmergency = Boolean.valueOf(isEmergencyObj.toString()) ? 1 : 0;
            }

            member.setIsEmergencyContact(isEmergency);
            member.setUpdateTime(new Date());

            boolean success = familyAuthService.updateById(member);
            if (success) {
                return Result.success(isEmergency == 1 ? "已设为紧急联系人" : "已取消紧急联系人");
            } else {
                return Result.error("操作失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("操作失败：" + e.getMessage());
        }
    }
}
