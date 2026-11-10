import React, { useState } from 'react';
import { generateText } from '../../utils/api';

const TextGenerator = () => {
    const [prompt, setPrompt] = useState('');
    const [generatedText, setGeneratedText] = useState('');
    const [error, setError] = useState('');

    const handleGenerateText = async () => {
        setError('');
        try {
            const text = await generateText(prompt);
            setGeneratedText(text);
        } catch (err) {
            setError(err.message);
        }
    };

    return (
        <div className="text-generator">
            <h2>Text Generator</h2>
            <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Enter your prompt here..."
            />
            <button onClick={handleGenerateText}>Generate Text</button>
            {error && <p className="error">{error}</p>}
            {generatedText && (
                <div className="generated-text">
                    <h3>Generated Text:</h3>
                    <p>{generatedText}</p>
                </div>
            )}
        </div>
    );
};

export default TextGenerator;