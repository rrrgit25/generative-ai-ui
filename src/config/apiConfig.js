// Base URL for the Spring Boot generation backend (see /backend). Configure per-env via
// REACT_APP_API_BASE_URL; defaults to the local Spring Boot dev port. An explicitly empty value
// means "same origin" (production: CloudFront routes /api/* and /media/* to the backend).
const API_BASE_URL = process.env.REACT_APP_API_BASE_URL ?? 'http://localhost:8080';

const apiConfig = {
    baseURL: API_BASE_URL,
    endpoints: {
        generateText: '/api/generate-text',
        generateImage: '/api/generate-image',
        generateAudio: '/api/generate-audio',
        generateVideo: '/api/generate-video',
    },
};

export { API_BASE_URL };
export default apiConfig;