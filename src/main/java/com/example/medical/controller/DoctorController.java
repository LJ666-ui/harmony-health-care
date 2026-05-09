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

            return Result.success(doctor);
        } catch (Exception e) {
            return Result.error("获取医生信息失败: " + e.getMessage());
        }
    }

    /**
     * 获取医生的患者列表
     */
    @GetMapping("/patients")
    public Result getPatients(@RequestHeader("Token") String token) {
        try {
            if (!JwtUtil.isDoctorToken(token)) {
                return Result.error("非医生Token");
            }

            Long doctorId = JwtUtil.getDoctorId(token);
            if (doctorId == null) {
                return Result.error("无效的Token");
            }

            // 获取医生的患者列表
            List<Map<String, Object>> patients = doctorService.getPatientsByDoctorId(doctorId);
            return Result.success(patients);
        } catch (Exception e) {
            return Result.error("获取患者列表失败: " + e.getMessage());
        }
    }
}
