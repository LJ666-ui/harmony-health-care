package com.example.medical.controller;

import com.example.medical.common.BCryptUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.Admin;
import com.example.medical.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@CrossOrigin
public class AdminPasswordFixController {

    @Autowired
    private AdminService adminService;

    @GetMapping("/generate-password")
    public Result<?> generatePassword(@RequestParam(defaultValue = "admin123") String password) {
        String hash = BCryptUtil.encrypt(password);
        
        Map<String, Object> data = new HashMap<>();
        data.put("password", password);
        data.put("hash", hash);
        data.put("sql", "UPDATE admin SET password = '" + hash + "' WHERE username = 'admin';");
        
        return Result.success(data);
    }

    @GetMapping("/fix-admin-password")
    public Result<?> fixAdminPassword() {
        Admin admin = adminService.findByUsername("admin");
        if (admin == null) {
            return Result.error("admin用户不存在");
        }

        String newPasswordHash = BCryptUtil.encrypt("admin123");
        admin.setPassword(newPasswordHash);
        adminService.updateById(admin);

        Map<String, Object> data = new HashMap<>();
        data.put("message", "密码已更新为: admin123");
        data.put("newHash", newPasswordHash);
        data.put("adminId", admin.getId());
        data.put("username", admin.getUsername());

        return Result.success(data);
    }

    @GetMapping("/verify-password")
    public Result<?> verifyPassword(@RequestParam String username, @RequestParam String password) {
        Admin admin = adminService.findByUsername(username);
        if (admin == null) {
            return Result.error("用户不存在");
        }

        boolean matches = BCryptUtil.matches(password, admin.getPassword());
        
        Map<String, Object> data = new HashMap<>();
        data.put("username", username);
        data.put("inputPassword", password);
        data.put("storedHash", admin.getPassword());
        data.put("matches", matches);
        
        if (!matches) {
            String correctHash = BCryptUtil.encrypt(password);
            data.put("correctHash", correctHash);
            data.put("suggestion", "密码不匹配，请使用此hash更新数据库");
        }

        return Result.success(data);
    }
}
