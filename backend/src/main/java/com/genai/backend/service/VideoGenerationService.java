package com.genai.backend.service;

public interface VideoGenerationService {

    /**
     * Generates a video for the given prompt and returns a URL the client can play directly.
     */
    String generateVideo(String prompt);
}
