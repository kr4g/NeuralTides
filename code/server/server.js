// require('dotenv').config();
const WebSocket = require('ws');
const osc = require('node-osc');

const WS_PORT = process.env.WS_PORT || 7400;
const OSC_PORT = process.env.OSC_PORT || 7400;
const OSC_HOST = process.env.OSC_HOST || '127.0.0.1';

const wss = new WebSocket.Server({ port: WS_PORT });
const oscServer = new osc.Server(OSC_PORT, OSC_HOST);
const oscClient = new osc.Client('127.0.0.1', 57120);

oscServer.on('message', function(msg) {
    wss.clients.forEach(function(client) {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(msg));
        }
    });
});

wss.on('connection', function connection(ws) {
    console.log('Browser connected');
    
    ws.on('message', function incoming(message) {
        try {
            const data = JSON.parse(message);
            console.log('Forwarding to SC:', data);
            oscClient.send(...data);
        } catch (error) {
            console.error('Error handling message:', error);
        }
    });
});