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

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/user/login",
                        "/user/register",
                        "/user/send-code",  // 验证码接口无需登录
                        "/admin/login",  // 管理员登录接口无需登录
                        "/ai/**",
                        "/herbal/**",  // 药材百科接口无需登录
                        "/medicine/**",  // 药品信息接口无需登录
                        "/medicine-category/**",  // 药品分类接口无需登录
                        "/ancient-image/list",  // 古医图库查询无需登录
                        "/ancient-image/*",  // 古医图库详情无需登录
                        "/error",
                        "/uploads/**",
                        "/api/rehab/action/list",
                        "/api/rehab/action/detail/**",
                        "/api/rehab/plan/list",
                        "/api/rehab/plan/detail/**",
                        "/api/rehab/plan/actions/**",
                        "/api/rehab/plan/progress/**",
                        "/api/rehab/plan/recommend/**"
                );
    }

    public static class JwtInterceptor implements HandlerInterceptor {

        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
                return true;
            }

            String token = request.getHeader("Token");
            if (token == null || token.isEmpty()) {
                handleUnauthorized(response, "未登录，请先登录");
                return false;
            }

            try {
                if (!JwtUtil.validateToken(token)) {
                    handleUnauthorized(response, "Token已过期，请重新登录");
                    return false;
                }
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
