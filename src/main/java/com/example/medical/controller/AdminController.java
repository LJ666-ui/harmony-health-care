package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.Admin;
import com.example.medical.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@CrossOrigin
@Validated
public class AdminController {

    @Autowired
    private AdminService adminService;

    /**
     * 管理员登录
     */
    @PostMapping("/login")
    public Result<?> login(@RequestBody Map<String, String> params, HttpServletRequest request) {
        String username = params.get("username");
        String password = params.get("password");

        if (username == null || username.trim().isEmpty()) {
            return Result.error("用户名不能为空");
        }

        if (password == null || password.trim().isEmpty()) {
            return Result.error("密码不能为空");
        }

        // 查询管理员
        Admin admin = adminService.findByUsername(username);
        if (admin == null) {
            return Result.error("用户名不存在");
        }

        // 检查账户状态
        if (admin.getStatus() == null || admin.getStatus() == 0) {
            return Result.error("账户已被禁用");
        }

        // 验证密码
        if (!BCryptUtil.matches(password, admin.getPassword())) {
            return Result.error("密码错误");
        }

        // 生成JWT Token
        String token = JwtUtil.generateToken(admin.getId(), admin.getUsername());

        // 更新最后登录信息
        admin.setLastLoginTime(new Date());
        admin.setLastLoginIp(getClientIp(request));
        adminService.updateById(admin);

        // 构建返回数据
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("adminId", admin.getId());
        data.put("username", admin.getUsername());
        data.put("realName", admin.getRealName());
        data.put("role", admin.getRole());
        data.put("avatar", admin.getAvatar());

        return Result.success(data);
    }

    /**
     * 获取管理员信息
     */
    @GetMapping("/info")
    public Result<?> getAdminInfo(@RequestHeader(value = "Authorization", required = false) String token) {
        if (token == null || token.isEmpty()) {
            return Result.error("未登录");
        }

        try {
            // 移除Bearer前缀
            if (token.startsWith("Bearer ")) {
                token = token.substring(7);
            }

            // 验证Token
            if (!JwtUtil.validateToken(token)) {
                return Result.error("Token无效或已过期");
            }

            // 从Token中获取用户ID
            Long adminId = JwtUtil.getUserId(token);
            Admin admin = adminService.getById(adminId);

            if (admin == null || admin.getIsDeleted() == 1) {
                return Result.error("管理员不存在");
            }

            // 构建返回数据
            Map<String, Object> data = new HashMap<>();
            data.put("id", admin.getId());
            data.put("username", admin.getUsername());
            data.put("realName", admin.getRealName());
            data.put("phone", admin.getPhone());
            data.put("email", admin.getEmail());
            data.put("avatar", admin.getAvatar());
            data.put("role", admin.getRole());
            data.put("status", admin.getStatus());
            data.put("lastLoginTime", admin.getLastLoginTime());
            data.put("lastLoginIp", admin.getLastLoginIp());
            data.put("createTime", admin.getCreateTime());

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("获取管理员信息失败：" + e.getMessage());
        }
    }

    /**
     * 管理员登出
     */
    @PostMapping("/logout")
    public Result<?> logout() {
        // JWT是无状态的，客户端删除Token即可
        return Result.success("登出成功");
    }

    /**
     * 获取客户端IP地址
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 多个代理时取第一个IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
