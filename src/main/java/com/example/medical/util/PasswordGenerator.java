package com.example.medical.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGenerator {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        String password = "admin123";
        String hash = encoder.encode(password);
        
        System.out.println("=====================================");
        System.out.println("Password: " + password);
        System.out.println("Bcrypt Hash: " + hash);
        System.out.println("=====================================");
        System.out.println();
        System.out.println("SQL to update admin password:");
        System.out.println("UPDATE admin SET password = '" + hash + "' WHERE username = 'admin';");
        System.out.println();
        
        boolean matches = encoder.matches(password, hash);
        System.out.println("Verification: Password matches hash = " + matches);
    }
}
