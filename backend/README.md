# Generative AI Backend

Spring Boot 3 + Spring AI microservice providing text, image, audio, and video generation
endpoints for the `generative-ai-ui` frontend.

## API contract

All endpoints accept `POST` with body `{ "prompt": "..." }` and match the frontend's fetch calls
(`src/components/Generators/*.jsx`):

| Endpoint              | Response field  | Backing model                                  |
|------------------------|-----------------|-------------------------------------------------|
| `/api/generate-text`  | `generatedText` | Spring AI `ChatClient` (Anthropic Claude)        |
| `/api/generate-image` | `imageUrl`      | Spring AI `ImageModel` (OpenAI DALL-E)           |
| `/api/generate-audio` | `audioUrl`      | Spring AI `OpenAiAudioSpeechModel` (TTS)         |
| `/api/generate-video` | `videoUrl`      | Pluggable external provider (WebClient, no Spring AI video support yet) |

Generated audio (and image fallback when no hosted URL is returned) is written to
`app.media.storage-dir` and served back as a static resource under `/media/**`.

## Configuration

Copy `.env.example` to `.env` (or set environment variables directly) and provide:

- `ANTHROPIC_API_KEY` — required for text generation (Claude has no image/audio/video API).
- `OPENAI_API_KEY` — required for image and audio generation.
- `VIDEO_PROVIDER_URL` / `VIDEO_PROVIDER_API_KEY` — optional; video generation returns a 502 with
  a clear message until configured.
- `CORS_ALLOWED_ORIGINS` — comma-separated list, defaults to `http://localhost:3000` (the CRA dev server).

Never commit real API keys; `.env` is git-ignored.

## Running locally

```bash
cd backend
export ANTHROPIC_API_KEY=sk-ant-...
export OPENAI_API_KEY=sk-...
./mvnw spring-boot:run
```

The service starts on `http://localhost:8080`. Swagger UI is available at
`/swagger-ui.html`, health checks at `/actuator/health`.

## Design notes / best practices applied

- **Layered architecture**: controller → service interface → provider-specific implementation,
  enabling swapping providers without touching controllers.
- **DTOs with bean validation** (`@NotBlank`, `@Size`) reject invalid/oversized prompts at the boundary.
- **Centralized exception handling** (`GlobalExceptionHandler`) returns a consistent error shape and
  never leaks stack traces or provider error details to clients.
- **Rate limiting** (Resilience4j) on all generation endpoints to protect against abuse and control
  AI provider cost exposure.
- **Secrets externalized** via environment variables, never hard-coded or logged.
- **CORS locked down** to an explicit origin allow-list instead of `*`.
- **Path traversal guard** in `MediaStorageService` when persisting generated files.
- **OpenAPI/Swagger** documentation generated from annotated controllers.
- **Testable by construction**: constructor injection everywhere, `@WebMvcTest` + Mockito for
  controller-level tests without booting AI clients.

## Docker

```bash
docker build -t generative-ai-backend .
docker run -p 8080:8080 -e ANTHROPIC_API_KEY=sk-ant-... -e OPENAI_API_KEY=sk-... generative-ai-backend
```
