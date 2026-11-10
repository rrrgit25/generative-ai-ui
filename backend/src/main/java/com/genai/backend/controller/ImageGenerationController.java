package com.genai.backend.controller;

import com.genai.backend.dto.GenerationRequest;
import com.genai.backend.dto.ImageGenerationResponse;
import com.genai.backend.service.ImageGenerationService;
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
@Tag(name = "Image Generation")
public class ImageGenerationController {

    private final ImageGenerationService imageGenerationService;

    public ImageGenerationController(ImageGenerationService imageGenerationService) {
        this.imageGenerationService = imageGenerationService;
    }

    @Operation(summary = "Generate an image from a prompt")
    @PostMapping("/generate-image")
    public ResponseEntity<ImageGenerationResponse> generateImage(@Valid @RequestBody GenerationRequest request) {
        String imageUrl = imageGenerationService.generateImage(request.prompt());
        return ResponseEntity.ok(new ImageGenerationResponse(imageUrl));
    }
}
