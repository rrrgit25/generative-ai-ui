package com.genai.backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI generativeAiOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Rath GPT API")
                        .description("Text, image, audio and video generation microservice powered by Spring AI")
                        .version("1.0.0"));
    }
}
