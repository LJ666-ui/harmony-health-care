package com.example.medical.config;

import com.example.medical.common.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class SecurityConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new JwtInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/user/login",
                        "/user/register",
                        "/ai/**",
                        "/error"
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
