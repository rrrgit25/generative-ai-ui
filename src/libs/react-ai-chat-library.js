import { generateText } from '../utils/api';

// Thin hook wrapper around the backend's text generation endpoint, kept separate from
// ChatBox so the chat UI doesn't need to know about the underlying API contract.
export const useChat = () => {
    const getResponse = async (input) => {
        try {
            return await generateText(input);
        } catch (error) {
            console.error('Error fetching AI response:', error);
            return 'Sorry, there was an error processing your request.';
        }
    };

    return { getResponse };
};

