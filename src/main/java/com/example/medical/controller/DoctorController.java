package com.example.medical.controller;

import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.User;
import com.example.medical.service.DoctorService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/doctor")
public class DoctorController {

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private UserService userService;

    /**
     * 医生登录
     */
    @PostMapping("/login")
    public Result login(@RequestBody Map<String, String> params) {
        String phone = params.get("phone");
        String password = params.get("password");

        if (phone == null || phone.isEmpty()) {
            return Result.error("手机号不能为空");
        }
        if (password == null || password.isEmpty()) {
            return Result.error("密码不能为空");
        }

        // 先通过手机号查找用户
        User user = userService.findByPhone(phone);
        if (user == null) {
            return Result.error("用户不存在");
        }

        // 验证密码（支持BCrypt加密和明文密码）
        boolean passwordMatches = false;
        
        // 先尝试BCrypt验证
        if (user.getPassword().startsWith("$2a$") || user.getPassword().startsWith("$2b$")) {
            passwordMatches = BCryptUtil.matches(password, user.getPassword());
        } else {
            // 如果不是BCrypt格式，则直接比较明文密码
            passwordMatches = user.getPassword().equals(password);
        }
        
        if (!passwordMatches) {
            return Result.error("密码错误");
        }

        // 查找医生信息
        Doctor doctor = doctorService.getByUserId(user.getId());
        if (doctor == null) {
            return Result.error("医生信息不存在");
        }

        if (doctor.getStatus() == null || doctor.getStatus() != 1) {
            return Result.error("账号已被禁用");
        }

        // 生成医生Token
        String token = JwtUtil.generateDoctorToken(doctor.getId(), phone);

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("doctorInfo", doctor);

        return Result.success(data);
    }

    /**
     * 验证医生Token
     */
    @GetMapping("/verify")
    public Result verify(@RequestHeader("Token") String token) {
        try {
            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            if (JwtUtil.isTokenExpired(token)) {
                return Result.error("Token已过期");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            Doctor doctor = doctorService.findById(doctorId);
            if (doctor == null) {
                return Result.error("医生不存在");
            }

            Map<String, Object> data = new HashMap<>();
            data.put("valid", true);
            data.put("doctorInfo", doctor);

            return Result.success(data);
        } catch (Exception e) {
            return Result.error("Token验证失败: " + e.getMessage());
        }
    }

    /**
     * 获取医生信息
     */
    @GetMapping("/info")
    public Result getDoctorInfo(@RequestHeader("Token") String token) {
        try {
            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            Doctor doctor = doctorService.findById(doctorId);
            if (doctor == null) {
                return Result.error("医生不存在");
            }

            // 关联查询用户表获取 realName 和 phone
            User user = userService.getById(doctor.getUserId());
            
            // 组装完整信息返回给前端
            Map<String, Object> result = new HashMap<>();
            result.put("id", doctor.getId());
            result.put("userId", doctor.getUserId());
            result.put("realName", user != null ? user.getRealName() : "");
            result.put("phone", user != null ? user.getPhone() : "");
            result.put("hospital", doctor.getHospital());
            result.put("department", doctor.getDepartment());
            result.put("licenseNumber", doctor.getLicenseNumber());
            result.put("title", doctor.getTitle());
            result.put("specialty", doctor.getSpecialty());
            result.put("description", doctor.getDescription());
            result.put("rating", doctor.getRating());
            result.put("status", doctor.getStatus());
            result.put("createTime", doctor.getCreateTime());
            result.put("updateTime", doctor.getUpdateTime());

            return Result.success(result);
        } catch (Exception e) {
            return Result.error("获取医生信息失败: " + e.getMessage());
        }
    }

    /**
     * 获取医生的患者列表
     */
    @GetMapping("/patients")
    public Result getPatients(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestHeader(value = "Token", required = false) String tokenHeader) {
        try {
            // 支持两种Token格式：标准Bearer Token和自定义Token头
            String token = null;
            if (authorization != null && authorization.startsWith("Bearer ")) {
                token = authorization.substring(7);
            } else if (tokenHeader != null) {
                token = tokenHeader;
            }

            if (token == null || token.isEmpty()) {
                return Result.error("未提供认证信息");
            }

            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            List<Map<String, Object>> patients = doctorService.getPatientsByDoctorId(doctorId);
            return Result.success(patients);
        } catch (Exception e) {
            return Result.error("获取患者列表失败: " + e.getMessage());
        }
    }

    /**
     * 更新医生个人信息
     */
    @PutMapping("/update")
    public Result updateDoctorInfo(@RequestHeader("Token") String token, @RequestBody Map<String, Object> params) {
        try {
            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            Doctor existingDoctor = doctorService.findById(doctorId);
            if (existingDoctor == null) {
                return Result.error("医生不存在");
            }

            // 获取关联的用户信息
            User user = userService.getById(existingDoctor.getUserId());
            if (user == null) {
                return Result.error("关联用户不存在");
            }

            // 1. 更新 user 表（realName 和 phone）
            if (params.containsKey("realName")) {
                user.setRealName((String) params.get("realName"));
            }
            if (params.containsKey("phone")) {
                user.setPhone((String) params.get("phone"));
            }
            userService.updateById(user);

            // 2. 更新 doctor 表（其他字段）
            if (params.containsKey("department")) {
                existingDoctor.setDepartment((String) params.get("department"));
            }
            if (params.containsKey("title")) {
                existingDoctor.setTitle((String) params.get("title"));
            }
            if (params.containsKey("specialty")) {
                existingDoctor.setSpecialty((String) params.get("specialty"));
            }
            if (params.containsKey("description")) {
                existingDoctor.setDescription((String) params.get("description"));
            }
            existingDoctor.setUpdateTime(new java.util.Date());

            if (doctorService.updateById(existingDoctor)) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新医生信息失败: " + e.getMessage());
        }
    }

    /**
     * 修改医生密码
     */
    @PostMapping("/password")
    public Result changePassword(@RequestHeader("Token") String token, @RequestBody Map<String, String> params) {
        try {
            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            String oldPassword = params.get("oldPassword");
            String newPassword = params.get("newPassword");

            if (oldPassword == null || oldPassword.isEmpty()) {
                return Result.error("原密码不能为空");
            }
            if (newPassword == null || newPassword.isEmpty()) {
                return Result.error("新密码不能为空");
            }
            if (newPassword.length() < 6) {
                return Result.error("新密码长度不能少于6位");
            }

            Doctor doctor = doctorService.findById(doctorId);
            if (doctor == null) {
                return Result.error("医生不存在");
            }

            User user = userService.getById(doctor.getUserId());
            if (user == null) {
                return Result.error("用户不存在");
            }

            boolean passwordMatches = false;
            if (user.getPassword().startsWith("$2a$") || user.getPassword().startsWith("$2b$")) {
                passwordMatches = BCryptUtil.matches(oldPassword, user.getPassword());
            } else {
                passwordMatches = user.getPassword().equals(oldPassword);
            }

            if (!passwordMatches) {
                return Result.error("原密码错误");
            }

            user.setPassword(BCryptUtil.encrypt(newPassword));
            if (userService.updateById(user)) {
                return Result.success("密码修改成功");
            } else {
                return Result.error("密码修改失败");
            }
        } catch (Exception e) {
            return Result.error("修改密码失败: " + e.getMessage());
        }
    }
}
