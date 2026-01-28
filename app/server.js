const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello! Welcome to the DevOps Masterclass v1.0');
});

// Health check endpoint for K8s
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});