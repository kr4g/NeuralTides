// src/scene/cursor.js
import * as THREE from 'three';
import { scene } from './setup.js';
import { CURSOR_CONFIG, PLOT_SIZE } from '../config/constants.js';

let mouseCursor;

function initCursor() {
    const cursorGeometry = new THREE.CircleGeometry(
        CURSOR_CONFIG.radius, 
        CURSOR_CONFIG.segments
    );
    
    const cursorMaterial = new THREE.MeshBasicMaterial({
        color: CURSOR_CONFIG.color,
        transparent: true,
        opacity: CURSOR_CONFIG.opacity,
        depthTest: false,
        side: THREE.DoubleSide
    });

    mouseCursor = new THREE.Mesh(cursorGeometry, cursorMaterial);
    mouseCursor.visible = false;
    scene.add(mouseCursor);
}

function positionCursor(x, y) {
    const worldX = (x * PLOT_SIZE) - PLOT_SIZE/2;
    const worldY = (y * PLOT_SIZE) - PLOT_SIZE/2;
    mouseCursor.position.x = worldX;
    mouseCursor.position.y = worldY;
    mouseCursor.visible = true;
}

function hideCursor() {
    mouseCursor.visible = false;
}

function getCursor() {
    return mouseCursor;
}

export {
    initCursor,
    positionCursor,
    hideCursor,
    getCursor
};