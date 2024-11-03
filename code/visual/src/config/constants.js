// src/config/constants.js
export const PLOT_HALF_SIZE = 1;
export const PLOT_SIZE = PLOT_HALF_SIZE * 2;
export const VIEWPORT_SCALE = 0.9;

export const HIGHLIGHT_TIMEOUT = 5000;
export const TRANSITION_SPEED = 0.1;
export const RESET_TIME = 100.0;
export const CYCLE_TIME = RESET_TIME * 2;

export const DATASET_CONFIGS = [
    { layer: 1, variants: ['a'], baseColor: [0.1, 0.1, 0.8] },
    { layer: 2, variants: ['a'], baseColor: [0.1, 0.8, 0.1] },
    { layer: 3, variants: ['a'], baseColor: [0.8, 0.1, 0.1] },
    { layer: 4, variants: ['a'], baseColor: [0.8, 0.8, 0.1] }
];

export const CURSOR_CONFIG = {
    radius: 0.1,
    segments: 32,
    color: 0x808080,
    opacity: 0.5
};

export const BORDER_CONFIG = {
    color: 0xffffff,
    linewidth: 2,
    z: 0.01
};

// WebSocket configuration
export const WS_URL = 'ws://localhost:7400';

// Sprite configuration
export const SPRITE_CONFIG = {
    width: 128,
    height: 128,
    gradient: {
        stops: [
            { position: 0, color: 'rgba(255, 255, 255, 1)' },
            { position: 0.8, color: 'rgba(255, 255, 255, 0.8)' },
            { position: 1, color: 'rgba(255, 255, 255, 0)' }
        ]
    }
};