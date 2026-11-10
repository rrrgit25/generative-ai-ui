import React, { useState } from 'react';
import { generateAudio } from '../../utils/api';

const AudioGenerator = () => {
    const [prompt, setPrompt] = useState('');
    const [audio, setAudio] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleGenerateAudio = async () => {
        setLoading(true);
        setError('');
        try {
            const audioUrl = await generateAudio(prompt);
            setAudio(audioUrl);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="audio-generator">
            <h2>Audio Generator</h2>
            <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Enter your prompt here..."
            />
            <button onClick={handleGenerateAudio} disabled={loading}>
                {loading ? 'Generating...' : 'Generate Audio'}
            </button>
            {error && <p className="error">{error}</p>}
            {audio && (
                <div>
                    <h3>Generated Audio:</h3>
                    <audio controls>
                        <source src={audio} type="audio/mpeg" />
                        Your browser does not support the audio tag.
                    </audio>
                </div>
            )}
        </div>
    );
};

export default AudioGenerator;