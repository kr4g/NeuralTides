// src/scene/setup.js
import * as THREE from 'three';
import { PLOT_HALF_SIZE, VIEWPORT_SCALE } from '../config/constants.js';

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x000000);

// Create camera with initial parameters - we'll update these in resize
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.1, 1000);
camera.position.z = 1;

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);

function initScene() {
    document.body.appendChild(renderer.domElement);
}

function updateCameraForSquare() {
    const aspect = window.innerWidth / window.innerHeight;
    
    if (aspect > 1) {
        // Window is wider than tall - constrain by height
        const height = PLOT_HALF_SIZE / VIEWPORT_SCALE;
        const width = height * aspect;
        camera.left = -width;
        camera.right = width;
        camera.top = height;
        camera.bottom = -height;
    } else {
        // Window is taller than wide - constrain by width
        const width = PLOT_HALF_SIZE / VIEWPORT_SCALE;
        const height = width / aspect;
        camera.left = -width;
        camera.right = width;
        camera.top = height;
        camera.bottom = -height;
    }
    
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function getBoxBounds() {
    const size = Math.min(window.innerWidth, window.innerHeight);
    const left = (window.innerWidth - size) / 2;
    const top = (window.innerHeight - size) / 2;
    
    return {
        left: left,
        right: left + size,
        top: top,
        bottom: top + size,
        size: size
    };
}

export { 
    scene, 
    camera, 
    renderer, 
    initScene, 
    updateCameraForSquare,
    getBoxBounds 
};