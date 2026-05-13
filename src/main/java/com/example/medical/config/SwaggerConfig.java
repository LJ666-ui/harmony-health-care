package com.example.medical.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("医疗健康管理系统API")
                        .description("harmony-health-care项目接口文档")
                        .version("1.0")
                        .contact(new Contact()
                                .name("Developer")
                                .url("https://example.com")
                                .email("developer@example.com")));
    }
}