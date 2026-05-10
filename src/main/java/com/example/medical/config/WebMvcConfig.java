package com.example.medical.config;

import com.example.medical.common.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + System.getProperty("user.dir") + "/uploads/");
    }

    // 合并所有放行接口，无遗漏、无冲突
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        // 用户端
                        "/user/login",
                        "/user/register",
                        "/user/send-code",
                        // 管理员端
                        "/admin/login",
                        "/admin/generate-password",
                        "/admin/fix-admin-password",
                        "/admin/verify-password",
                        // 家属/护士/医生端
                        "/family/login",
                        "/nurse/login",
                        "/doctor/login",
                        // 公共开放接口
                        "/ai/**",
                        "/herbal/**",
                        "/medicine/**",
                        "/medicine-category/**",
                        "/ancient-image/list",
                        "/ancient-image/*",
                        // 康复训练接口
                        "/api/rehab/action/list",
                        "/api/rehab/action/detail/**",
                        "/api/rehab/plan/list",
                        "/api/rehab/plan/detail/**",
                        "/api/rehab/plan/actions/**",
                        "/api/rehab/plan/progress/**",
                        "/api/rehab/plan/recommend/**",
                        // 支付接口
                        "/pay/notify",
                        "/pay/return",
                        // 系统通用
                        "/error",
                        "/uploads/**"
                );
    }

    public static class JwtInterceptor implements HandlerInterceptor {

        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            // 放行预检请求
            if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
                return true;
            }

            String token = request.getHeader("Token");
            if (token == null || token.isEmpty()) {
                handleUnauthorized(response, "未登录，请先登录");
                return false;
            }

            try {
                // 校验Token是否有效/过期
                if (!JwtUtil.validateToken(token)) {
                    handleUnauthorized(response, "Token已过期，请重新登录");
                    return false;
                }
                // 解析用户信息存入request
                Long userId = JwtUtil.getUserId(token);
                String username = JwtUtil.getUsername(token);
                request.setAttribute("userId", userId);
                request.setAttribute("username", username);
                return true;
            } catch (Exception e) {
                handleUnauthorized(response, "Token无效，请重新登录");
                return false;
            }
        }

        // 统一返回401未授权JSON格式
        private void handleUnauthorized(HttpServletResponse response, String message) throws IOException {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            Map<String, Object> result = new HashMap<>();
            result.put("code", 401);
            result.put("msg", message);
            result.put("data", null);
            ObjectMapper mapper = new ObjectMapper();
            response.getWriter().write(mapper.writeValueAsString(result));
        }
    }
}