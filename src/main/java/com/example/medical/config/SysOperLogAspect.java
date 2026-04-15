package com.example.medical.config;

import com.example.medical.common.JwtUtil;
import com.example.medical.service.SysOperLogService;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;

@Aspect
@Component
public class SysOperLogAspect {

    @Autowired
    private SysOperLogService sysOperLogService;

    // 拦截所有controller
    @Pointcut("execution(* com.example.medical.controller.*.*(..))")
    public void controllerPointcut() {}

    // 接口执行成功后记录日志
    @AfterReturning(pointcut = "controllerPointcut()", returning = "result")
    public void recordOperLog(JoinPoint joinPoint, Object result) {
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) return;

            HttpServletRequest request = attributes.getRequest();
            Long userId = getCurrentUserId(request); // ✅ 这里会拿到 101

            String operationType = getOperationType(request.getMethod());
            String operationDesc = getOperationDesc(joinPoint);
            String ipAddress = getIpAddress(request);
            String deviceInfo = request.getHeader("User-Agent");

            // 保存日志
            sysOperLogService.addOperLog(userId, operationType, operationDesc, ipAddress, deviceInfo);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // =============================================
    // 🔴 关键修复：从Token正确获取userId，不再是0
    // =============================================
    private Long getCurrentUserId(HttpServletRequest request) {
        try {
            String auth = request.getHeader("Authorization");
            if (auth != null && auth.startsWith("Bearer ")) {
                String token = auth.substring(7).trim();
                if (JwtUtil.validateToken(token)) {
                    return JwtUtil.getUserId(token);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0L;
    }

    private String getOperationType(String httpMethod) {
        switch (httpMethod.toUpperCase()) {
            case "GET": return "查询";
            case "POST": return "新增";
            case "PUT": return "修改";
            case "DELETE": return "删除";
            default: return "其他";
        }
    }

    private String getOperationDesc(JoinPoint joinPoint) {
        return joinPoint.getTarget().getClass().getName() + "." + joinPoint.getSignature().getName();
    }

    private String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip))
            ip = request.getHeader("Proxy-Client-IP");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip))
            ip = request.getRemoteAddr();
        return ip;
    }
}