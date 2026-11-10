package com.genai.backend.controller;

import org.junit.jupiter.api.Test;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.genai.backend.dto.GenerationRequest;
import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.TextGenerationService;

@WebMvcTest(TextGenerationController.class)
class TextGenerationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @MockitoBean
    private TextGenerationService textGenerationService;

    @Test
    void generateText_returnsGeneratedText_forValidPrompt() throws Exception {
        when(textGenerationService.generateText(anyString())).thenReturn("Hello, world!");

        mockMvc.perform(post("/api/generate-text")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(new GenerationRequest("Say hello"))))
                .andExpect(status().isOk())
                .andExpect(content().contentType("application/json"))
                .andExpect(jsonPath("$.generatedText").value("Hello, world!"));
    }

    @Test
    void generateText_returnsBadRequest_forBlankPrompt() throws Exception {
        mockMvc.perform(post("/api/generate-text")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(new GenerationRequest(""))))
                .andExpect(status().isBadRequest());
    }

    @Test
    void generateText_returnsBadGateway_whenGenerationFails() throws Exception {
        when(textGenerationService.generateText(anyString()))
                .thenThrow(new GenerationException("Failed to generate text"));

        mockMvc.perform(post("/api/generate-text")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(new GenerationRequest("Say hello"))))
                .andExpect(status().isBadGateway());
    }
}
