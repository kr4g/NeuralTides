require('dotenv').config();
const WebSocket = require('ws');
const osc = require('node-osc');

const WS_PORT = process.env.WS_PORT || 7400;
const OSC_PORT = process.env.OSC_PORT || 7400;
const OSC_HOST = process.env.OSC_HOST || '127.0.0.1';

const wss = new WebSocket.Server({ port: WS_PORT });
const oscServer = new osc.Server(OSC_PORT, OSC_HOST);

oscServer.on('message', function(msg) {
    wss.clients.forEach(function(client) {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(msg));
        }
    });
});