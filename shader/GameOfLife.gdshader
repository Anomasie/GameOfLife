shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
	vec3 sum = vec3(0.0);
	for(int y = -1; y <= 1; y++)
	for(int x = -1; x <= 1; x++) {
		vec2 pixel_off = vec2(float(x), float(y));
		vec3 c = textureLod(screen_texture, SCREEN_UV + pixel_off * pixel_size, 0.0).rgb;
		sum = sum + c;
	}
	COLOR.rgb = sum / 9.0;
}