import React from 'react';
import Navbar from '../components/Navbar';
import Chat from '../components/Chat/ChatBox';
import PromptEditor from '../components/Editor/PromptEditor';
import TextGenerator from '../components/Generators/TextGenerator';
import ImageGenerator from '../components/Generators/ImageGenerator';
import AudioGenerator from '../components/Generators/AudioGenerator';
import VideoGenerator from '../components/Generators/VideoGenerator';
import '../styles/home.css';

const Home = () => {
    return (
        <div className="home-container">
            <header className="home-header">
                <h1>Rath GPT</h1>
                <p>Your all-in-one AI studio for generating text, images, audio, and video.</p>
            </header>
            <main className="home-main">
                <section className="prompt-editor-section">
                    <h2>Prompt Editor</h2>
                    <PromptEditor />
                </section>
                <section className="chat-section">
                    <h2>Chat</h2>
                    <Chat />
                </section>
                <section className="generators-section">
                    <h2>Generators</h2>
                    <div className="generators-grid">
                        <TextGenerator />
                        <ImageGenerator />
                        <AudioGenerator />
                        <VideoGenerator />
                    </div>
                </section>
            </main>
        </div>
    );
};

export default Home;