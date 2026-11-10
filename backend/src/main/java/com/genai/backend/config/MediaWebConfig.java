package com.genai.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

/**
 * Exposes generated media files (audio/images stored on disk) as static resources.
 */
@Configuration
public class MediaWebConfig implements WebMvcConfigurer {

    private final String storageDir;

    public MediaWebConfig(@Value("${app.media.storage-dir}") String storageDir) {
        this.storageDir = storageDir;
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String location = "file:" + Paths.get(storageDir).toAbsolutePath().normalize() + "/";
        registry.addResourceHandler("/media/**").addResourceLocations(location);
    }
}
