// src/data/loader.js
import * as THREE from 'three';
import { scene } from '../scene/setup.js';
import { DATASET_CONFIGS, PLOT_SIZE } from '../config/constants.js';
import { createShaderMaterial } from '../config/materials.js';
import { generateClusterParams } from '../utils/coordinates.js';

export const clusterCounts = new Array(DATASET_CONFIGS.length).fill(0);

async function loadDataset(index, variant, initSize) {
    const config = DATASET_CONFIGS[index];
    if (!config) {
        console.warn(`No dataset config found for index ${index}`);
        return;
    }
    
    try {
        const [posData, labelData, clusterData] = await Promise.all([
            fetch(`/data/json/${config.layer}/umap_norm_${config.layer}${variant}.json`).then(r => r.json()),
            fetch(`/data/json/${config.layer}/labels_${config.layer}${variant}.json`).then(r => r.json()),
            fetch(`/data/json/${config.layer}/km_clusters_${config.layer}${variant}.json`).then(r => r.json())
        ]);

        clusterCounts[index] = clusterData.rows;

        const geometry = new THREE.BufferGeometry();
        const positions = [];
        const colors = [];
        const layerIds = [];
        const clusterIds = [];
        const pointIds = [];

        const points = Object.values(posData.data);
        const [minX, maxX] = [Math.min(...points.map(p => p[0])), Math.max(...points.map(p => p[0]))];
        const [minY, maxY] = [Math.min(...points.map(p => p[1])), Math.max(...points.map(p => p[1]))];
        
        const scale = Math.min(PLOT_SIZE / (maxX - minX), PLOT_SIZE / (maxY - minY));
        const centerX = (minX + maxX) / 2;
        const centerY = (minY + maxY) / 2;

        Object.keys(posData.data).forEach((key) => {
            const point = posData.data[key];
            const cluster = labelData.data[key][0];
            positions.push(
                (point[0] - centerX) * scale, 
                (point[1] - centerY) * scale, 
                0
            );
            colors.push(...config.baseColor);
            layerIds.push(index);
            clusterIds.push(cluster);
            pointIds.push(parseInt(key));
        });
        
        geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
        geometry.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));
        geometry.setAttribute('layerId', new THREE.Float32BufferAttribute(layerIds, 1));
        geometry.setAttribute('clusterId', new THREE.Float32BufferAttribute(clusterIds, 1));
        geometry.setAttribute('pointId', new THREE.Float32BufferAttribute(pointIds, 1));

        const clusterParams = Array(clusterData.rows).fill().map(() => generateClusterParams());
        
        const material = await createShaderMaterial(
            clusterData.rows,
            clusterParams,
            index, 
            variant,
            initSize
        );

        const pointCloud = new THREE.Points(geometry, material);
        scene.add(pointCloud);

    } catch (error) {
        console.error(`Error loading dataset ${index}:`, error);
    }

    return Promise.resolve();
}

export async function reloadLayerVariant(index, variant) {
    // Remove existing point cloud for this layer
    scene.children = scene.children.filter(child => {
        const isPointCloud = child instanceof THREE.Points;
        const hasLayerId = isPointCloud && child.geometry.attributes.layerId;
        const matchesIndex = hasLayerId && child.geometry.attributes.layerId.array[0] === index;
        if (isPointCloud && matchesIndex) {
            child.geometry.dispose();
            child.material.dispose();
        }
        return !(isPointCloud && matchesIndex);
    });

    // console.log(`Reloading layer ${index + 1} with variant ${variant}`);

    await loadDataset(index, variant, 0.0);
}

export { loadDataset };