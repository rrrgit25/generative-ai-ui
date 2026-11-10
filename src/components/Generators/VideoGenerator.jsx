import React, { useState } from 'react';
import { generateVideo } from '../../utils/api';

const VideoGenerator = () => {
    const [prompt, setPrompt] = useState('');
    const [video, setVideo] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleGenerateVideo = async () => {
        setError('');
        
        // Video provider URL/key are configured on the backend only; never expose them in the bundle.
        if (!prompt.trim()) {
            setError('Please enter a prompt for video generation');
            return;
        }

        setLoading(true);
        try {
            const videoUrl = await generateVideo(prompt);
            setVideo(videoUrl);
        } catch (err) {
            setError(err.message || 'Failed to generate video. Check API keys and try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="video-generator">
            <h2>Video Generator</h2>
            <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Enter your prompt here"
            />
            <button onClick={handleGenerateVideo} disabled={loading}>
                {loading ? 'Generating...' : 'Generate Video'}
            </button>
            {error && <p className="error">{error}</p>}
            {video && (
                <div className="generated-video">
                    <h3>Generated Video:</h3>
                    <video controls>
                        <source src={video} type="video/mp4" />
                        Your browser does not support the video tag.
                    </video>
                </div>
            )}
        </div>
    );
};

export default VideoGenerator;