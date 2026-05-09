package com.example.medical.config;

import com.example.medical.common.BCryptUtil;
import com.example.medical.entity.FamilyMember;
import com.example.medical.entity.User;
import com.example.medical.mapper.FamilyMemberMapper;
import com.example.medical.mapper.UserMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 密码初始化器
 * 在应用启动时检查并修复密码问题
 */
@Component
public class PasswordInitializer implements CommandLineRunner {
    
    private static final Logger logger = LoggerFactory.getLogger(PasswordInitializer.class);
    private static final String DEFAULT_PASSWORD = "123456";
    
    @Autowired
    private UserMapper userMapper;
    
    @Autowired
    private FamilyMemberMapper familyMemberMapper;
    
    @Override
    public void run(String... args) throws Exception {
        logger.info("开始检查密码初始化...");
        
        // 生成正确的BCrypt哈希值
        String correctHash = BCryptUtil.encrypt(DEFAULT_PASSWORD);
        logger.info("默认密码 '{}' 的BCrypt哈希值: {}", DEFAULT_PASSWORD, correctHash);
        
        // 检查并更新user表中的密码
        List<User> users = userMapper.selectList(null);
        int userUpdated = 0;
        for (User user : users) {
            // 检查密码是否是错误的示例值
            if (user.getPassword() != null && 
                (user.getPassword().contains("N.zmdr9k7uOCQv37uk7jO") ||
                 !BCryptUtil.matches(DEFAULT_PASSWORD, user.getPassword()))) {
                user.setPassword(correctHash);
                userMapper.updateById(user);
                userUpdated++;
                logger.info("更新用户 {} (ID: {}) 的密码", user.getUsername(), user.getId());
            }
        }
        
        // 检查并更新family_member表中的密码
        List<FamilyMember> familyMembers = familyMemberMapper.selectList(null);
        int familyUpdated = 0;
        for (FamilyMember family : familyMembers) {
            // 检查密码是否是错误的示例值
            if (family.getPassword() != null && 
                (family.getPassword().contains("N.zmdr9k7uOCQv37uk7jO") ||
                 !BCryptUtil.matches(DEFAULT_PASSWORD, family.getPassword()))) {
                family.setPassword(correctHash);
                // 重置登录失败次数
                family.setLoginFailCount(0);
                family.setLockUntil(null);
                familyMemberMapper.updateById(family);
                familyUpdated++;
                logger.info("更新家属 {} (ID: {}, Phone: {}) 的密码", 
                    family.getName(), family.getId(), family.getPhone());
            }
        }
        
        if (userUpdated > 0 || familyUpdated > 0) {
            logger.info("密码初始化完成！更新了 {} 个用户和 {} 个家属的密码", userUpdated, familyUpdated);
        } else {
            logger.info("密码检查完成，无需更新");
        }
    }
}
