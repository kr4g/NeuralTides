// src/config/materials.js
import * as THREE from 'three';
import { SPRITE_CONFIG } from './constants.js';

export const materials = [];

// Create sprite texture
const canvas = document.createElement('canvas');
canvas.width = SPRITE_CONFIG.width;
canvas.height = SPRITE_CONFIG.height;
const ctx = canvas.getContext('2d');
const gradient = ctx.createRadialGradient(
    canvas.width/2, 
    canvas.height/2, 
    0, 
    canvas.width/2, 
    canvas.height/2, 
    canvas.width/4
);

SPRITE_CONFIG.gradient.stops.forEach(stop => {
    gradient.addColorStop(stop.position, stop.color);
});

ctx.fillStyle = gradient;
ctx.fillRect(0, 0, canvas.width, canvas.height);
export const sprite = new THREE.Texture(canvas);
sprite.needsUpdate = true;

async function loadShaders(numClusters) {
    const [commonGLSL, vertexGLSL, fragmentGLSL] = await Promise.all([
        fetch('./src/shaders/common.glsl').then(r => r.text()),
        fetch('./src/shaders/vertex.glsl').then(r => r.text()),
        fetch('./src/shaders/fragment.glsl').then(r => r.text())
    ]);

    const processedVertexShader = vertexGLSL
        .replace(/NUM_CLUSTERS/g, numClusters.toString())
        .replace('#include common.glsl', commonGLSL);

    return {
        vertexShader: processedVertexShader,
        fragmentShader: fragmentGLSL
    };
}

function createMaterial(numClusters, layerParams, clusterParams) {
    return new THREE.ShaderMaterial({
        uniforms: {
            time: { value: 0 },
            sprite: { value: sprite },
            layerLfo: { value: layerParams },
            clusterLfo: { value: clusterParams },
            layerRanges: { value: new THREE.Vector2(0.2, 1.0) },
            clusterRanges: { value: Array(numClusters)
                .fill()
                .map(() => new THREE.Vector2(0.067, 0.8))
            },
            targetClusterRanges: { value: Array(numClusters)
                .fill()
                .map(() => new THREE.Vector2(0.03, 0.8))
            },
            highlightLayer: { value: -1 },
            highlightPointId: { value: -1 }
        },
        transparent: true,
        depthWrite: false,
        blending: THREE.AdditiveBlending
    });
}

async function createShaderMaterial(numClusters, layerParams, clusterParams) {
    const shaders = await loadShaders(numClusters);
    const material = createMaterial(numClusters, layerParams, clusterParams);
    material.vertexShader = shaders.vertexShader;
    material.fragmentShader = shaders.fragmentShader;
    materials.push(material);
    return material;
}

export {
    loadShaders,
    createShaderMaterial
};