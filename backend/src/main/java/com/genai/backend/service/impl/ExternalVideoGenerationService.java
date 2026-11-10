package com.genai.backend.service.impl;

import com.genai.backend.exception.GenerationException;
import com.genai.backend.service.VideoGenerationService;
import io.github.resilience4j.ratelimiter.annotation.RateLimiter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.time.Duration;
import java.util.Map;

/**
 * Spring AI has no first-class video generation model as of this writing, so video generation is
 * implemented as a pluggable HTTP client against a configurable provider (e.g. Runway, Stability,
 * Pika). Configure app.video.provider-url / app.video.provider-api-key to enable it.
 */
@Service
public class ExternalVideoGenerationService implements VideoGenerationService {

    private static final Logger log = LoggerFactory.getLogger(ExternalVideoGenerationService.class);

    private final WebClient webClient;
    private final String providerUrl;
    private final String apiKey;
    private final Duration timeout;

    public ExternalVideoGenerationService(
            WebClient.Builder webClientBuilder,
            @Value("${app.video.provider-url:}") String providerUrl,
            @Value("${app.video.provider-api-key:}") String apiKey,
            @Value("${app.video.timeout-seconds:60}") long timeoutSeconds) {
        this.webClient = webClientBuilder.build();
        this.providerUrl = providerUrl;
        this.apiKey = apiKey;
        this.timeout = Duration.ofSeconds(timeoutSeconds);
    }

    @Override
    @RateLimiter(name = "generation")
    public String generateVideo(String prompt) {
        if (!StringUtils.hasText(providerUrl)) {
            throw new GenerationException(
                    "Video generation provider is not configured. Set VIDEO_PROVIDER_URL and VIDEO_PROVIDER_API_KEY");
        }
        try {
            VideoProviderResponse response = webClient.post()
                    .uri(providerUrl)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + apiKey)
                    .bodyValue(Map.of("prompt", prompt))
                    .retrieve()
                    .bodyToMono(VideoProviderResponse.class)
                    .timeout(timeout)
                    .block();

            if (response == null || !StringUtils.hasText(response.videoUrl())) {
                throw new GenerationException("Video provider returned an empty response");
            }
            return response.videoUrl();
        } catch (GenerationException e) {
            throw e;
        } catch (WebClientResponseException e) {
            log.error("Video provider request failed with status {}", e.getStatusCode(), e);
            throw new GenerationException("Video provider request failed: " + e.getStatusCode());
        } catch (Exception e) {
            log.error("Video generation failed for prompt of length {}", prompt.length(), e);
            throw new GenerationException("Failed to generate video", e);
        }
    }
}
