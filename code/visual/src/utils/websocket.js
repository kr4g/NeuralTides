// src/utils/websocket.js
import { positionCursor, hideCursor } from '../scene/cursor.js';
import { materials } from '../config/materials.js';
import { WS_URL, HIGHLIGHT_TIMEOUT } from '../config/constants.js';
import { reloadLayerVariant } from '../data/loader.js';

let ws;
let globalHighlightTimeout = null;

function resetAllHighlights() {
    materials.forEach(material => {
        material.uniforms.highlightPointId.value = -1;
        material.uniforms.highlightLayer.value = -1;
        for (let i = 0; i < material.uniforms.targetClusterRanges.value.length; i++) {
            material.uniforms.targetClusterRanges.value[i].set(0.067, 0.8);
        }
    });
    hideCursor();
}

function handleLayerMessage(layerId, size) {
    if (layerId >= 0 && layerId < materials.length) {
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

function handleHighlightMessage(layerId, pointId, clusterId) {
    if (globalHighlightTimeout) {
        clearTimeout(globalHighlightTimeout);
    }
    
    globalHighlightTimeout = setTimeout(resetAllHighlights, HIGHLIGHT_TIMEOUT);
    
    if (layerId >= 0 && layerId < materials.length) {
        const material = materials[layerId];
        material.uniforms.highlightPointId.value = pointId;
        material.uniforms.highlightLayer.value = pointId >= 0 ? layerId : -1;
        
        for (let i = 0; i < material.uniforms.targetClusterRanges.value.length; i++) {
            if (i == clusterId && pointId >= 0) {
                material.uniforms.targetClusterRanges.value[i].set(0.9, 1.0);
            } else {
                material.uniforms.targetClusterRanges.value[i].set(0.01, 0.2);
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
    ws = new WebSocket(WS_URL);
    
    ws.onmessage = function(event) {
        const msg = JSON.parse(event.data);
        const address = msg[0];
        
        switch(address) {
            case '/layer':
                handleLayerMessage(msg[1] - 1, msg[2]);
                break;
                
            case '/cluster':
                handleClusterMessage(msg[1] - 1, msg[2], msg[3], msg[4]);
                break;
                
            case '/highlight':
                handleHighlightMessage(msg[1] - 1, msg[2], msg[3]);
                break;
                
            case '/reload':
                reloadLayerVariant(msg[1] - 1, msg[2]);
                break;
                
            case '/pos':
                positionCursor(msg[1], msg[2]);
                break;
        }
    };

    return ws;
}

export {
    initWebSocket,
    resetAllHighlights
};