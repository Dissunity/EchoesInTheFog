shader_type spatial;
// Added depth_draw_never and blend_mix/add style hints for VR transparency performance
render_mode unshaded, cull_disabled, depth_draw_never, blend_add;

// Fire uniforms
uniform sampler2D noise_tex : repeat_enable; // Replaces procedural noise with a texture
uniform float detail_strength = 1.0;
uniform float scroll_speed = 1.2;
uniform float fire_height = 1.0;
uniform float fire_shape = 1.5;
uniform float fire_thickness = 0.55;
uniform float fire_sharpness = 1.0;
uniform float intensity = 1.0;


void fragment() {
    vec2 uv = UV;

    // UV for offset and animating UVs for fire    
    vec2 modified_uv = -uv;
    modified_uv.x = mod(modified_uv.x, 1.0) - 0.5;
    modified_uv.y += 0.84; // Size vertical
    
    // Fire noise scroll effect
    float scroll = scroll_speed * TIME;
    
    // texture lookup 
    float noise_val = texture(noise_tex, modified_uv * detail_strength - vec2(0.0, scroll)).r;
    
    // Controls the shape of the fire
    float fire_intensity = intensity - 16.0 * fire_sharpness * pow(
        max(
            0.0,
            length(
                modified_uv * vec2((1.0 / fire_thickness) + modified_uv.y * fire_shape, 1.0 / fire_height)
            ) - noise_val * max(0.0, modified_uv.y + 0.25)
        ),
        1.2
    );
    
    float fire_intensity1 = noise_val * fire_intensity * (1.5 - pow(1.0 * uv.y, 14.0));
    fire_intensity1 = clamp(fire_intensity1, 0.0, 1.0);

    // Compute fire color
    vec3 fire_color = vec3(
        1.5 * fire_intensity1,
        1.5 * pow(fire_intensity1, 3.0),
        pow(fire_intensity1, 6.0)
    );

    // Add alpha to color
    float alpha = fire_intensity * (1.0 - pow(uv.y, 3.0));
    alpha = clamp(alpha, 0.0, 1.0);
    
    // Apply to fragment
    ALBEDO = fire_color;
    ALPHA = alpha;
}