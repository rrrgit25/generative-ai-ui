package com.genai.backend.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.anthropic.AnthropicChatModel;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.TextGenerationService;

import io.github.resilience4j.ratelimiter.annotation.RateLimiter;

@Service
public class SpringAiTextGenerationService implements TextGenerationService {

    private static final Logger log = LoggerFactory.getLogger(SpringAiTextGenerationService.class);

    private final ChatClient chatClient;

    public SpringAiTextGenerationService(AnthropicChatModel anthropicChatModel,
                                          @Value("${spring.ai.anthropic.api-key:}") String apiKey) {
        this.chatClient = ChatClient.builder(anthropicChatModel).build();
        if (apiKey.isBlank()) {
            throw new IllegalStateException(
                "ANTHROPIC_API_KEY is not set — set it as an environment variable before starting the app.");
        }
    }

    @Override
    @RateLimiter(name = "generation")
    public String generateText(String prompt) {
        try {
            String content = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();
            if (content == null || content.isBlank()) {
                throw new GenerationException("Model returned an empty response");
            }
            return content;
        } catch (GenerationException e) {
            throw e;
        } catch (Exception e) {
            log.error("Text generation failed for prompt of length {}", prompt.length(), e);
            throw new GenerationException("Failed to generate text", e);
        }
    }
}
