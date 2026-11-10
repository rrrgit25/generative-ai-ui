package com.genai.backend.service;

public interface AudioGenerationService {

    /**
     * Synthesizes speech audio for the given prompt and returns a URL the client can play directly.
     */
    String generateAudio(String prompt);
}
