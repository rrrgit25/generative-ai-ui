package com.genai.backend.dto;

import java.time.Instant;

/**
 * Uniform error shape returned to clients; never includes internal exception details.
 */
public record ErrorResponse(int status, String error, String message, Instant timestamp) {

    public static ErrorResponse of(int status, String error, String message) {
        return new ErrorResponse(status, error, message, Instant.now());
    }
}
