const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const fetch = require('node-fetch');
require('dotenv').config(); // Load environment variables

const app = express();
const PORT = process.env.PORT || 5000; // Use environment variable or fallback to 5000

app.use(cors());
app.use(bodyParser.json());

app.post('/api/chat', async (req, res) => {
    const { input } = req.body;

    try {
        const response = await fetch('https://api.openai.com/v1/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${process.env.OPENAI_API_KEY}`, // Use environment variable for API key
            },
            body: JSON.stringify({
                model: 'gpt-3.5-turbo', // Replace with your preferred model
                prompt: input,
                max_tokens: 150,
            }),
        });

        const data = await response.json();

        if (data.error) {
            return res.status(400).json({ error: data.error.message });
        }

        res.json({ response: data.choices[0].text.trim() });
    } catch (error) {
        console.error('Error communicating with OpenAI:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
