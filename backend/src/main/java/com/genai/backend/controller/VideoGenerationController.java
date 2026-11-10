package com.genai.backend.controller;

import com.genai.backend.dto.GenerationRequest;
import com.genai.backend.dto.VideoGenerationResponse;
import com.genai.backend.service.VideoGenerationService;
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
@Tag(name = "Video Generation")
public class VideoGenerationController {

    private final VideoGenerationService videoGenerationService;

    public VideoGenerationController(VideoGenerationService videoGenerationService) {
        this.videoGenerationService = videoGenerationService;
    }

    @Operation(summary = "Generate a video from a prompt")
    @PostMapping("/generate-video")
    public ResponseEntity<VideoGenerationResponse> generateVideo(@Valid @RequestBody GenerationRequest request) {
        String videoUrl = videoGenerationService.generateVideo(request.prompt());
        return ResponseEntity.ok(new VideoGenerationResponse(videoUrl));
    }
}
