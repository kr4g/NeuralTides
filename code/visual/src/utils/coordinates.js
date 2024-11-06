// src/utils/coordinates.js
import * as THREE from 'three';
import { PLOT_SIZE } from '../config/constants.js';

function worldToUnitCoords(x, y) {
    // Convert from centered coordinates (-1 to 1) to unit coordinates (0 to 1)
    const unitX = (x + PLOT_SIZE/2) / PLOT_SIZE;
    const unitY = (y + PLOT_SIZE/2) / PLOT_SIZE;
    return { x: unitX, y: unitY };
}

function generateRandomPhase() {
    return Math.random() * Math.PI * 2;
}

// function generateLayerParams() {
//     return new THREE.Vector4(
//         0.02 + Math.random() * 0.005, // inner LFO freq
//         generateRandomPhase(),
//         0.125/8,    // outer LFO min freq
//         0.25        // outer LFO max freq
//     );
// }

function generateClusterParams() {
    return new THREE.Vector4(
        0.08 + Math.random() * 0.13,
        generateRandomPhase(),
        0.067,
        0.667
    );
}

export {
    worldToUnitCoords,
    generateRandomPhase,
    generateClusterParams
};