import React, { useState } from 'react';
import { generateImage } from '../../utils/api';

const ImageGenerator = () => {
    const [prompt, setPrompt] = useState('');
    const [image, setImage] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleGenerateImage = async () => {
        setLoading(true);
        setError('');
        try {
            const imageUrl = await generateImage(prompt);
            setImage(imageUrl);
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="image-generator">
            <h2>Image Generator</h2>
            <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder="Enter your prompt here..."
            />
            <button onClick={handleGenerateImage} disabled={loading}>
                {loading ? 'Generating...' : 'Generate Image'}
            </button>
            {error && <p className="error">{error}</p>}
            {image && <img src={image} alt="Generated" />}
        </div>
    );
};

export default ImageGenerator;