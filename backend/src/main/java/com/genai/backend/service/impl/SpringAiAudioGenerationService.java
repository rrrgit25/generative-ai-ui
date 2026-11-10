package com.genai.backend.service.impl;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.openai.OpenAiAudioSpeechModel;
import org.springframework.stereotype.Service;

import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.AudioGenerationService;
import com.genai.backend.service.MediaStorageService;

import io.github.resilience4j.ratelimiter.annotation.RateLimiter;

@Service
public class SpringAiAudioGenerationService implements AudioGenerationService {

    private static final Logger log = LoggerFactory.getLogger(SpringAiAudioGenerationService.class);

    private final OpenAiAudioSpeechModel speechModel;
    private final MediaStorageService mediaStorageService;

    public SpringAiAudioGenerationService(OpenAiAudioSpeechModel speechModel, MediaStorageService mediaStorageService) {
        this.speechModel = speechModel;
        this.mediaStorageService = mediaStorageService;
    }

    @Override
    @RateLimiter(name = "generation")
    public String generateAudio(String prompt) {
        try {
            // Uses the model's configured default options (voice/model/response-format from application.yml).
            byte[] audioBytes = speechModel.call(prompt);
            if (audioBytes == null || audioBytes.length == 0) {
                throw new GenerationException("Speech model returned no audio data");
            }
            return mediaStorageService.store(audioBytes, "audio", "mp3");
        } catch (GenerationException e) {
            throw e;
        } catch (Exception e) {
            log.error("Audio generation failed for prompt of length {}", prompt.length(), e);
            throw new GenerationException("Failed to generate audio", e);
        }
    }
}
