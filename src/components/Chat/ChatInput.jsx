import React, { useState } from 'react';

const ChatInput = ({ onSend }) => {
    const [message, setMessage] = useState('');

    const handleChange = (event) => {
        setMessage(event.target.value);
    };

    const handleSubmit = (event) => {
        event.preventDefault();
        if (message.trim()) {
            onSend(message);
            setMessage('');
        }
    };

    return (
        <form onSubmit={handleSubmit} className="chat-input">
            <input
                type="text"
                value={message}
                onChange={handleChange}
                placeholder="Type your message..."
                className="chat-input-field"
            />
            <button type="submit" className="chat-input-button">Send</button>
        </form>
    );
};

export default ChatInput;