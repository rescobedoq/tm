shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// Color y tamaño del aura
uniform vec4 aura_color = vec4(1.0, 0.8, 0.2, 0.1); // Color de la nube
uniform float aura_radius = 2.0;                     // Escala base del aura
uniform float glow_softness = 0.0001;                  // Difuminado radial
uniform float noise_scale = 1.0;                    // Escala del ruido
uniform float noise_strength = 0.6;                 // Intensidad del patrón irregular
uniform float pulse_speed = 0.5;                    // Velocidad del pulso
uniform float pulse_strength = 0.2;                 // Intensidad del pulso (expansión)

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void vertex() {
    // Escala base + pequeño pulso para breathing
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
    VERTEX *= aura_radius * pulse;
}

void fragment() {
    vec2 uv = UV;

    // Distancia radial desde el centro
    float dist = length(uv - vec2(0.5));

    // Ruido para borde irregular
    float n = rand(uv * noise_scale);

    // Alpha difuminado con borde suave y patrón irregular
    float alpha = smoothstep(glow_softness + n*noise_strength, 0.0, dist);

    ALBEDO = aura_color.rgb;
    ALPHA = alpha * aura_color.a;
}
