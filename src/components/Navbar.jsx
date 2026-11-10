import React from 'react';
import { Link } from 'react-router-dom';
import { useTheme } from '../context/ThemeContext';
import '../styles/components.css'; // Updated path

const Navbar = () => {
    const { theme, toggleTheme } = useTheme();

    return (
        <header className="navbar">
            <div className="navbar-brand">
                <Link to="/">Rath GPT</Link>
            </div>
            <nav className="navbar-menu">
                <ul className="navbar-links">
                    <li>
                        <Link to="/">Home</Link>
                    </li>
                    <li>
                        <Link to="/chat">Chat</Link>
                    </li>
                    <li>
                        <Link to="/editor">Editor</Link>
                    </li>
                    <li>
                        <button
                            type="button"
                            className="theme-toggle"
                            onClick={toggleTheme}
                            aria-label="Toggle dark and light theme"
                            title={theme === 'light' ? 'Switch to dark mode' : 'Switch to light mode'}
                        >
                            {theme === 'light' ? '🌙' : '☀️'}
                        </button>
                    </li>
                </ul>
            </nav>
        </header>
    );
};

export default Navbar;