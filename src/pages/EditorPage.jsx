import React from 'react';
import PromptEditor from '../components/Editor/PromptEditor';
import SettingsPanel from '../components/Editor/SettingsPanel';
import TextGenerator from '../components/Generators/TextGenerator';
import ImageGenerator from '../components/Generators/ImageGenerator';
import AudioGenerator from '../components/Generators/AudioGenerator';
import VideoGenerator from '../components/Generators/VideoGenerator';

const EditorPage = () => {
    return (
        <div className="editor-page">
            <h1>Generative AI Editor</h1>
            <PromptEditor />
            <SettingsPanel />
            <div className="generators">
                <TextGenerator />
                <ImageGenerator />
                <AudioGenerator />
                <VideoGenerator />
            </div>
        </div>
    );
};

export default EditorPage;