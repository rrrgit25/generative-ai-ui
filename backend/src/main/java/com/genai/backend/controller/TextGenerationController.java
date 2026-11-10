package com.genai.backend.controller;

import com.genai.backend.dto.GenerationRequest;
import com.genai.backend.dto.TextGenerationResponse;
import com.genai.backend.service.TextGenerationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@Tag(name = "Text Generation")
public class TextGenerationController {

    private final TextGenerationService textGenerationService;

    public TextGenerationController(TextGenerationService textGenerationService) {
        this.textGenerationService = textGenerationService;
    }

    @Operation(summary = "Generate text from a prompt")
    @PostMapping("/generate-text")
    public ResponseEntity<TextGenerationResponse> generateText(@Valid @RequestBody GenerationRequest request) {
        String generatedText = textGenerationService.generateText(request.prompt());
        return ResponseEntity.ok(new TextGenerationResponse(generatedText));
    }
}
