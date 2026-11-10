package com.genai.backend.service;

public interface TextGenerationService {

    /**
     * Generates natural-language text for the given prompt.
     */
    String generateText(String prompt);
}
