package com.medical;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 生成BCrypt密码hash的工具类
 */
public class PasswordHashGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 生成 admin123 的BCrypt hash
        String password = "admin123";
        String hash = encoder.encode(password);
        
        System.out.println("========================================");
        System.out.println("Password: " + password);
        System.out.println("BCrypt Hash: " + hash);
        System.out.println("========================================");
        
        // 验证hash是否正确
        boolean matches = encoder.matches(password, hash);
        System.out.println("Verification: " + matches);
        
        // 也生成一些其他常用密码的hash
        System.out.println("\n========================================");
        System.out.println("Other common passwords:");
        System.out.println("========================================");
        
        String[] passwords = {"123456", "admin", "password"};
        for (String pwd : passwords) {
            String h = encoder.encode(pwd);
            System.out.println("Password: " + pwd + " -> Hash: " + h);
        }
    }
}
