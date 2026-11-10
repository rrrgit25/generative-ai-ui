import React from 'react';
import ChatBox from '../components/Chat/ChatBox';
import ChatInput from '../components/Chat/ChatInput';

const ChatPage = () => {
    return (
        <div className="chat-page">
            <h1>Chat with AI</h1>
            <ChatBox />
            <ChatInput />
        </div>
    );
};

export default ChatPage;