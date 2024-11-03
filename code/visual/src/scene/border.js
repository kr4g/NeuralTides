// src/scene/border.js
import * as THREE from 'three';
import { scene } from './setup.js';
import { PLOT_SIZE, BORDER_CONFIG } from '../config/constants.js';

let plotBorder;

function initBorder() {
    const borderGeometry = new THREE.EdgesGeometry(
        new THREE.PlaneGeometry(PLOT_SIZE, PLOT_SIZE)
    );
    
    const borderMaterial = new THREE.LineBasicMaterial({ 
        color: BORDER_CONFIG.color, 
        linewidth: BORDER_CONFIG.linewidth 
    });
    
    plotBorder = new THREE.LineSegments(borderGeometry, borderMaterial);
    plotBorder.position.z = BORDER_CONFIG.z;
    scene.add(plotBorder);
    
    return plotBorder;
}

function getBorder() {
    return plotBorder;
}

export {
    initBorder,
    getBorder
};