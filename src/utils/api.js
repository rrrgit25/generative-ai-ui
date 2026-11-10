import axios from 'axios';
import apiConfig from '../config/apiConfig';

const client = axios.create({ baseURL: apiConfig.baseURL });

// Extracts the backend's ErrorResponse.message when available, falling back to a generic message.
const extractErrorMessage = (error) =>
    error.response?.data?.message || error.message || 'Request failed';

// The backend returns absolute URLs for hosted media (e.g. OpenAI-hosted images) but relative
// paths like "/media/xxx.mp3" for locally stored files. Relative paths must be qualified with
// the backend's own origin, since the browser would otherwise resolve them against the
// frontend's origin (e.g. localhost:3000) and 404.
const resolveMediaUrl = (url) => {
    if (!url || /^https?:\/\//i.test(url)) {
        return url;
    }
    return `${apiConfig.baseURL}${url}`;
};

export const generateText = async (prompt) => {
    try {
        const { data } = await client.post(apiConfig.endpoints.generateText, { prompt });
        return data.generatedText;
    } catch (error) {
        console.error('Error generating text:', error);
        throw new Error(extractErrorMessage(error));
    }
};

export const generateImage = async (prompt) => {
    try {
        const { data } = await client.post(apiConfig.endpoints.generateImage, { prompt });
        return resolveMediaUrl(data.imageUrl);
    } catch (error) {
        console.error('Error generating image:', error);
        throw new Error(extractErrorMessage(error));
    }
};

export const generateAudio = async (prompt) => {
    try {
        const { data } = await client.post(apiConfig.endpoints.generateAudio, { prompt });
        return resolveMediaUrl(data.audioUrl);
    } catch (error) {
        console.error('Error generating audio:', error);
        throw new Error(extractErrorMessage(error));
    }
};

export const generateVideo = async (prompt) => {
    try {
        const { data } = await client.post(apiConfig.endpoints.generateVideo, { prompt });
        return resolveMediaUrl(data.videoUrl);
    } catch (error) {
        console.error('Error generating video:', error);
        throw new Error(extractErrorMessage(error));
    }
};