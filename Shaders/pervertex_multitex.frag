#version 120

varying vec4 f_color;
varying vec2 f_texCoord;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float uCloudOffset; // The offset of the cloud texture

void main() {

	// The final color must be a linear combination of both
	// textures with a factor of 0.5, e.g:
	// ref = https://www.khronos.org/opengl/wiki/Multitexture_with_GLSL 
	vec4 texColor,texColor2,color;
	texColor = texture2D(texture0, f_texCoord);
	texColor2 = texture2D(texture1, f_texCoord+uCloudOffset);
	color = 0.5 * texColor + 0.5 * texColor2;
	gl_FragColor = f_color*color;
}
