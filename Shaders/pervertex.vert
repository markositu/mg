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
	return max(0,dot(n,l));
}
float specular_factor(const vec3 n, const vec3 l, const vec3 v, float m){
// n es el vector normal
// l es el vector de la luz
// v es el vector que va a la cámara
// m es el brillo del material
// ( theMaterial.shininess)
	vec3 r=reflect(-l,n);//https://learnopengl.com/Lighting/Basic-Lighting
	return max(0,pow(dot(r,v),m));

}

void luz_direccional(vec3 L,vec3 N,vec3 V, int light,out vec3 i_difusa,out vec3 i_especular){
	i_difusa=lambert_factor(N,L)*theLights[light].diffuse;
	i_especular= specular_factor(N,L,V,theMaterial.shininess)*theLights[light].specular*lambert_factor(N,L);
}

void main() {
	vec3 i_difusa,i_especular,acumulador_difuso,acumulador_especular,N,V,L;
	acumulador_difuso=vec3(0,0,0);
	acumulador_especular=vec3(0,0,0);
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
	vec3 positionEye= (modelToCameraMatrix * vec4(v_position,1)).xyz;
	N=normalize((modelToCameraMatrix * vec4(v_normal,0)).xyz);
	V=normalize(vec3(modelToCameraMatrix[3][0],modelToCameraMatrix[3][1],modelToCameraMatrix[3][2]));
	for (int light=0;light<active_lights_n;light++){
		L=normalize(theLights[light].position.xyz*-1);
		luz_direccional(L,N,V,light,i_difusa,i_especular);
		acumulador_difuso+=i_difusa;
		acumulador_especular+=i_especular;
	}
	f_color=vec4(scene_ambient+acumulador_difuso*theMaterial.diffuse+acumulador_especular*theMaterial.specular,1);
	f_texCoord=v_texCoord;
	
}
