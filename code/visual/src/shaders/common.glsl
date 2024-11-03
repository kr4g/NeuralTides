// shaders/common.glsl
const float PI = 3.14159265359;
const float TWO_PI = PI * 2.0;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float perlin(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f*f*(3.0-2.0*f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float noise1(float t) {
    return fract(sin(t * 78.233) * 43758.5453123);
}

float noise(float t) {
    float i = floor(t);
    float f = fract(t);
    return mix(noise1(i), noise1(i + 1.0), smoothstep(0.0, 1.0, f));
}