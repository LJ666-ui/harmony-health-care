package com.example.medical.controller;

import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.common.Result;
import com.example.medical.entity.User;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
@CrossOrigin
@Validated
public class UserController {

    @Autowired
    private UserService userService;

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
}
