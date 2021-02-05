shader_type canvas_item;


uniform float inner_width  = 0.2;
uniform float outer_width  = 0.5;
uniform float gradient_ease = 5.0;
uniform float fill_ratio = 0.8;

void fragment() {
	float fill_angle = fill_ratio * 3.141592656 * 2.0;
	vec2 uv = UV * 2.0 - 1.0;
	if (atan(uv.x, uv.y) + 3.141592656 < fill_angle) {
		float cur_inner_width = inner_width;
		cur_inner_width *= cur_inner_width;
		float cur_outer_width = outer_width;
		cur_outer_width *= cur_outer_width;
		float d = uv.x * uv.x + uv.y * uv.y;
		if (d <= cur_outer_width && d>=cur_inner_width){
			float w = abs((1.0 + cur_outer_width) / 2.0 - d) / (1.0 - cur_outer_width);
			w = 1.0 - pow(w + 0.5, gradient_ease);
			COLOR = vec4(vec3(1.0), min(1.0, w ));
		} else {
			COLOR.a = 0.0;
		}
	} else {
		COLOR.a = 0.0;
	}
}