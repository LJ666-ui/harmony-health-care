package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.Doctor;
import com.example.medical.entity.DoctorMessage;
import com.example.medical.entity.Nurse;
import com.example.medical.entity.NursePatientRelation;
import com.example.medical.entity.User;
import com.example.medical.service.DoctorMessageService;
import com.example.medical.service.DoctorService;
import com.example.medical.service.NursePatientRelationService;
import com.example.medical.service.NurseService;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/user")
@CrossOrigin
@Validated
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private DoctorService doctorService;

    @Autowired
    private DoctorMessageService doctorMessageService;

    @Autowired
    private NurseService nurseService;

    @Autowired
    private NursePatientRelationService nursePatientRelationService;

    /**
     * 发送验证码（模拟）
     * 实际项目中应该调用短信服务API
     */
    @PostMapping("/send-code")
    public Result<?> sendVerificationCode(@RequestBody Map<String, String> params) {
        String phone = params.get("phone");
        if (phone == null || phone.trim().isEmpty()) {
            return Result.error("手机号不能为空");
        }
        // 验证手机号格式
        if (!phone.matches("^1[3-9]\\d{9}$")) {
            return Result.error("手机号格式不正确");
        }
        
        // TODO: 实际项目中这里应该：
        // 1. 调用短信服务API发送验证码
        // 2. 将验证码存入Redis并设置过期时间
        // 3. 返回发送结果
        
        // 模拟发送成功
        System.out.println("[验证码] 发送验证码到手机: " + phone + ", 验证码: 123456");
        Map<String, Object> result = new HashMap<>();
        result.put("message", "验证码发送成功");
        result.put("code", "123456"); // 测试环境返回验证码，生产环境应删除
        return Result.success(result);
    }

    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody User user) {
        if (userService.findByUsername(user.getUsername()) != null) {
            return Result.error("用户名已存在");
        }
        if (user.getUserType() == null) {
            user.setUserType(0);
        }
        user.setPassword(BCryptUtil.encrypt(user.getPassword()));
        user.setCreateTime(new Date());
        user.setIsDeleted(0);
        if (userService.save(user)) {
            Map<String, Object> result = new HashMap<>();
            result.put("userId", user.getId());
            result.put("message", "注册成功");
            result.put("userType", user.getUserType());
            return Result.success(result);
        } else {
            return Result.error("注册失败");
        }
    }

    @PostMapping("/login")
    public Result<?> login(@Valid @RequestBody User user) {
        User dbUser = userService.findByUsername(user.getUsername());
        if (dbUser == null) {
            return Result.error("用户名不存在");
        }
        if (!BCryptUtil.matches(user.getPassword(), dbUser.getPassword())) {
            return Result.error("密码错误");
        }
        String token = JwtUtil.generateToken(dbUser.getId(), dbUser.getUsername());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("userId", dbUser.getId());
        result.put("username", dbUser.getUsername());
        result.put("userType", dbUser.getUserType());
        return Result.success(result);
    }

    @GetMapping("/info")
    public Result<?> getUserInfo(@RequestParam Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setPassword(null);
        return Result.success(user);
    }

    @PostMapping("/update")
    public Result<?> updateUser(@Valid @RequestBody User user) {
        if (userService.updateById(user)) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }

    @GetMapping("/doctor/list")
    public Result<List<Doctor>> getDoctorList(@RequestParam(required = false) String keyword) {
        try {
            LambdaQueryWrapper<Doctor> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Doctor::getIsDeleted, 0);
            if (keyword != null && !keyword.isEmpty()) {
                final String kw = keyword.trim().toLowerCase();
                wrapper.and(w -> w.like(Doctor::getRealName, kw)
                    .or()
                    .like(Doctor::getHospital, kw)
                    .or()
                    .like(Doctor::getDepartment, kw));
            }
            wrapper.orderByDesc(Doctor::getCreateTime);
            List<Doctor> doctors = doctorService.list(wrapper);
            return Result.success(doctors);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医生列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/doctor/register")
    public Result<?> doctorRegister(@RequestBody Doctor doctor) {
        try {
            if (doctor.getUserId() == null) {
                return Result.error("用户ID不能为空");
            }
            if (doctor.getRealName() == null || doctor.getRealName().trim().isEmpty()) {
                return Result.error("请填写真实姓名");
            }
            if (doctor.getHospital() == null || doctor.getHospital().trim().isEmpty()) {
                return Result.error("请填写所属医院");
            }
            if (doctor.getDepartment() == null || doctor.getDepartment().trim().isEmpty()) {
                return Result.error("请填写科室");
            }
            if (doctor.getLicenseNumber() == null || doctor.getLicenseNumber().trim().isEmpty()) {
                return Result.error("请填写执业证号");
            }
            Doctor existing = doctorService.getByUserId(doctor.getUserId());
            if (existing != null) {
                return Result.error("该用户已注册医生信息");
            }
            doctor.setStatus(0);
            doctor.setIsDeleted(0);
            doctor.setCreateTime(new Date());
            if (doctorService.save(doctor)) {
                Map<String, Object> result = new HashMap<>();
                result.put("doctorId", doctor.getId());
                result.put("message", "医生信息提交成功，等待审核");
                return Result.success(result);
            } else {
                return Result.error("医生信息保存失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("医生注册失败：" + e.getMessage());
        }
    }

    @GetMapping("/doctor/info/{userId}")
    public Result<?> getDoctorInfo(@PathVariable Long userId) {
        try {
            Doctor doctor = doctorService.getByUserId(userId);
            if (doctor == null) {
                return Result.error("医生信息不存在");
            }
            return Result.success(doctor);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医生信息失败：" + e.getMessage());
        }
    }

    @PutMapping("/doctor/update")
    public Result<?> updateDoctor(@RequestBody Doctor doctor) {
        try {
            if (doctor.getId() == null) {
                return Result.error("医生ID不能为空");
            }
            doctor.setUpdateTime(new Date());
            if (doctorService.updateById(doctor)) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败：" + e.getMessage());
        }
    }

    @PostMapping("/message/send")
    public Result<?> sendMessage(@RequestBody Map<String, Object> body) {
        try {
            long senderId = Long.parseLong(body.get("senderId").toString());
            long receiverId = Long.parseLong(body.get("receiverId").toString());
            String content = body.get("content") != null ? body.get("content").toString() : "";

            User sender = userService.getById(senderId);
            if (sender == null) {
                return Result.error("发送者不存在");
            }

            if (sender.getUserType() != null && sender.getUserType() == 1) {
                if (!doctorMessageService.canDoctorSendMessage(senderId, receiverId)) {
                    return Result.error("该患者尚未联系您，您无法主动发起对话");
                }
            }

            DoctorMessage message = doctorMessageService.sendMessageWithExpiry(senderId, receiverId, content);
            return Result.success(message);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("发送消息失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/history")
    public Result<?> getMessageHistory(@RequestParam Long userA, @RequestParam Long userB) {
        try {
            System.out.println("[getMessageHistory] userA=" + userA + " userB=" + userB);
            List<DoctorMessage> messages = doctorMessageService.getConversation(userA, userB);
            System.out.println("[getMessageHistory] 查询结果条数=" + (messages != null ? messages.size() : "null"));
            if (messages != null && !messages.isEmpty()) {
                for (DoctorMessage m : messages) {
                    System.out.println("  msg id=" + m.getId() + " sender=" + m.getSenderId()
                        + " receiver=" + m.getReceiverId() + " content=" + m.getContent()
                        + " expireTime=" + m.getExpireTime());
                }
            }
            LambdaQueryWrapper<DoctorMessage> readWrapper = new LambdaQueryWrapper<>();
            readWrapper.eq(DoctorMessage::getSenderId, userB);
            readWrapper.eq(DoctorMessage::getReceiverId, userA);
            readWrapper.eq(DoctorMessage::getIsRead, 0);
            DoctorMessage updateMsg = new DoctorMessage();
            updateMsg.setIsRead(1);
            doctorMessageService.update(updateMsg, readWrapper);
            return Result.success(messages);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取消息记录失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/conversations")
    public Result<?> getConversations(@RequestParam Long userId) {
        try {
            List<Map<String, Object>> conversations = doctorMessageService.getConversationList(userId);
            return Result.success(conversations);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取会话列表失败：" + e.getMessage());
        }
    }

    @DeleteMapping("/message/delete")
    public Result<?> deleteConversation(@RequestBody Map<String, Object> body) {
        try {
            long userA = Long.parseLong(body.get("userA").toString());
            long userB = Long.parseLong(body.get("userB").toString());
            LambdaQueryWrapper<DoctorMessage> wrapper = new LambdaQueryWrapper<>();
            wrapper.and(w -> w.eq(DoctorMessage::getSenderId, userA).eq(DoctorMessage::getReceiverId, userB))
                .or(w -> w.eq(DoctorMessage::getSenderId, userB).eq(DoctorMessage::getReceiverId, userA));
            if (doctorMessageService.remove(wrapper)) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("删除对话失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/can-send")
    public Result<?> canSend(@RequestParam Long senderId, @RequestParam Long receiverId) {
        try {
            User sender = userService.getById(senderId);
            if (sender == null) {
                return Result.error("用户不存在");
            }
            boolean canSend = true;
            if (sender.getUserType() != null && sender.getUserType() == 1) {
                canSend = doctorMessageService.canDoctorSendMessage(senderId, receiverId);
            }
            Map<String, Object> result = new HashMap<>();
            result.put("canSend", canSend);
            result.put("userType", sender.getUserType());
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("检查权限失败：" + e.getMessage());
        }
    }

    @GetMapping("/doctor/patients")
    public Result<?> getDoctorPatients(@RequestParam Long doctorId) {
        try {
            User doctor = userService.getById(doctorId);
            if (doctor == null || doctor.getUserType() != 1) {
                return Result.error("非医生身份，无权访问");
            }
            List<Map<String, Object>> conversations = doctorMessageService.getConversationList(doctorId);
            return Result.success(conversations);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取患者列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/message/cleanup")
    public Result<?> cleanupExpired() {
        try {
            int deleted = doctorMessageService.cleanupExpiredMessages();
            Map<String, Object> result = new HashMap<>();
            result.put("deletedCount", deleted);
            return Result.success(result);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("清理过期消息失败：" + e.getMessage());
        }
    }

    /**
     * 获取所有患者列表（user_type=0）
     * GET /user/patients
     * 用于护士端显示患者列表
     */
    @GetMapping("/patients")
    public Result<?> getAllPatients() {
        try {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getUserType, 0)
                   .eq(User::getIsDeleted, 0)
                   .orderByDesc(User::getCreateTime);

            List<User> patients = userService.list(wrapper);

            if (patients != null && !patients.isEmpty()) {
                patients.forEach(user -> user.setPassword(null));
                return Result.success(patients);
            } else {
                return Result.success(new java.util.ArrayList<>());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取患者列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取当前登录护士负责的患者列表
     * GET /user/nurse/patients
     */
    @GetMapping("/nurse/patients")
    public Result<?> getNursePatients(@RequestHeader(value = "Token", required = false) String token) {
        try {
            System.out.println("[NursePatients] Token received: " + (token != null ? token.substring(0, Math.min(20, token.length())) + "..." : "null"));

            if (token == null || token.isEmpty()) {
                System.out.println("[NursePatients] Error: No token provided");
                return Result.error("未提供Token");
            }

            Long nurseId = null;
            
            if (JwtUtil.isNurseToken(token)) {
                nurseId = JwtUtil.getNurseId(token);
                System.out.println("[NursePatients] Detected NURSE token, nurseId: " + nurseId);
            } else {
                Long userId = JwtUtil.getUserId(token);
                System.out.println("[NursePatients] Detected USER token, userId: " + userId);
                if (userId == null) {
                    System.out.println("[NursePatients] Error: Invalid token or cannot extract userId");
                    return Result.error("无效的Token或无法提取用户ID");
                }
                
                Nurse nurse = nurseService.findByUserId(userId);
                if (nurse == null) {
                    System.out.println("[NursePatients] Error: Nurse not found for userId: " + userId);
                    return Result.error("未找到护士信息");
                }
                nurseId = nurse.getId();
            }

            if (nurseId == null) {
                System.out.println("[NursePatients] Error: Cannot determine nurseId from token");
                return Result.error("无法从Token中获取护士ID");
            }

            System.out.println("[NursePatients] Final nurseId: " + nurseId);

            Nurse nurse = nurseService.getById(nurseId);
            if (nurse == null) {
                System.out.println("[NursePatients] Error: Nurse not found for nurseId: " + nurseId);
                return Result.error("未找到护士信息");
            }

            System.out.println("[NursePatients] Nurse found: " + nurse.getName() + " (ID: " + nurse.getId() + ")");

            List<Long> patientIds = nursePatientRelationService.getPatientIdsByNurseId(nurse.getId());
            System.out.println("[NursePatients] Patient IDs from relation: " + patientIds);

            if (patientIds == null || patientIds.isEmpty()) {
                System.out.println("[NursePatients] No patients assigned to this nurse");
                return Result.success(new java.util.ArrayList<>());
            }

            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.in(User::getId, patientIds)
                   .eq(User::getUserType, 0)
                   .eq(User::getIsDeleted, 0)
                   .orderByDesc(User::getCreateTime);

            List<User> patients = userService.list(wrapper);
            System.out.println("[NursePatients] Total patients found: " + (patients != null ? patients.size() : 0));

            if (patients != null && !patients.isEmpty()) {
                patients.forEach(user -> user.setPassword(null));
                return Result.success(patients);
            } else {
                System.out.println("[NursePatients] Returning empty list");
                return Result.success(new java.util.ArrayList<>());
            }
        } catch (Exception e) {
            System.err.println("[NursePatients] Exception occurred:");
            e.printStackTrace();
            return Result.error("获取护士患者列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取患者详情信息
     * GET /user/patient/{patientId}
     */
    @GetMapping("/patient/{patientId}")
    public Result<?> getPatientDetail(@PathVariable Long patientId) {
        try {
            User user = userService.getById(patientId);
            if (user == null) {
                return Result.error("患者不存在");
            }
            if (user.getUserType() != null && user.getUserType() != 0) {
                return Result.error("该用户不是患者");
            }
            if (user.getIsDeleted() != null && user.getIsDeleted() == 1) {
                return Result.error("该患者已被删除");
            }
            user.setPassword(null);
            return Result.success(user);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取患者详情失败：" + e.getMessage());
        }
    }

    /**
     * 调试接口：测试护士患者数据链路
     * GET /user/nurse/patients/debug?nurseId=1
     */
    @GetMapping("/nurse/patients/debug")
    public Result<?> debugNursePatients(@RequestParam(required = false) Long nurseId) {
        try {
            System.out.println("[DebugNursePatients] Starting debug...");
            
            Map<String, Object> debugInfo = new HashMap<>();
            
            if (nurseId == null) {
                nurseId = 1L;
            }
            debugInfo.put("inputNurseId", nurseId);

            Nurse nurse = nurseService.getById(nurseId);
            if (nurse == null) {
                debugInfo.put("error", "Nurse not found for id: " + nurseId);
                return Result.success(debugInfo);
            }
            debugInfo.put("nurseFound", true);
            debugInfo.put("nurseName", nurse.getName());
            debugInfo.put("nurseId", nurse.getId());

            List<Long> patientIds = nursePatientRelationService.getPatientIdsByNurseId(nurse.getId());
            System.out.println("[DebugNursePatients] Patient IDs: " + patientIds);
            debugInfo.put("patientIdsFromRelation", patientIds);
            debugInfo.put("patientCount", patientIds != null ? patientIds.size() : 0);

            if (patientIds == null || patientIds.isEmpty()) {
                debugInfo.put("warning", "No patients in relation table");
                LambdaQueryWrapper<NursePatientRelation> allRelations = new LambdaQueryWrapper<>();
                allRelations.eq(NursePatientRelation::getNurseId, nurseId)
                           .eq(NursePatientRelation::getIsDeleted, 0);
                List<NursePatientRelation> allRel = nursePatientRelationService.list(allRelations);
                debugInfo.put("allRelationsForThisNurse", allRel);
                return Result.success(debugInfo);
            }

            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.in(User::getId, patientIds)
                   .eq(User::getUserType, 0)
                   .eq(User::getIsDeleted, 0);

            List<User> patients = userService.list(wrapper);
            System.out.println("[DebugNursePatients] Patients found: " + (patients != null ? patients.size() : 0));
            debugInfo.put("patientsFound", patients != null ? patients.size() : 0);

            if (patients != null && !patients.isEmpty()) {
                patients.forEach(user -> user.setPassword(null));
                debugInfo.put("patients", patients);
            } else {
                debugInfo.put("warning", "No users found with those IDs. Checking user table directly...");
                
                LambdaQueryWrapper<User> checkUsers = new LambdaQueryWrapper<>();
                checkUsers.in(User::getId, patientIds);
                List<User> allUsersWithIds = userService.list(checkUsers);
                debugInfo.put("allUsersWithTheseIds", allUsersWithIds);
                
                if (allUsersWithIds != null) {
                    allUsersWithIds.forEach(u -> {
                        Map<String, Object> userInfo = new HashMap<>();
                        userInfo.put("id", u.getId());
                        userInfo.put("username", u.getUsername());
                        userInfo.put("phone", u.getPhone());
                        userInfo.put("age", u.getAge());
                        userInfo.put("userType", u.getUserType());
                        userInfo.put("isDeleted", u.getIsDeleted());
                        System.out.println("[DebugNursePatients] User check - ID:" + u.getId()
                            + " Username:" + u.getUsername()
                            + " Type:" + u.getUserType()
                            + " Deleted:" + u.getIsDeleted());
                    });
                }
            }

            return Result.success(debugInfo);
        } catch (Exception e) {
            System.err.println("[DebugNurePatients] Exception:");
            e.printStackTrace();
            Map<String, Object> errorInfo = new HashMap<>();
            errorInfo.put("error", e.getMessage());
            errorInfo.put("stackTrace", e.toString());
            return Result.success(errorInfo);
        }
    }

    /**
     * 临时方案：获取所有患者列表（用于测试）
     * GET /user/all-patients
     */
    @GetMapping("/all-patients")
    public Result<?> getAllPatientsForTest() {
        try {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getUserType, 0)
                   .eq(User::getIsDeleted, 0)
                   .orderByDesc(User::getId);

            List<User> patients = userService.list(wrapper);
            System.out.println("[AllPatients] Total patients: " + (patients != null ? patients.size() : 0));

            if (patients != null && !patients.isEmpty()) {
                patients.forEach(user -> user.setPassword(null));
                return Result.success(patients);
            } else {
                return Result.success(new java.util.ArrayList<>());
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取所有患者失败：" + e.getMessage());
        }
    }
}
