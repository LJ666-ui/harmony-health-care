package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.Admin;
import com.example.medical.entity.FamilyMember;
import com.example.medical.entity.User;
import com.example.medical.entity.Doctor;
import com.example.medical.service.AdminService;
import com.example.medical.service.FamilyAuthService;
import com.example.medical.service.UserService;
import com.example.medical.service.DoctorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@CrossOrigin
@Validated
public class AdminController {

    @Autowired
    private AdminService adminService;

    @Autowired
    private UserService userService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private FamilyAuthService familyAuthService;

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

    /**
     * 获取管理仪表盘统计数据
     */
    @GetMapping("/dashboard/stats")
    public Result<?> getDashboardStats() {
        try {
            Map<String, Object> stats = new HashMap<>();

            // 用户总数
            LambdaQueryWrapper<User> userWrapper = new LambdaQueryWrapper<>();
            userWrapper.eq(User::getIsDeleted, 0);
            long userCount = userService.count(userWrapper);
            stats.put("userCount", userCount);

            // 医生总数
            LambdaQueryWrapper<Doctor> doctorWrapper = new LambdaQueryWrapper<>();
            doctorWrapper.eq(Doctor::getIsDeleted, 0);
            long doctorCount = doctorService.count(doctorWrapper);
            stats.put("doctorCount", doctorCount);

            // 管理员总数
            LambdaQueryWrapper<Admin> adminWrapper = new LambdaQueryWrapper<>();
            adminWrapper.eq(Admin::getIsDeleted, 0);
            long adminCount = adminService.count(adminWrapper);
            stats.put("adminCount", adminCount);

            // 家属总数
            long familyCount = familyAuthService.count(new LambdaQueryWrapper<FamilyMember>()
                    .eq(FamilyMember::getIsDeleted, 0));
            stats.put("familyCount", familyCount);

            // 最近注册的用户（前5个）
            LambdaQueryWrapper<User> recentWrapper = new LambdaQueryWrapper<>();
            recentWrapper.eq(User::getIsDeleted, 0);
            recentWrapper.orderByDesc(User::getCreateTime);
            recentWrapper.last("LIMIT 5");
            List<User> recentUsers = userService.list(recentWrapper);
            stats.put("recentUsers", recentUsers);

            return Result.success(stats);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取仪表盘统计数据失败：" + e.getMessage());
        }
    }

    @GetMapping("/user/list")
    public Result<?> getUserList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer userType,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getIsDeleted, 0);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim();
                wrapper.and(w -> w.like(User::getUsername, kw)
                    .or().like(User::getPhone, kw)
                    .or().like(User::getIdCard, kw));
            }

            if (userType != null && userType >= 0) {
                wrapper.eq(User::getUserType, userType);
            }

            wrapper.orderByDesc(User::getCreateTime);

            long total = userService.count(wrapper);

            int start = (page - 1) * size;
            wrapper.last("LIMIT " + size + " OFFSET " + start);

            List<User> users = userService.list(wrapper);

            Map<String, Object> result = new HashMap<>();
            result.put("records", users);
            result.put("total", total);
            result.put("page", page);
            result.put("size", size);
            result.put("pages", Math.max(1, (int) Math.ceil((double) total / size)));

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取用户列表失败：" + e.getMessage());
        }
    }

    // ==================== 家属管理 ====================

    @GetMapping("/family/list")
    public Result<?> getFamilyList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String relation,
            @RequestParam(required = false) Integer isEmergencyContact,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        try {
            LambdaQueryWrapper<FamilyMember> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(FamilyMember::getIsDeleted, 0);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim();
                wrapper.and(w -> w.like(FamilyMember::getName, kw)
                        .or().like(FamilyMember::getPhone, kw));
            }
            if (relation != null && !relation.trim().isEmpty()) {
                wrapper.eq(FamilyMember::getRelation, relation);
            }
            if (isEmergencyContact != null && isEmergencyContact >= 0) {
                wrapper.eq(FamilyMember::getIsEmergencyContact, isEmergencyContact);
            }
            wrapper.orderByDesc(FamilyMember::getCreateTime);

            Page<FamilyMember> pageResult = familyAuthService.page(new Page<>(page, size), wrapper);

            Map<String, Object> result = new HashMap<>();
            result.put("records", pageResult.getRecords());
            result.put("total", pageResult.getTotal());
            result.put("page", pageResult.getCurrent());
            result.put("size", pageResult.getSize());
            result.put("pages", pageResult.getPages());

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取家属列表失败：" + e.getMessage());
        }
    }

    @GetMapping("/family/detail/{id}")
    public Result<?> getFamilyDetail(@PathVariable Long id) {
        try {
            FamilyMember familyMember = familyAuthService.getById(id);
            if (familyMember == null || familyMember.getIsDeleted() == 1) {
                return Result.error("家属信息不存在");
            }
            return Result.success(familyMember);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取家属详情失败：" + e.getMessage());
        }
    }

    @PostMapping("/family/add")
    public Result<?> addFamily(@RequestBody Map<String, Object> params) {
        try {
            FamilyMember fm = new FamilyMember();
            fm.setUserId(toLong(params.get("userId")));
            fm.setName(getString(params.get("name")));
            fm.setRelation(getString(params.get("relation")));
            fm.setPhone(getString(params.get("phone")));
            fm.setIdCard(getString(params.get("idCard")));
            fm.setGender(toInteger(params.get("gender")));
            fm.setAge(toInteger(params.get("age")));
            fm.setAddress(getString(params.get("address")));
            fm.setIsEmergencyContact(toInteger(params.get("isEmergencyContact")));
            fm.setHealthCondition(getString(params.get("healthCondition")));
            fm.setCreateTime(new Date());
            fm.setUpdateTime(new Date());
            fm.setIsDeleted(0);

            familyAuthService.save(fm);
            return Result.success("添加家属成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加家属失败：" + e.getMessage());
        }
    }

    @PostMapping("/family/update")
    public Result<?> updateFamily(@RequestBody Map<String, Object> params) {
        try {
            Long id = toLong(params.get("id"));
            FamilyMember fm = familyAuthService.getById(id);
            if (fm == null || fm.getIsDeleted() == 1) {
                return Result.error("家属信息不存在");
            }

            if (params.containsKey("name")) fm.setName(getString(params.get("name")));
            if (params.containsKey("userId")) fm.setUserId(toLong(params.get("userId")));
            if (params.containsKey("relation")) fm.setRelation(getString(params.get("relation")));
            if (params.containsKey("phone")) fm.setPhone(getString(params.get("phone")));
            if (params.containsKey("idCard")) fm.setIdCard(getString(params.get("idCard")));
            if (params.containsKey("gender")) fm.setGender(toInteger(params.get("gender")));
            if (params.containsKey("age")) fm.setAge(toInteger(params.get("age")));
            if (params.containsKey("address")) fm.setAddress(getString(params.get("address")));
            if (params.containsKey("isEmergencyContact")) fm.setIsEmergencyContact(toInteger(params.get("isEmergencyContact")));
            if (params.containsKey("healthCondition")) fm.setHealthCondition(getString(params.get("healthCondition")));
            fm.setUpdateTime(new Date());

            familyAuthService.updateById(fm);
            return Result.success("更新家属成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新家属失败：" + e.getMessage());
        }
    }

    @PostMapping("/family/delete/{id}")
    public Result<?> deleteFamily(@PathVariable Long id) {
        try {
            FamilyMember fm = familyAuthService.getById(id);
            if (fm == null) {
                return Result.error("家属信息不存在");
            }
            fm.setIsDeleted(1);
            fm.setUpdateTime(new Date());
            familyAuthService.updateById(fm);
            return Result.success("删除家属成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除家属失败：" + e.getMessage());
        }
    }

    // ==================== 管理员管理 ====================

    @GetMapping("/admin/list")
    public Result<?> getAdminList(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer role,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            LambdaQueryWrapper<Admin> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Admin::getIsDeleted, 0);

            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim();
                wrapper.and(w -> w.like(Admin::getUsername, kw)
                        .or().like(Admin::getRealName, kw)
                        .or().like(Admin::getPhone, kw));
            }
            if (role != null && role >= 0) {
                wrapper.eq(Admin::getRole, role);
            }
            wrapper.orderByDesc(Admin::getCreateTime);

            Page<Admin> pageResult = adminService.page(new Page<>(page, size), wrapper);

            List<Map<String, Object>> records = new java.util.ArrayList<>();
            for (Admin admin : pageResult.getRecords()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id", admin.getId());
                item.put("username", admin.getUsername());
                item.put("realName", admin.getRealName());
                item.put("phone", admin.getPhone());
                item.put("email", admin.getEmail());
                item.put("avatar", admin.getAvatar());
                item.put("role", admin.getRole());
                item.put("status", admin.getStatus());
                item.put("lastLoginTime", admin.getLastLoginTime());
                item.put("lastLoginIp", admin.getLastLoginIp());
                item.put("createTime", admin.getCreateTime());
                records.add(item);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("records", records);
            result.put("total", pageResult.getTotal());
            result.put("page", pageResult.getCurrent());
            result.put("size", pageResult.getSize());
            result.put("pages", pageResult.getPages());

            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取管理员列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/admin/add")
    public Result<?> addAdmin(@RequestBody Map<String, Object> params) {
        try {
            String username = getString(params.get("username"));
            String realName = getString(params.get("realName"));
            String password = getString(params.get("password"));

            if (username.isEmpty() || realName.isEmpty()) {
                return Result.error("用户名和真实姓名不能为空");
            }
            if (password.isEmpty() || password.length() < 6) {
                return Result.error("密码长度不能少于6位");
            }

            Admin existing = adminService.findByUsername(username);
            if (existing != null) {
                return Result.error("用户名已存在");
            }

            Admin admin = new Admin();
            admin.setUsername(username);
            admin.setRealName(realName);
            admin.setPassword(BCryptUtil.encrypt(password));
            admin.setPhone(getString(params.get("phone")));
            admin.setEmail(getString(params.get("email")));
            admin.setRole(toInteger(params.get("role")));
            if (admin.getRole() == null || admin.getRole() < 1) admin.setRole(2);
            admin.setStatus(1);
            admin.setCreateTime(new Date());
            admin.setUpdateTime(new Date());
            admin.setIsDeleted(0);

            adminService.save(admin);
            return Result.success("添加管理员成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("添加管理员失败：" + e.getMessage());
        }
    }

    @PostMapping("/admin/update")
    public Result<?> updateAdmin(@RequestBody Map<String, Object> params) {
        try {
            Long id = toLong(params.get("id"));
            Admin admin = adminService.getById(id);
            if (admin == null || admin.getIsDeleted() == 1) {
                return Result.error("管理员不存在");
            }

            if (params.containsKey("realName")) admin.setRealName(getString(params.get("realName")));
            if (params.containsKey("phone")) admin.setPhone(getString(params.get("phone")));
            if (params.containsKey("email")) admin.setEmail(getString(params.get("email")));
            if (params.containsKey("role")) admin.setRole(toInteger(params.get("role")));
            if (params.containsKey("status")) admin.setStatus(toInteger(params.get("status")));
            admin.setUpdateTime(new Date());

            adminService.updateById(admin);
            return Result.success("更新管理员成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新管理员失败：" + e.getMessage());
        }
    }

    @PostMapping("/admin/delete/{id}")
    public Result<?> deleteAdmin(@PathVariable Long id) {
        try {
            Admin admin = adminService.getById(id);
            if (admin == null) {
                return Result.error("管理员不存在");
            }
            if (admin.getRole() == 1) {
                long superAdminCount = adminService.count(new LambdaQueryWrapper<Admin>()
                        .eq(Admin::getRole, 1).eq(Admin::getIsDeleted, 0));
                if (superAdminCount <= 1) {
                    return Result.error("不能删除最后一个超级管理员");
                }
            }
            admin.setIsDeleted(1);
            admin.setUpdateTime(new Date());
            adminService.updateById(admin);
            return Result.success("删除管理员成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除管理员失败：" + e.getMessage());
        }
    }

    @PostMapping("/admin/reset-password")
    public Result<?> resetAdminPassword(@RequestBody Map<String, Object> params) {
        try {
            Long id = toLong(params.get("id"));
            String newPassword = getString(params.get("newPassword"));

            if (newPassword.isEmpty() || newPassword.length() < 6) {
                return Result.error("新密码长度不能少于6位");
            }

            Admin admin = adminService.getById(id);
            if (admin == null || admin.getIsDeleted() == 1) {
                return Result.error("管理员不存在");
            }

            admin.setPassword(BCryptUtil.encrypt(newPassword));
            admin.setUpdateTime(new Date());
            adminService.updateById(admin);
            return Result.success("重置密码成功");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("重置密码失败：" + e.getMessage());
        }
    }

    @PostMapping("/admin/toggle-status")
    public Result<?> toggleAdminStatus(@RequestBody Map<String, Object> params) {
        try {
            Long id = toLong(params.get("id"));
            Admin admin = adminService.getById(id);
            if (admin == null || admin.getIsDeleted() == 1) {
                return Result.error("管理员不存在");
            }
            if (admin.getRole() == 1) {
                return Result.error("不能禁用超级管理员");
            }
            admin.setStatus(admin.getStatus() == 1 ? 0 : 1);
            admin.setUpdateTime(new Date());
            adminService.updateById(admin);
            return Result.success(admin.getStatus() == 1 ? "已启用" : "已禁用");
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("操作失败：" + e.getMessage());
        }
    }

    // ==================== 数据大屏统计 ====================

    @GetMapping("/dashboard/detail")
    public Result<?> getDashboardDetail() {
        try {
            Map<String, Object> data = new HashMap<>();

            long userCount = userService.count(new LambdaQueryWrapper<User>().eq(User::getIsDeleted, 0));
            long doctorCount = doctorService.count(new LambdaQueryWrapper<Doctor>().eq(Doctor::getIsDeleted, 0));
            long adminCount = adminService.count(new LambdaQueryWrapper<Admin>().eq(Admin::getIsDeleted, 0));
            long familyCount = familyAuthService.count(new LambdaQueryWrapper<FamilyMember>().eq(FamilyMember::getIsDeleted, 0));
            long patientCount = userService.count(new LambdaQueryWrapper<User>().eq(User::getIsDeleted, 0).eq(User::getUserType, 0));

            data.put("userCount", userCount);
            data.put("doctorCount", doctorCount);
            data.put("adminCount", adminCount);
            data.put("familyCount", familyCount);
            data.put("patientCount", patientCount);
            data.put("todayActiveUsers", Math.max(1, (long) Math.floor(userCount * 0.35)));

            return Result.success(data);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取数据大屏统计失败：" + e.getMessage());
        }
    }

    // ==================== 工具方法 ====================

    private Long toLong(Object obj) {
        if (obj == null) return 0L;
        if (obj instanceof Number) return ((Number) obj).longValue();
        try { return Long.parseLong(obj.toString()); } catch (Exception e) { return 0L; }
    }

    private Integer toInteger(Object obj) {
        if (obj == null) return null;
        if (obj instanceof Number) return ((Number) obj).intValue();
        try { return Integer.parseInt(obj.toString()); } catch (Exception e) { return null; }
    }

    private String getString(Object obj) {
        return obj == null ? "" : obj.toString();
    }
}
