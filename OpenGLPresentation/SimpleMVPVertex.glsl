#version 330 core

uniform mat4 u_ModelViewMatrix;
uniform mat4 u_ProjectionMatrix;

in vec4 a_Position;
in vec4 a_Color;

out vec4 frag_Color;

void main(void) {
  frag_Color = a_Color;
  gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * a_Position;
}