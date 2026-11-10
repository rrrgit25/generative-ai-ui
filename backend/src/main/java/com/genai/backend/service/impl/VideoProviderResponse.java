package com.genai.backend.service.impl;

/**
 * Minimal response contract expected from the configurable external video generation provider.
 */
public record VideoProviderResponse(String videoUrl) {
}
