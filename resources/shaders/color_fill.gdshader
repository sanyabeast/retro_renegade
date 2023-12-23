shader_type spatial;

uniform vec4 albedo : source_color = vec4(1.0);

varying vec3 barys;

void vertex() {
	
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = 0.75;
}