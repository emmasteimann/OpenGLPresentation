#version 330 core

uniform mat4 u_ModelViewMatrix;
uniform mat4 u_ProjectionMatrix;

in vec4 a_Position;
in vec4 a_Color;
in vec2 a_TexCoord;
in vec3 a_Normal;

out vec4 frag_Color;
out vec2 frag_TexCoord;
out vec3 frag_Normal;
out vec3 frag_Position;

void main(void) {
  frag_Color = a_Color;
  gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * a_Position;
  frag_TexCoord = a_TexCoord;
  frag_Normal = (u_ModelViewMatrix * vec4(a_Normal, 0.0)).xyz;
  frag_Position = (u_ModelViewMatrix * a_Position).xyz;
}