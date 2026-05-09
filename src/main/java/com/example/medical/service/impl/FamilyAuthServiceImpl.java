package com.example.medical.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.medical.common.BCryptUtil;
import com.example.medical.common.JwtUtil;
import com.example.medical.dto.FamilyLoginRequest;
import com.example.medical.dto.FamilyLoginResponse;
import com.example.medical.entity.FamilyAuthLog;
import com.example.medical.entity.FamilyMember;
import com.example.medical.entity.User;
import com.example.medical.mapper.FamilyAuthLogMapper;
import com.example.medical.mapper.FamilyMemberMapper;
import com.example.medical.mapper.UserMapper;
import com.example.medical.service.FamilyAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Calendar;
import java.util.Date;

/**
 * 家属认证服务实现类
 */
@Service
public class FamilyAuthServiceImpl extends ServiceImpl<FamilyMemberMapper, FamilyMember> implements FamilyAuthService {

    @Autowired
    private FamilyMemberMapper familyMemberMapper;

    @Autowired
    private FamilyAuthLogMapper authLogMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public FamilyLoginResponse login(FamilyLoginRequest request) {
        // 1. 查询家属信息
        FamilyMember family = familyMemberMapper.selectByPhone(request.getPhone());
        if (family == null) {
            throw new RuntimeException("手机号不存在");
        }

        // 2. 检查登录权限
        if (family.getLoginEnabled() == null || family.getLoginEnabled() != 1) {
            throw new RuntimeException("家属登录功能未开启，请联系用户开启");
        }

        // 3. 检查账号锁定
        if (family.getLockUntil() != null && family.getLockUntil().after(new Date())) {
            throw new RuntimeException("账号已锁定，请稍后再试");
        }

        // 4. 验证密码
        if (!BCryptUtil.matches(request.getPassword(), family.getPassword())) {
            // 登录失败，增加失败次数
            handleLoginFail(family);
            throw new RuntimeException("密码错误");
        }

        // 5. 登录成功，生成Token
        String token = JwtUtil.generateFamilyToken(family.getId(), family.getPhone());

        // 6. 更新登录信息
        family.setLoginFailCount(0);
        family.setLockUntil(null);
        family.setLastLoginTime(new Date());
        familyMemberMapper.updateById(family);

        // 7. 记录登录日志
        saveAuthLog(family.getId(), true, null);

        // 8. 构建响应
        FamilyLoginResponse response = new FamilyLoginResponse();
        response.setToken(token);
        response.setFamilyInfo(family);

        // 查询关联用户信息
        User relatedUser = userMapper.selectById(family.getUserId());
        response.setRelatedUser(relatedUser);

        return response;
    }

    @Override
    public FamilyMember getFamilyInfo(Long familyId) {
        FamilyMember family = familyMemberMapper.selectById(familyId);
        if (family == null) {
            throw new RuntimeException("家属信息不存在");
        }
        return family;
    }

    @Override
    public boolean updateLoginEnabled(Long familyId, Integer loginEnabled, String defaultPassword) {
        FamilyMember family = familyMemberMapper.selectById(familyId);
        if (family == null) {
            throw new RuntimeException("家属信息不存在");
        }

        family.setLoginEnabled(loginEnabled);

        // 如果开启登录且提供了默认密码，则设置密码
        if (loginEnabled == 1 && defaultPassword != null && !defaultPassword.isEmpty()) {
            family.setPassword(BCryptUtil.encrypt(defaultPassword));
        }

        return familyMemberMapper.updateById(family) > 0;
    }

    /**
     * 处理登录失败
     */
    private void handleLoginFail(FamilyMember family) {
        // 增加失败次数
        int failCount = (family.getLoginFailCount() == null ? 0 : family.getLoginFailCount()) + 1;
        family.setLoginFailCount(failCount);

        // 失败3次，锁定30分钟
        if (failCount >= 3) {
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.MINUTE, 30);
            family.setLockUntil(cal.getTime());
        }

        familyMemberMapper.updateById(family);

        // 记录失败日志
        saveAuthLog(family.getId(), false, "密码错误");
    }

    /**
     * 保存认证日志
     */
    private void saveAuthLog(Long familyId, boolean success, String reason) {
        FamilyAuthLog log = new FamilyAuthLog();
        log.setFamilyId(familyId);
        log.setLoginTime(new Date());
        log.setLoginResult(success ? 1 : 0);
        log.setFailReason(reason);
        authLogMapper.insert(log);
    }
}
