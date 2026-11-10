package com.genai.backend.controller;

import com.genai.backend.dto.AudioGenerationResponse;
import com.genai.backend.dto.GenerationRequest;
import com.genai.backend.service.AudioGenerationService;
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
@Tag(name = "Audio Generation")
public class AudioGenerationController {

    private final AudioGenerationService audioGenerationService;

    public AudioGenerationController(AudioGenerationService audioGenerationService) {
        this.audioGenerationService = audioGenerationService;
    }

    @Operation(summary = "Generate speech audio from a prompt")
    @PostMapping("/generate-audio")
    public ResponseEntity<AudioGenerationResponse> generateAudio(@Valid @RequestBody GenerationRequest request) {
        String audioUrl = audioGenerationService.generateAudio(request.prompt());
        return ResponseEntity.ok(new AudioGenerationResponse(audioUrl));
    }
}
