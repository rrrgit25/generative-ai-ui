package com.genai.backend.service.impl;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.model.Generation;

class SpringAiTextGenerationServiceTest {

    private static Generation thinking(String text) {
        return new Generation(AssistantMessage.builder()
                .content(text)
                .properties(Map.of("thinking", Boolean.TRUE, "signature", "sig"))
                .build());
    }

    private static Generation text(String text) {
        return new Generation(AssistantMessage.builder().content(text).build());
    }

    @Test
    void skipsEmptyThinkingBlockBeforeAnswer() {
        ChatResponse response = new ChatResponse(List.of(thinking(""), text("Hi there, friend!")));
        assertThat(SpringAiTextGenerationService.extractText(response)).isEqualTo("Hi there, friend!");
    }

    @Test
    void skipsSummarizedThinkingText() {
        ChatResponse response = new ChatResponse(List.of(thinking("reasoning summary"), text("Answer")));
        assertThat(SpringAiTextGenerationService.extractText(response)).isEqualTo("Answer");
    }

    @Test
    void returnsBlankWhenOnlyThinking() {
        ChatResponse response = new ChatResponse(List.of(thinking("")));
        assertThat(SpringAiTextGenerationService.extractText(response)).isBlank();
        assertThat(SpringAiTextGenerationService.extractText(null)).isBlank();
    }
}
