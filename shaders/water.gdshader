shader_type spatial;

// Pass data from vertex to fragment 
varying float v_dist;
varying float v_wave_height;
varying float v_steepness;

uniform sampler2D normal_map_1 : hint_normal;
uniform sampler2D normal_map_2 : hint_normal;

// uniforms to change the water color dynamically (e.g. past, present)
// regular water colors
//uniform vec3 color_deep : source_color = vec3(0.01, 0.03, 0.08);
//uniform vec3 color_shallow : source_color = vec3(0.0, 0.3, 0.4);

// cloudy colors
uniform vec3 color_deep : source_color = vec3(0.05, 0.07, 0.09);
uniform vec3 color_shallow : source_color = vec3(0.15, 0.18, 0.20);

// night sky colors
//uniform vec3 color_deep : source_color = vec3(0.005, 0.01, 0.015);
//uniform vec3 color_shallow : source_color = vec3(0.02, 0.04, 0.06);


void gerstner_wave(vec4 wave, vec3 p, inout vec3 displacement, inout vec3 normal) {
    float steepness = wave.z;
    float wavelength = wave.w;
    
    float k = 2.0 * PI / wavelength;
    float c = sqrt(9.8 / k);
    vec2 d = normalize(wave.xy); 
    
    float f = k * (dot(d, p.xz) - c * TIME);
    float a = steepness / k; 

    displacement.x += d.x * (a * cos(f));
    displacement.y += a * sin(f);
    displacement.z += d.y * (a * cos(f));

    normal.x -= d.x * steepness * cos(f);
    normal.y -= steepness * sin(f);
    normal.z -= d.y * steepness * cos(f);
}

void vertex() {
	//vec4 wave_a = vec4(1.0, 0.5, 0.15, 60.0);
    //vec4 wave_b = vec4(0.8, -0.6, 0.2, 31.0); 
    //vec4 wave_c = vec4(-0.2, 0.9, 0.3, 13.0);
    //vec4 wave_d = vec4(0.4, -0.1, 0.4, 5.0);
	
    vec4 wave_a = vec4(1.0, 0.5, 0.15, 26.0);
    vec4 wave_b = vec4(3.8, -0.6, 0.1, 34.0); 
    vec4 wave_c = vec4(-0.2, 1.9, 0.1, 29.0);
    vec4 wave_d = vec4(-0.4, -0.1, 0.15, 83.0);

    vec3 grid_pos = VERTEX;
    vec3 displacement = vec3(0.0);
    vec3 normal = vec3(0.0, 1.0, 0.0);

    gerstner_wave(wave_a, grid_pos, displacement, normal);
    gerstner_wave(wave_b, grid_pos, displacement, normal);
    gerstner_wave(wave_c, grid_pos, displacement, normal);
    gerstner_wave(wave_d, grid_pos, displacement, normal);

    float vertex_distance = length(VERTEX.xz);
    float fade_mask = 1.0 - smoothstep(100.0, 400.0, vertex_distance);
    displacement *= fade_mask;

    VERTEX += displacement;
    NORMAL = normalize(normal); 
    
    v_wave_height = displacement.y;
    v_dist = vertex_distance;

    // Calculate steepness in the vertex shader, not the fragment for performance
    v_steepness = 1.0 - NORMAL.y; 
}

void fragment() {
    // Fractal Normal Mapping
    vec2 math_warp = vec2(
        (sin(UV.y * 4.0 + TIME * 0.3) + sin(UV.x * 17.0 - TIME * 0.6)),
        (cos(UV.x * 4.0 + TIME * 0.3) + cos(UV.y * 17.0 + TIME * 0.6))
    ) * 0.01;

    vec2 uv_1 = (UV * 3.0) + vec2(TIME * 0.015, TIME * 0.01) + math_warp;
    vec2 uv_2 = (UV * 6.0) + vec2(-TIME * 0.03, TIME * 0.02) - math_warp; 
    
    // Rotate the 2nd grid to reduce tiling
    vec2 rotated_uv_2 = vec2(
        (uv_2.x * 0.725) - (uv_2.y * 0.688),
        (uv_2.x * 0.688) + (uv_2.y * 0.725)
    );
    
    vec3 normal_blend_1 = texture(normal_map_1, uv_1).rgb;
    vec3 normal_blend_2 = texture(normal_map_2, rotated_uv_2).rgb;
    vec3 combined_normals = mix(normal_blend_1, normal_blend_2, 0.5); 
    
    // VR Distance LOD
    vec3 flat_normal = vec3(0.5, 0.5, 1.0);
    float normal_fade = smoothstep(20.0, 100.0, v_dist);
    NORMAL_MAP = mix(combined_normals, flat_normal, normal_fade);

    // View-Angle Color Mixing 
    float facing = 1.0 - max(dot(VIEW, NORMAL), 0.0);
    vec3 water_color = mix(color_deep, color_shallow, facing);

    // Fresnel Approximation
    float fresnel = 0.02 + 0.98 * pow(1.0 - max(dot(VIEW, NORMAL), 0.0), 5.0);
    
    // Output
    ALBEDO = water_color;
    ROUGHNESS = 0.1 - (fresnel * 0.1); 
    METALLIC = 0.0;
}