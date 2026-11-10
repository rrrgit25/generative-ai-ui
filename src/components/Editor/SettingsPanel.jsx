import React, { useState } from 'react';

const SettingsPanel = () => {
    const [settings, setSettings] = useState({
        textGeneration: true,
        imageGeneration: true,
        audioGeneration: true,
        videoGeneration: true,
    });

    const handleToggle = (setting) => {
        setSettings((prevSettings) => ({
            ...prevSettings,
            [setting]: !prevSettings[setting],
        }));
    };

    return (
        <div className="settings-panel">
            <h2>Settings</h2>
            <div>
                <label>
                    <input
                        type="checkbox"
                        checked={settings.textGeneration}
                        onChange={() => handleToggle('textGeneration')}
                    />
                    Enable Text Generation
                </label>
            </div>
            <div>
                <label>
                    <input
                        type="checkbox"
                        checked={settings.imageGeneration}
                        onChange={() => handleToggle('imageGeneration')}
                    />
                    Enable Image Generation
                </label>
            </div>
            <div>
                <label>
                    <input
                        type="checkbox"
                        checked={settings.audioGeneration}
                        onChange={() => handleToggle('audioGeneration')}
                    />
                    Enable Audio Generation
                </label>
            </div>
            <div>
                <label>
                    <input
                        type="checkbox"
                        checked={settings.videoGeneration}
                        onChange={() => handleToggle('videoGeneration')}
                    />
                    Enable Video Generation
                </label>
            </div>
        </div>
    );
};

export default SettingsPanel;