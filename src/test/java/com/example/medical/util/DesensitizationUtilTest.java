package com.example.medical.util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * 数据脱敏工具类测试
 */
class DesensitizationUtilTest {

    @Test
    void testDesensitizePhone() {
        // 正常手机号
        assertEquals("138****1234", DesensitizationUtil.desensitizePhone("13812341234"));
        
        // 短手机号
        assertEquals("123", DesensitizationUtil.desensitizePhone("123"));
        
        // null
        assertNull(DesensitizationUtil.desensitizePhone(null));
    }

    @Test
    void testDesensitizeIdCard() {
        // 正常身份证号
        assertEquals("110***********1234", DesensitizationUtil.desensitizeIdCard("110101199001011234"));
        
        // 短身份证号
        assertEquals("12345678", DesensitizationUtil.desensitizeIdCard("12345678"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeIdCard(null));
    }

    @Test
    void testDesensitizeEmail() {
        // 正常邮箱
        assertEquals("z*******@e******.com", DesensitizationUtil.desensitizeEmail("zhangsan@example.com"));
        
        // 短邮箱
        assertEquals("a@b.com", DesensitizationUtil.desensitizeEmail("a@b.com"));
        
        // 无效邮箱
        assertEquals("invalid", DesensitizationUtil.desensitizeEmail("invalid"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeEmail(null));
    }

    @Test
    void testDesensitizeName() {
        // 正常姓名
        assertEquals("张**", DesensitizationUtil.desensitizeName("张三"));
        assertEquals("李**", DesensitizationUtil.desensitizeName("李四五"));
        
        // 单字姓名
        assertEquals("张", DesensitizationUtil.desensitizeName("张"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeName(null));
    }

    @Test
    void testDesensitizeAddress() {
        // 正常地址
        assertEquals("北京市朝阳区***********", DesensitizationUtil.desensitizeAddress("北京市朝阳区建国路88号"));
        
        // 短地址
        assertEquals("北京", DesensitizationUtil.desensitizeAddress("北京"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeAddress(null));
    }

    @Test
    void testDesensitizeBankCard() {
        // 正常银行卡号
        assertEquals("6222***********1234", DesensitizationUtil.desensitizeBankCard("6222021234567891234"));
        
        // 短银行卡号
        assertEquals("12345678", DesensitizationUtil.desensitizeBankCard("12345678"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeBankCard(null));
    }

    @Test
    void testDesensitizePassword() {
        // 正常密码
        assertEquals("******", DesensitizationUtil.desensitizePassword("password123"));
        
        // 空密码
        assertEquals("******", DesensitizationUtil.desensitizePassword(""));
        
        // null
        assertNull(DesensitizationUtil.desensitizePassword(null));
    }

    @Test
    void testDesensitizeIp() {
        // 正常IP
        assertEquals("192.168.*.*", DesensitizationUtil.desensitizeIp("192.168.1.100"));
        
        // 无效IP
        assertEquals("invalid", DesensitizationUtil.desensitizeIp("invalid"));
        
        // null
        assertNull(DesensitizationUtil.desensitizeIp(null));
    }

    @Test
    void testDesensitize() {
        // 通用脱敏
        assertEquals("abc***ghi", DesensitizationUtil.desensitize("abcdefghi", 3, 3));
        
        // 字符串太短
        assertEquals("abc", DesensitizationUtil.desensitize("abc", 2, 2));
        
        // null
        assertNull(DesensitizationUtil.desensitize(null, 2, 2));
    }

    @Test
    void testNeedDesensitize() {
        // 需要脱敏
        assertTrue(DesensitizationUtil.needDesensitize("test"));
        
        // 不需要脱敏
        assertFalse(DesensitizationUtil.needDesensitize(""));
        assertFalse(DesensitizationUtil.needDesensitize(null));
    }
}
