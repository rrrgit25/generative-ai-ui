package com.genai.backend;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = {
        "spring.ai.anthropic.api-key=test-key",
        "spring.ai.openai.api-key=test-key"
})
class GenerativeAiBackendApplicationTests {

    @Test
    void contextLoads() {
        // Verifies the Spring application context starts successfully with all beans wired.
    }
}
