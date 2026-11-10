package com.genai.backend.exception;

/**
 * Raised when an underlying AI provider/model fails to produce a valid generation result.
 */
public class GenerationException extends RuntimeException {

    public GenerationException(String message) {
        super(message);
    }

    public GenerationException(String message, Throwable cause) {
        super(message, cause);
    }
}
