const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Hello from BLUE'));
const port = process.env.PORT || 3000;
app.listen(port, ()=> console.log(`Blue on ${port}`));
app.get('/health', (req, res) => res.json({ status: 'ok' }));

