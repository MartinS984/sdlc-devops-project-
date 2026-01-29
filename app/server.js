const express = require('express');
const client = require('prom-client'); // Import the Prometheus library

const app = express();
const port = 3000;

// Create a Registry to collect metrics
const register = new client.Registry();

// Add default metrics (like Node.js memory usage, CPU, etc.)
client.collectDefaultMetrics({ register });

// Create a custom counter metric
const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status'],
});

// Register the counter
register.registerMetric(httpRequestCounter);

app.get('/', (req, res) => {
  // Increment the counter every time someone hits home
  httpRequestCounter.inc({ method: 'GET', route: '/', status: '200' });
  res.send('Hello! Welcome to the DevOps Masterclass v2.0 (Monitored)');
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Expose the metrics for Prometheus to "scrape"
app.get('/metrics', async (req, res) => {
  res.setHeader('Content-Type', register.contentType);
  res.send(await register.metrics());
});

app.listen(port, () => {
  console.log(`App running on port ${port}`);
});