shader_type spatial;
render_mode specular_schlick_ggx, blend_mix, depth_draw_opaque, cull_back;

uniform vec3 shallow_color : source_color = vec3(0.05, 0.25, 0.35);
uniform vec3 deep_color : source_color = vec3(0.0, 0.07, 0.12);
uniform float depth_strength : hint_range(0.0, 5.0) = 1.5;

uniform vec3 albedo : source_color = vec3(0.03, 0.12, 0.2);
uniform float metallic : hint_range(0.0, 1.0) = 0.2;
uniform float roughness : hint_range(0.0, 1.0) = 0.03;
uniform float specular : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;

// DIRECCIÓN + AMPLITUD MUCHO MAYOR
uniform vec2 wave_direction = vec2(3.5, 1.5);
uniform vec2 wave_direction2 = vec2(-2.0, 1.0);

// VELOCIDAD MÁS ALTA
uniform float wave_speed = 0.6;

// ESCALA DEL TIEMPO MÁS GRANDE
uniform float time_scale = 0.06;

// MEZCLA DE NORMALES MÁS MARCADA
uniform float normal_mix = 0.7;

// DISTORSIÓN MUCHO MÁS INTENSA
uniform float distortion_amount = 0.045;

// Fresnel más suave y visible
uniform float fresnel_power = 4.0;
uniform float fresnel_strength = 0.35;

// ===== PARÁMETROS DE BORDES ANIMADOS =====
uniform float edge_wave_scale : hint_range(0.5, 5.0) = 2.0;
uniform float edge_wave_amount : hint_range(0.0, 0.3) = 0.12;
uniform float edge_threshold : hint_range(0.0, 1.0) = 0.85;
uniform float edge_softness : hint_range(0.0, 0.5) = 0.15;

// --------------------------------------------------
vec3 blend_rnm(vec3 n1, vec3 n2) {
    n1 = n1 * 2.0 - 1.0;
    n2 = n2 * 2.0 - 1.0;
    vec3 t = vec3(n1.xy + n2.xy, n1. z * n2.z);
    return normalize(vec3(t.xy, t.z));
}

// Función para calcular bordes con ondas animadas
float edge_mask_with_waves(vec2 uv, float time_offset) {
    vec2 center = uv - 0.5;
    float dist = length(center) * 2.0;
    
    // Generar olas en los bordes usando las mismas texturas de normales
    vec2 edge_uv1 = uv * edge_wave_scale + wave_direction * time_offset * wave_speed * time_scale;
    vec2 edge_uv2 = uv * edge_wave_scale * 1.3 + wave_direction2 * time_offset * wave_speed * time_scale;
    
    float wave1 = texture(texture_normal, edge_uv1).r;
    float wave2 = texture(texture_normal2, edge_uv2).r;
    
    // Combinar las olas
    float wave_offset = (wave1 + wave2 - 1.0) * edge_wave_amount;
    
    return dist + wave_offset;
}

void fragment() {
    // ===== CÁLCULO DE BORDES CON OLAS ANIMADAS =====
    float edge_dist = edge_mask_with_waves(UV, TIME);
    
    // Crear alpha suavizado con las olas
    float alpha = 1.0 - smoothstep(edge_threshold - edge_softness, edge_threshold + edge_softness, edge_dist);
    
    // ===== SHADER DE AGUA ORIGINAL =====
    // Movimiento más fuerte
    vec2 t1 = UV * 1.2 + wave_direction * TIME * wave_speed * time_scale;
    vec2 t2 = UV * 1.3 + wave_direction2 * TIME * wave_speed * time_scale;

    // Distorsión fuerte y clara
    vec2 distortion = (texture(texture_normal, UV * 1.5). rg - 0.5) * distortion_amount;

    vec3 n1 = texture(texture_normal, t1 + distortion).rgb;
    vec3 n2 = texture(texture_normal2, t2 - distortion).rgb;

    // Mezcla más marcada
    vec3 normal_final = blend_rnm(n1, n2);
    normal_final = normalize(mix(n1, normal_final, normal_mix));

    // Fresnel
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power) * fresnel_strength;

    // Profundidad falsa
    float depth_factor = clamp(dot(NORMAL, VIEW) * depth_strength, 0.0, 1.0);
    vec3 depth_color = mix(deep_color, shallow_color, depth_factor);

    ALBEDO = mix(depth_color, albedo, fresnel);

    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = specular;

    NORMAL_MAP = normal_final;
    
    // ===== APLICAR TRANSPARENCIA EN BORDES CON OLAS =====
    ALPHA = alpha;
}