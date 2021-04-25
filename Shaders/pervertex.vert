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

void luz_direccional(vec3 N,vec3 V, int light,out vec3 i_difusa,out vec3 i_especular){
	vec3 L=normalize(theLights[light].position.xyz*-1);
	i_difusa=lambert_factor(N,L)*theLights[light].diffuse*theMaterial.diffuse;
	i_especular= specular_factor(N,L,V,theMaterial.shininess)*theLights[light].specular*lambert_factor(N,L)*theMaterial.specular;
}
void luz_posicional(vec3 positionEye,vec3 N,vec3 V, int light,out vec3 i_difusa,out vec3 i_especular){
	vec3 L=normalize(theLights[light].position.xyz-positionEye);
	float d=distance(positionEye,theLights[light].position.xyz);
	float atenuacion=1/(theLights[light].attenuation.x+theLights[light].attenuation.y*d+theLights[light].attenuation.z*pow(d,2));
	i_difusa=atenuacion*lambert_factor(N,L)*theLights[light].diffuse*theMaterial.diffuse;
	i_especular=atenuacion* specular_factor(N,L,V,theMaterial.shininess)*theLights[light].specular*lambert_factor(N,L)*theMaterial.specular;	
}
void luz_foco(vec3 N,vec3 V, int light,out vec3 i_difusa,out vec3 i_especular){
	vec3 L=V;
	vec3 S=normalize(theLights[light].spotDir);
	float Os=dot(-L,S);
	if(Os<theLights[light].cosCutOff){
		i_difusa=vec3(0,0,0);
		i_especular=vec3(0,0,0);
	}
	else{
		float cspot=pow(max(Os,0),theLights[light].exponent);
		i_difusa=cspot*lambert_factor(N,L)*theLights[light].diffuse*theMaterial.diffuse;
		i_especular= cspot*specular_factor(N,L,V,theMaterial.shininess)*theLights[light].specular*lambert_factor(N,L)*theMaterial.specular;
	}
}

void main() {
	vec3 i_difusa,i_especular,acumulador_difuso,acumulador_especular,N,V;
	acumulador_difuso=vec3(0,0,0);
	acumulador_especular=vec3(0,0,0);
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
	vec3 positionEye= (modelToCameraMatrix * vec4(v_position,1)).xyz;
	N=normalize((modelToCameraMatrix * vec4(v_normal,0)).xyz);
	V=normalize(-positionEye);
	for (int light=0;light<active_lights_n;light++){
		if (theLights[light].cosCutOff!=0)luz_foco(N,V,light,i_difusa,i_especular);
		else{
			if(theLights[light].position.w==0)luz_direccional(N,V,light,i_difusa,i_especular);
			else luz_posicional(positionEye,N,V,light,i_difusa,i_especular);
		}
		acumulador_difuso+=i_difusa;
		acumulador_especular+=i_especular;
		

		
	}
	f_color=vec4(scene_ambient+acumulador_difuso+acumulador_especular,1);
	f_texCoord=v_texCoord;
	
}
