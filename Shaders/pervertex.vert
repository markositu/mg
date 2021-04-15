#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient;  // rgb

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

uniform struct material_t {
	vec3  diffuse;
	vec3  specular;
	float alpha;
	float shininess;
} theMaterial;

attribute vec3 v_position; // Model space
attribute vec3 v_normal;   // Model space
attribute vec2 v_texCoord;

varying vec4 f_color;
varying vec2 f_texCoord;


float lambert_factor(vec3 n, const vec3 l){
	//n es el vector normal
	//l es el vector de la luz
	return dot(n,l);
}
float specular_factor(const vec3 n, const vec3 l, const vec3 v, float m){
// n es el vector normal
// l es el vector de la luz
// v es el vector que va a la cámara
// m es el brillo del material
// ( theMaterial.shininess)
	vec3 r=normalize(lambert_factor(n,l)*n-l);
	return max(0,pow(dot(r,v),m));

}

void main() {
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
	vec3 N=(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	vec3 V=normalize((modelToCameraMatrix * vec4(v_position,1)).xyz*-1);
	vec3 L=normalize(theLights[0].position.xyz*-1);
	vec3 i_difusa=lambert_factor(N,L)*theMaterial.diffuse*theLights[0].diffuse;
	vec3 i_especular= specular_factor(N,L,V,theMaterial.shininess)*theMaterial.specular*theLights[0].specular*lambert_factor(N,L);
	
	f_color=vec4(scene_ambient+i_difusa+i_especular,1);
	f_texCoord=v_texCoord;
	
}
