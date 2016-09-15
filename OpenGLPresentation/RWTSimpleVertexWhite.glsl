#version 330 core

in vec4 a_Position;
in vec4 a_Color;

out vec4 frag_Color;

void main(void) {
  frag_Color = a_Color;
  gl_Position = a_Position;
}