// src/utils/websocket.js
import { positionCursor, hideCursor } from '../scene/cursor.js';
import { materials } from '../config/materials.js';
import { WS_RECEIVE_URL, HIGHLIGHT_TIMEOUT } from '../config/constants.js';
import { reloadLayerVariant } from '../data/loader.js';

let wsSend;
let wsReceive;
let globalHighlightTimeout = null;

function resetAllHighlights() {
    Object.values(materials).forEach(material => {
        material.uniforms.highlightPointId.value = -1;
        material.uniforms.highlightLayer.value = -1;
        for (let i = 0; i < material.uniforms.targetClusterRanges.value.length; i++) {
            material.uniforms.targetClusterRanges.value[i].set(0.067, 0.8);
        }
    });
    hideCursor();
}

function handleLayerMessage(layerId, size) {
    if (layerId >= 0 && layerId < Object.keys(materials).length) {
        materials[layerId].uniforms.layerSize.value = size;
    }
}

function handleClusterMessage(layerId, clusterId, minRange, maxRange) {
    if (layerId >= 0 && layerId < materials.length) {
        const material = materials[layerId];
        if (clusterId < material.uniforms.clusterRanges.value.length) {
            material.uniforms.clusterRanges.value[clusterId].set(minRange, maxRange);
        }
    }
}

function handleClustersMessage(layerId, minRange, maxRange) {
    if (layerId >= 0 && layerId < Object.keys(materials).length) {
        const material = materials[layerId];
        for (let i = 0; i < material.uniforms.clusterRanges.value.length; i++) {
            material.uniforms.targetClusterRanges.value[i].set(minRange, maxRange);
        }
    }
}

function handleHighlightMessage(layerId, pointId, clusterId) {
    if (globalHighlightTimeout) {
        clearTimeout(globalHighlightTimeout);
    }

    globalHighlightTimeout = setTimeout(resetAllHighlights, HIGHLIGHT_TIMEOUT);
    
    if (layerId >= 0 && layerId < Object.keys(materials).length) {
        const material = materials[layerId];
        material.uniforms.highlightPointId.value = pointId;
        material.uniforms.highlightLayer.value = pointId >= 0 ? layerId : -1;
        
        for (let i = 0; i < material.uniforms.targetClusterRanges.value.length; i++) {
            if (i == clusterId && pointId >= 0) {
                material.uniforms.targetClusterRanges.value[i].set(0.9, 1.0);
            } else {
                material.uniforms.targetClusterRanges.value[i].set(0.0, 0.2);
            }
        }
    } else if (pointId < 0) {
        resetAllHighlights();
        if (globalHighlightTimeout) {
            clearTimeout(globalHighlightTimeout);
            globalHighlightTimeout = null;
        }
    }
}

function initWebSocket() {
    wsReceive = new WebSocket(WS_RECEIVE_URL);
    // wsSend = new WebSocket(WS_SEND_URL);
    // wsSend = new Client('127.0.0.1', 57120);
    
    wsReceive.onmessage = function(event) {
        const msg = JSON.parse(event.data);
        const address = msg[0];
        
        switch(address) {
            case '/layer':
                handleLayerMessage(msg[1] - 1, msg[2]);
                break;
                
            case '/cluster':
                handleClusterMessage(msg[1] - 1, msg[2], msg[3], msg[4]);
                break;
                
            case '/clusters':
                handleClustersMessage(msg[1] - 1, msg[2], msg[3]);
                break;
                
            case '/highlight':
                handleHighlightMessage(msg[1] - 1, msg[2], msg[3]);
                break;
                
            case '/reload':
                handleClusterMessage(msg[1] - 1, msg[2], 0.0);
                reloadLayerVariant(msg[1] - 1, msg[2]);
                break;
                
            case '/pos':
                positionCursor(msg[1], msg[2]);
                break;
        }
    };

    return wsReceive;
}

export {
    initWebSocket,
    resetAllHighlights
};