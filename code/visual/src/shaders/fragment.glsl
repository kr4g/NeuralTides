// shaders/fragment.glsl
uniform sampler2D sprite;
varying vec3 vColor;
varying float vBrightness;
varying float vHighlight;
varying float vTime;

void main() {
    vec4 tex = texture2D(sprite, gl_PointCoord);
    float highlightGlow = vHighlight * (1.0 + 0.5 * sin(gl_PointCoord.x * 3.14159 + gl_PointCoord.y * 3.14159));
    
    float highlightBoost = vHighlight * (1.5 + 0.5 * sin(vTime * 3.0));
    vec3 finalColor = mix(vColor, vec3(1.0), vBrightness * (0.25 + highlightBoost));
    
    if (vHighlight > 0.0) {
        finalColor = mix(finalColor, vec3(1.0), highlightGlow * 0.5);
        float glowAlpha = smoothstep(0.0, 0.5, tex.a);
        gl_FragColor = vec4(finalColor, glowAlpha * (vBrightness + highlightGlow));
    } else {
        gl_FragColor = vec4(finalColor, tex.a * vBrightness);
    }
}