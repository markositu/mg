#version 120

// Bump mapping with many lights.

// all attributes in model space
attribute vec3 v_position;
attribute vec3 v_normal;
attribute vec2 v_texCoord;
attribute vec3 v_TBN_t;
attribute vec3 v_TBN_b;

uniform mat4 modelToCameraMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

// All bump computations are performed in tangent space; therefore, we need to
// convert all light (and spot) directions and view directions to tangent space
// and pass them the fragment shader.

varying vec2 f_texCoord;
varying vec3 f_viewDirection;     // tangent space
varying vec3 f_lightDirection[4]; // tangent space
varying vec3 f_spotDirection[4];  // tangent space
varying vec3 f_position;

void main() {
	gl_Position = modelToClipMatrix * vec4(v_position, 1.0);

	vec3 normal=normalize((modelToCameraMatrix*vec4(v_normal, 0.0)).xyz);
	vec3 tangent=normalize((modelToCameraMatrix*vec4(v_TBN_t, 0.0)).xyz);
	vec3 bitangent=normalize((modelToCameraMatrix*vec4(v_TBN_b, 0.0)).xyz);
	mat3 TBN=transpose(mat3(
        tangent,
        bitangent,
        normal
    ));
	f_position=TBN*(modelToCameraMatrix*vec4(v_position, 1.0)).xyz;
	f_viewDirection=((-f_position));
	for (int light=0;light<active_lights_n;light++){
		f_lightDirection[light]=(TBN*(theLights[light].position).xyz);
		f_spotDirection[light]=(TBN*theLights[light].spotDir);
	}
	
	f_texCoord=v_texCoord;
}
