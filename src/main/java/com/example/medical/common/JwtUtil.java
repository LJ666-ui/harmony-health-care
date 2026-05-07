package com.example.medical.common;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class JwtUtil {
    private static final String SECRET_KEY = "medical-health-care-2024-secret-key-jwt-token";
    private static final long EXPIRE_TIME = 24 * 60 * 60 * 1000;

    public static String generateToken(Long userId, String username) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRE_TIME))
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    public static Claims parseToken(String token) {
        return Jwts.parser()
                .setSigningKey(SECRET_KEY)
                .parseClaimsJws(token)
                .getBody();
    }

    public static Long getUserId(String token) {
        return parseToken(token).get("userId", Long.class);
    }

    public static String getUsername(String token) {
        return parseToken(token).get("username", String.class);
    }

    public static boolean isTokenExpired(String token) {
        return parseToken(token).getExpiration().before(new Date());
    }

    /**
     * 生成家属Token
     */
    public static String generateFamilyToken(Long familyId, String phone) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("familyId", familyId);
        claims.put("phone", phone);
        claims.put("subject", "FAMILY");
        return Jwts.builder()
                .setClaims(claims)
                .setSubject("FAMILY")
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRE_TIME))
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    /**
     * 从Token中获取家属ID
     */
    public static Long getFamilyId(String token) {
        Claims claims = parseToken(token);
        if ("FAMILY".equals(claims.getSubject())) {
            return claims.get("familyId", Long.class);
        }
        return null;
    }

    /**
     * 判断是否为家属Token
     */
    public static boolean isFamilyToken(String token) {
        try {
            Claims claims = parseToken(token);
            return "FAMILY".equals(claims.getSubject());
        } catch (Exception e) {
            return false;
        }
    }

    public static boolean validateToken(String token) {
        try {
            parseToken(token);
            return !isTokenExpired(token);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * 生成护士Token
     */
    public static String generateNurseToken(Long nurseId, String phone) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("nurseId", nurseId);
        claims.put("phone", phone);
        claims.put("subject", "NURSE");
        return Jwts.builder()
                .setClaims(claims)
                .setSubject("NURSE")
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRE_TIME))
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    /**
     * 从Token中获取护士ID
     */
    public static Long getNurseId(String token) {
        Claims claims = parseToken(token);
        if ("NURSE".equals(claims.getSubject())) {
            return claims.get("nurseId", Long.class);
        }
        return null;
    }

    /**
     * 判断是否为护士Token
     */
    public static boolean isNurseToken(String token) {
        try {
            Claims claims = parseToken(token);
            return "NURSE".equals(claims.getSubject());
        } catch (Exception e) {
            return false;
        }
    }
}
