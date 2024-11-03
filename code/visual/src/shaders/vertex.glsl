// shaders/vertex.glsl
#include common.glsl

attribute vec3 color;
attribute float layerId;
attribute float clusterId;
attribute float pointId;

uniform float time;
uniform vec4 layerLfo;
uniform vec4 clusterLfo[NUM_CLUSTERS];
uniform vec2 layerRanges;
uniform vec2 clusterRanges[NUM_CLUSTERS];
uniform float highlightLayer;
uniform float highlightPointId;

varying vec3 vColor;
varying float vBrightness;
varying float vHighlight;
varying float vTime;

float layerLfoFunc(vec4 params, vec2 range, float t) {
    float noiseFreq = params.x;
    float phase = params.y * perlin(vec2(-position.y, -position.x));
    float minFreq = params.z;
    float maxFreq = params.w;
    
    float freqMod = noise(t * noiseFreq);
    float freq = mix(minFreq, maxFreq, freqMod);
    float angle = t * freq + phase;
    float v = sin(angle) * 0.5 + 0.5;

    float randomVal = perlin(vec2(position.x, position.y) / pointId);
    float exp = randomVal * 1.5 + 0.5;
    v = pow(v, exp);
    
    return mix(range.x, range.y, v);
}

float clusterLfoFunc(vec4 params, vec2 range, float t) {
    float baseFreq = params.x;
    float phase = params.y;
    float minFreq = params.z;
    float maxFreq = params.w;
    
    float angle = t * baseFreq + phase;
    float freqMod = sin(angle) * 0.5 + 0.5;
    float noiseFreq = mix(minFreq, maxFreq, freqMod);
    float v = noise(t * noiseFreq);

    float randomVal = perlin(vec2(position.y, position.x) * pointId);
    float exp = randomVal * 1.5 + 0.5;
    v = pow(v, exp);
    
    return mix(range.x, range.y, v);
}

void main() {
    vTime = time;
    vColor = color;
    int cid = int(clusterId);
    
    float size = layerLfoFunc(layerLfo, layerRanges, time);
    vBrightness = clusterLfoFunc(clusterLfo[cid], clusterRanges[cid], time);
    vHighlight = (layerId == highlightLayer && pointId == highlightPointId) ? 1.0 : 0.0;

    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    gl_PointSize = size * (vHighlight > 0.0 ? 35.0 : 15.0) / -mvPosition.z;
    gl_Position = projectionMatrix * mvPosition;
}