// src/scene/border.js
import * as THREE from 'three';
import { scene } from './setup.js';
import { PLOT_SIZE, BORDER_CONFIG } from '../config/constants.js';

let plotBorder;

function initBorder() {
    const borderThickness = 0.005;

    const borderMaterial = new THREE.MeshBasicMaterial({ 
        color: 0xffffff // White color
    });

    // Create four planes to form a border
    const topBorder = new THREE.Mesh(
        new THREE.PlaneGeometry(PLOT_SIZE + 2 * borderThickness, borderThickness),
        borderMaterial
    );
    topBorder.position.set(0, PLOT_SIZE / 2 + borderThickness / 2, BORDER_CONFIG.z);

    const bottomBorder = new THREE.Mesh(
        new THREE.PlaneGeometry(PLOT_SIZE + 2 * borderThickness, borderThickness),
        borderMaterial
    );
    bottomBorder.position.set(0, -PLOT_SIZE / 2 - borderThickness / 2, BORDER_CONFIG.z);

    const leftBorder = new THREE.Mesh(
        new THREE.PlaneGeometry(borderThickness, PLOT_SIZE),
        borderMaterial
    );
    leftBorder.position.set(-PLOT_SIZE / 2 - borderThickness / 2, 0, BORDER_CONFIG.z);

    const rightBorder = new THREE.Mesh(
        new THREE.PlaneGeometry(borderThickness, PLOT_SIZE),
        borderMaterial
    );
    rightBorder.position.set(PLOT_SIZE / 2 + borderThickness / 2, 0, BORDER_CONFIG.z);

    // Add borders to the scene
    scene.add(topBorder);
    scene.add(bottomBorder);
    scene.add(leftBorder);
    scene.add(rightBorder);

    plotBorder = [topBorder, bottomBorder, leftBorder, rightBorder];
    
    return plotBorder;
}

function getBorder() {
    return plotBorder;
}

export {
    initBorder,
    getBorder
};