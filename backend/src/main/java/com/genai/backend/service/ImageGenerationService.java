package com.genai.backend.service;

public interface ImageGenerationService {

    /**
     * Generates an image for the given prompt and returns a URL the client can render directly.
     */
    String generateImage(String prompt);
}
