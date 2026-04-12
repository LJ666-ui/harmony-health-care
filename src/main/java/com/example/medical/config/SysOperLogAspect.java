package com.example.medical.config;

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
import java.util.Date;

@Aspect
@Component
public class SysOperLogAspect {
    @Autowired
    private SysOperLogService sysOperLogService;

    // 定义切点，拦截所有Controller的方法
    @Pointcut("execution(* com.example.medical.controller.*.*(..))")
    public void controllerPointcut() {
    }

    // 方法执行后记录操作日志
    @AfterReturning(pointcut = "controllerPointcut()", returning = "result")
    public void recordOperLog(JoinPoint joinPoint, Object result) {
        try {
            // 获取请求信息
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes == null) {
                return;
            }
            HttpServletRequest request = attributes.getRequest();

            // 获取操作用户ID（实际项目中应该从JWT token中获取）
            Long userId = 1L; // 假设当前用户ID为1

            // 获取操作类型
            String operationType = getOperationType(request.getMethod());

            // 获取操作描述
            String operationDesc = getOperationDesc(joinPoint);

            // 获取IP地址
            String ipAddress = getIpAddress(request);

            // 获取设备信息
            String deviceInfo = request.getHeader("User-Agent");

            // 记录操作日志
            sysOperLogService.addOperLog(userId, operationType, operationDesc, ipAddress, deviceInfo);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 根据HTTP方法获取操作类型
    private String getOperationType(String httpMethod) {
        switch (httpMethod.toUpperCase()) {
            case "GET":
                return "查询";
            case "POST":
                return "新增";
            case "PUT":
                return "修改";
            case "DELETE":
                return "删除";
            default:
                return "其他";
        }
    }

    // 获取操作描述
    private String getOperationDesc(JoinPoint joinPoint) {
        String className = joinPoint.getTarget().getClass().getName();
        String methodName = joinPoint.getSignature().getName();
        return className + "." + methodName;
    }

    // 获取IP地址
    private String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}