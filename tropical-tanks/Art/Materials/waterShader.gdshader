shader_type spatial;

varying float height;
varying vec3 world_pos;


// Thanks StayAtHomeDev
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0,1.0) = 0;
uniform float roughness : hint_range(0.0,1.0) = 0.02;
uniform sampler2D wave : filter_linear_mipmap;
uniform sampler2D texture_normal : filter_nearest;
uniform sampler2D texture_normal2 : filter_nearest;
uniform vec2 wave_direction = vec2(2.0,0.0);
uniform vec2 wave_direction2 = vec2(0.0,1.0);
uniform float time_scale : hint_range(0.0, 0.2, 0.005) = 0.025;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,  filter_linear_mipmap;
uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 1.0;
uniform float depth_offset = -0.75;

uniform float edge_scale = 0.1;
uniform float near = 1.0;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

float findHeight(vec2 position, float t){
	return texture(wave,position/noise_scale + t * time_scale).r;
}

float fbm(vec2 position, float t){
	return (findHeight(position, t) * height_scale);
}

void vertex() {
	world_pos = (MODEL_MATRIX * 0.01 * vec4(VERTEX,1.0)).xyz;
	height = findHeight(world_pos.xz, TIME);
	VERTEX.y += height * height_scale;

	vec2 e = vec2(0.1,0.0);
	//vec3 normal = normalize(vec3(fbm(VERTEX.xz - e, TIME) - fbm(VERTEX.xz + e , TIME), 2.0 * e.x, fbm(VERTEX.xz - e.yx, TIME) - fbm(VERTEX.xz + e.yx, TIME)));
	//NORMAL = normal;
}


float fresnel(float amount, vec3 normal, vec3 view){
	return pow((1.0-clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float edge(float depth){

	depth = 1.0 - 2.0 * depth;

	return near * far / (far + depth * (near - far));

}


void fragment() {
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	depth = depth + VERTEX.z;
	float depth_blend = exp((depth + depth_offset) * beers_law);
	//depth_blend = clamp(1.0 - depth_blend, 0.0,1.0);
	float depth_blend_power = clamp(pow(depth_blend,2.5),0.0,1.0);

	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power).rgb;
	vec3 depth_color = mix(color_shallow.rgb,color_deep.rgb,depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.75);

	float z_depth = edge(texture(DEPTH_TEXTURE,SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;

	vec2 time = (TIME * wave_direction) * time_scale;
	vec2 time2 = (TIME* wave_direction2) *time_scale;

	vec3 normal_blend = mix(texture(texture_normal,world_pos.xz  +time).rgb,texture(texture_normal2,world_pos.xz + time2).rgb,0.5);

	float fresnel = fresnel(5.0,NORMAL,VIEW);
	vec3 surface_color = mix(albedo,albedo2,fresnel);
	vec3 depth_color_adj = mix(edge_color,color,step(edge_scale,z_dif));

	ALBEDO = clamp(surface_color + depth_color_adj,vec3(0.0),vec3(1.0));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
	//ALBEDO = vec3(depth_blend_power);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
