package com.genai.backend.service.impl;

import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.anthropic.AnthropicChatModel;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.TextGenerationService;

import io.github.resilience4j.ratelimiter.annotation.RateLimiter;

@Service
public class SpringAiTextGenerationService implements TextGenerationService {

    private static final Logger log = LoggerFactory.getLogger(SpringAiTextGenerationService.class);

    /** Metadata flag Spring AI's Anthropic integration sets on generations built from thinking blocks. */
    private static final String THINKING_METADATA_KEY = "thinking";

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
            ChatResponse response = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .chatResponse();
            String content = extractText(response);
            if (content.isBlank()) {
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

    /**
     * Joins the text of all non-thinking generations. Current Claude models think by default and
     * return a (by default empty) thinking block before the answer; Spring AI maps each content
     * block to its own Generation and {@code .content()} returns only the first one, which would
     * be the empty thinking block.
     */
    static String extractText(ChatResponse response) {
        if (response == null) {
            return "";
        }
        return response.getResults().stream()
                .map(Generation::getOutput)
                .filter(message -> message != null
                        && !Boolean.TRUE.equals(message.getMetadata().get(THINKING_METADATA_KEY)))
                .map(AssistantMessage::getText)
                .filter(text -> text != null && !text.isBlank())
                .collect(Collectors.joining("\n\n"));
    }
}
