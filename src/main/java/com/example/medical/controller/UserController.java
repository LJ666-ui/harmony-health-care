package com.example.medical.controller;

import com.example.medical.common.Result;
import com.example.medical.entity.User;
import com.example.medical.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;

@RestController
@RequestMapping("/user")
@CrossOrigin
public class UserController {

    @Autowired
    private UserService userService;

    // 用户注册
    @PostMapping("/register")
    public Result<?> register(@RequestBody User user) {
        // 检查用户名是否已存在
        if (userService.findByUsername(user.getUsername()) != null) {
            return Result.error("用户名已存在");
        }
        // 设置默认值
        if (user.getUserType() == null) {
            user.setUserType(0);
        }
        user.setCreateTime(new Date());
        // 保存用户
        if (userService.save(user)) {
            return Result.success("注册成功");
        } else {
            return Result.error("注册失败");
        }
    }

    // 用户登录
    @PostMapping("/login")
    public Result<?> login(@RequestBody User user) {
        // 根据用户名查询用户
        User dbUser = userService.findByUsername(user.getUsername());
        if (dbUser == null) {
            return Result.error("用户名不存在");
        }
        // 验证密码
        if (!dbUser.getPassword().equals(user.getPassword())) {
            return Result.error("密码错误");
        }
        // 登录成功，返回用户信息
        return Result.success(dbUser);
    }

    // 获取用户信息
    @GetMapping("/info")
    public Result<?> getUserInfo(@RequestParam Long id) {
        User user = userService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        return Result.success(user);
    }

    // 修改用户信息
    @PostMapping("/update")
    public Result<?> updateUser(@RequestBody User user) {
        if (userService.updateById(user)) {
            return Result.success("更新成功");
        } else {
            return Result.error("更新失败");
        }
    }
}