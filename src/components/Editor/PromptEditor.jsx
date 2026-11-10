import React, { useState } from 'react';

const PromptEditor = () => {
    const [prompt, setPrompt] = useState('');

    const handleChange = (event) => {
        setPrompt(event.target.value);
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        // Logic to handle prompt submission goes here
        console.log('Prompt submitted:', prompt);
    };

    return (
        <div className="prompt-editor">
            <h2>Edit Prompt</h2>
            <form onSubmit={handleSubmit}>
                <textarea
                    value={prompt}
                    onChange={handleChange}
                    placeholder="Type your prompt here..."
                    rows="4"
                    cols="50"
                />
                <button type="submit">Generate</button>
            </form>
        </div>
    );
};

export default PromptEditor;