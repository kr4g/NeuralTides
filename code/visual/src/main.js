// src/main.js
import { initScene, scene, renderer, camera } from './scene/setup.js';
import { initBorder } from './scene/border.js';
import { initCursor } from './scene/cursor.js';
import { loadDataset } from './data/loader.js';
import { initWebSocket } from './utils/websocket.js';
import { updateCameraForSquare } from './scene/setup.js';
import { materials } from './config/materials.js';
import { DATASET_CONFIGS, RESET_TIME, CYCLE_TIME, TRANSITION_SPEED } from './config/constants.js';

// Initialize core components
initScene();
initBorder();
initCursor();
initWebSocket();

let datasetsLoaded = 0;
const totalDatasets = DATASET_CONFIGS.length;

// Start loading datasets
for (let i = 0; i < totalDatasets; i++) {
    let variant = DATASET_CONFIGS[i].variants[Math.floor(Math.random() * DATASET_CONFIGS[i].variants.length)];
    loadDataset(i, variant).then(() => {
        datasetsLoaded++;
        if (datasetsLoaded === totalDatasets) {
            animate();
        }
    });
}

// Handle window resize
window.addEventListener('resize', updateCameraForSquare);
updateCameraForSquare();

// Animation loop
const startTime = Math.random() * CYCLE_TIME;

function animate() {
    requestAnimationFrame(animate);
    const trueTime = performance.now() * 0.001 + startTime;
    const normalizedTime = trueTime % CYCLE_TIME;
    const time = normalizedTime <= RESET_TIME ? normalizedTime : CYCLE_TIME - normalizedTime;

    materials.forEach(material => {
        material.uniforms.time.value = time;
        
        for (let i = 0; i < material.uniforms.clusterRanges.value.length; i++) {
            const current = material.uniforms.clusterRanges.value[i];
            const target = material.uniforms.targetClusterRanges.value[i];
        
            current.x += (target.x - current.x) * TRANSITION_SPEED;
            current.y += (target.y - current.y) * TRANSITION_SPEED;
        }
    });        
    renderer.render(scene, camera);
}

export { animate };