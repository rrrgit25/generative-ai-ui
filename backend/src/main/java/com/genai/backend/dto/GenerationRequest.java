package com.genai.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Common request payload for all generation endpoints, matching the frontend contract: { prompt }.
 */
public record GenerationRequest(

        @NotBlank(message = "prompt must not be blank")
        @Size(max = 2000, message = "prompt must not exceed 2000 characters")
        String prompt
) {
}
