shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;
uniform float pixelacion : hint_range(0.001, 0.1) = 0.001; 
uniform float oscuridad : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    
    vec2 grid_uv = round(SCREEN_UV / pixelacion) * pixelacion;
    vec4 tex_color = texture(screen_tex, grid_uv);
    
    COLOR = mix(tex_color, vec4(0.0, 0.0, 0.0, 1.0), oscuridad);
}