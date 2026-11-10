package com.genai.backend.service.impl;

import java.util.Base64;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.image.ImageModel;
import org.springframework.ai.image.ImagePrompt;
import org.springframework.ai.image.ImageResponse;
import org.springframework.ai.openai.OpenAiImageOptions;
import org.springframework.stereotype.Service;

import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.ImageGenerationService;
import com.genai.backend.service.MediaStorageService;

import io.github.resilience4j.ratelimiter.annotation.RateLimiter;

@Service
public class SpringAiImageGenerationService implements ImageGenerationService {

    private static final Logger log = LoggerFactory.getLogger(SpringAiImageGenerationService.class);

    private final ImageModel imageModel;
    private final MediaStorageService mediaStorageService;

    public SpringAiImageGenerationService(ImageModel imageModel, MediaStorageService mediaStorageService) {
        this.imageModel = imageModel;
        this.mediaStorageService = mediaStorageService;
    }

    @Override
    @RateLimiter(name = "generation")
    public String generateImage(String prompt) {
        try {
            OpenAiImageOptions options = OpenAiImageOptions.builder()
                    .quality("medium")
                    .n(1)
                    .height(1024)
                    .width(1024)
                    .build();
            ImageResponse response = imageModel.call(new ImagePrompt(prompt, options));
            var output = response.getResult().getOutput();

            if (output.getUrl() != null && !output.getUrl().isBlank()) {
                return output.getUrl();
            }
            if (output.getB64Json() != null && !output.getB64Json().isBlank()) {
                byte[] bytes = Base64.getDecoder().decode(output.getB64Json());
                return mediaStorageService.store(bytes, "images", "png");
            }
            throw new GenerationException("Image model returned no url or image data");
        } catch (GenerationException e) {
            throw e;
        } catch (Exception e) {
            log.error("Image generation failed for prompt of length {}", prompt.length(), e);
            throw new GenerationException("Failed to generate image", e);
        }
    }
}
