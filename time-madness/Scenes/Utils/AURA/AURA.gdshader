shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// Color y tamaño del aura
uniform vec4 aura_color = vec4(1.0, 0.2, 0.0, 0.3); // Color rojo-naranja
uniform float aura_radius = 10.0;                     // Escala base del aura
uniform float glow_intensity = 0.5;                  // Intensidad del brillo central
uniform float glow_falloff = 1.5;                    // Qué tan rápido decae el brillo
uniform float center_brightness = 3.0;               // Brillo extra en el centro
uniform float pulse_speed = 4;                     // Velocidad del pulso
uniform float pulse_strength = 0.02;                  // Intensidad del pulso (expansión)

void vertex() {
    // Escala base + pequeño pulso para breathing
    float pulse = 1.0 + sin(TIME * pulse_speed) * pulse_strength;
    VERTEX *= aura_radius * pulse;
}

void fragment() {
    vec2 uv = UV;
    
    // Distancia radial desde el centro (0.0 en centro, 0.5 en borde)
    float dist = length(uv - vec2(0.5)) * 2.0;
    
    // Gradiente radial suave con falloff exponencial
    float radial_gradient = exp(-dist * glow_falloff) * glow_intensity;
    
    // Brillo extra en el centro
    float center_glow = exp(-dist * (glow_falloff * 2.0)) * center_brightness;
    
    // Combinar ambos efectos
    float brightness = radial_gradient + center_glow;
    
    // Alpha basado en el brillo (más suave en los bordes)
    float alpha = smoothstep(0.0, 0.3, brightness);
    
    ALBEDO = aura_color. rgb * brightness;
    ALPHA = alpha * aura_color.a;
}