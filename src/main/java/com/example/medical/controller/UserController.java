package com.example.medical.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.DoctorMessage;
import com.example.medical.entity.User;
import com.example.medical.service.DoctorMessageService;
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
    private DoctorMessageService doctorMessageService;

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
            return Result.success("注册成功");
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
    public Result<List<User>> getDoctorList(@RequestParam(required = false) String keyword) {
        try {
            LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(User::getUserType, 1);
            wrapper.eq(User::getIsDeleted, 0);
            if (keyword != null && !keyword.isEmpty()) {
                final String kw = keyword.trim().toLowerCase();
                wrapper.and(w -> w.like(User::getUsername, kw)
                    .or()
                    .like(User::getPhone, kw));
            }
            wrapper.orderByDesc(User::getCreateTime);
            List<User> doctors = userService.list(wrapper);
            for (User doctor : doctors) {
                doctor.setPassword(null);
            }
            return Result.success(doctors);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取医生列表失败：" + e.getMessage());
        }
    }

    @PostMapping("/message/send")
    public Result<?> sendMessage(@RequestParam Long senderId, @RequestParam Long receiverId,
                                  @RequestParam String content) {
        try {
            DoctorMessage message = new DoctorMessage();
            message.setSenderId(senderId);
            message.setReceiverId(receiverId);
            message.setContent(content);
            message.setIsRead(0);
            message.setCreateTime(new Date());
            if (doctorMessageService.save(message)) {
                return Result.success(message);
            } else {
                return Result.error("发送失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("发送消息失败：" + e.getMessage());
        }
    }

    @GetMapping("/message/history")
    public Result<?> getMessageHistory(@RequestParam Long userA, @RequestParam Long userB) {
        try {
            List<DoctorMessage> messages = doctorMessageService.getConversation(userA, userB);
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
}
