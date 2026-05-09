package com.example.medical.util;

/**
 * 数据脱敏工具类
 * 用于对敏感数据进行脱敏处理，保护用户隐私
 */
public class DesensitizationUtil {

    /**
     * 手机号脱敏
     * 格式：138****1234
     * 
     * @param phone 手机号
     * @return 脱敏后的手机号
     */
    public static String desensitizePhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }

    /**
     * 身份证号脱敏
     * 格式：110***********1234
     * 
     * @param idCard 身份证号
     * @return 脱敏后的身份证号
     */
    public static String desensitizeIdCard(String idCard) {
        if (idCard == null || idCard.length() < 8) {
            return idCard;
        }
        return idCard.substring(0, 3) + "***********" + idCard.substring(idCard.length() - 4);
    }

    /**
     * 邮箱脱敏
     * 格式：z*******@e******.com
     * 
     * @param email 邮箱
     * @return 脱敏后的邮箱
     */
    public static String desensitizeEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        
        String[] parts = email.split("@");
        if (parts.length != 2) {
            return email;
        }
        
        String username = parts[0];
        String domain = parts[1];
        
        // 脱敏用户名
        String desensitizedUsername = username.substring(0, 1) + 
            "*******".substring(0, Math.min(7, username.length() - 1));
        
        // 脱敏域名
        String[] domainParts = domain.split("\\.");
        if (domainParts.length >= 2) {
            String domainName = domainParts[0];
            String extension = domainParts[1];
            String desensitizedDomain = domainName.substring(0, 1) + 
                "******".substring(0, Math.min(6, domainName.length() - 1)) + "." + extension;
            return desensitizedUsername + "@" + desensitizedDomain;
        }
        
        return desensitizedUsername + "@" + domain;
    }

    /**
     * 姓名脱敏
     * 格式：张**
     * 
     * @param name 姓名
     * @return 脱敏后的姓名
     */
    public static String desensitizeName(String name) {
        if (name == null || name.length() < 2) {
            return name;
        }
        return name.substring(0, 1) + "**";
    }

    /**
     * 地址脱敏
     * 格式：北京市朝阳区***********
     * 
     * @param address 地址
     * @return 脱敏后的地址
     */
    public static String desensitizeAddress(String address) {
        if (address == null || address.length() < 6) {
            return address;
        }
        
        // 保留前6个字符（省市区）
        int keepLength = Math.min(6, address.length());
        return address.substring(0, keepLength) + "***********";
    }

    /**
     * 银行卡号脱敏
     * 格式：6222***********1234
     * 
     * @param bankCard 银行卡号
     * @return 脱敏后的银行卡号
     */
    public static String desensitizeBankCard(String bankCard) {
        if (bankCard == null || bankCard.length() < 8) {
            return bankCard;
        }
        return bankCard.substring(0, 4) + "***********" + bankCard.substring(bankCard.length() - 4);
    }

    /**
     * 密码脱敏
     * 格式：******
     * 
     * @param password 密码
     * @return 脱敏后的密码
     */
    public static String desensitizePassword(String password) {
        if (password == null) {
            return null;
        }
        return "******";
    }

    /**
     * IP地址脱敏
     * 格式：192.168.*.*
     * 
     * @param ip IP地址
     * @return 脱敏后的IP地址
     */
    public static String desensitizeIp(String ip) {
        if (ip == null || !ip.contains(".")) {
            return ip;
        }
        
        String[] parts = ip.split("\\.");
        if (parts.length == 4) {
            return parts[0] + "." + parts[1] + ".*.*";
        }
        
        return ip;
    }

    /**
     * 通用脱敏方法
     * 保留前preLength个字符和后sufLength个字符，中间用*代替
     * 
     * @param str 原始字符串
     * @param preLength 保留前几个字符
     * @param sufLength 保留后几个字符
     * @return 脱敏后的字符串
     */
    public static String desensitize(String str, int preLength, int sufLength) {
        if (str == null || str.length() <= preLength + sufLength) {
            return str;
        }
        
        int length = str.length();
        int maskLength = length - preLength - sufLength;
        StringBuilder mask = new StringBuilder();
        for (int i = 0; i < maskLength; i++) {
            mask.append("*");
        }
        
        return str.substring(0, preLength) + mask.toString() + str.substring(length - sufLength);
    }

    /**
     * 判断是否需要脱敏
     * 
     * @param str 字符串
     * @return 是否需要脱敏
     */
    public static boolean needDesensitize(String str) {
        return str != null && str.length() > 0;
    }
}
