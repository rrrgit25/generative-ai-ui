import React, { useState } from 'react';
import { useChat } from '../../libs/react-ai-chat-library'; // Ensure correct import path

const ChatBox = () => {
    const [messages, setMessages] = useState([]);
    const [input, setInput] = useState('');
    const { getResponse } = useChat();

    const handleSendMessage = async () => {
        if (input.trim()) {
            const userMessage = { text: input, sender: 'user' };
            setMessages((prevMessages) => [...prevMessages, userMessage]);

            try {
                const aiReply = await getResponse(input); // Get AI response from the library
                const aiMessage = { text: aiReply, sender: 'ai' };
                setMessages((prevMessages) => [...prevMessages, aiMessage]);
            } catch (error) {
                console.error('Error getting AI response:', error);
            }

            setInput('');
        }
    };

    return (
        <div className="chat-box">
            <div className="messages">
                {messages.map((message, index) => (
                    <div key={index} className={`message ${message.sender}`}>
                        {message.text}
                    </div>
                ))}
            </div>
            <div className="input-area">
                <input
                    type="text"
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    placeholder="Type a message..."
                />
                <button onClick={handleSendMessage}>Send</button>
            </div>
        </div>
    );
};

export default ChatBox;