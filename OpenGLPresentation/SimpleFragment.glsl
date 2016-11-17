#version 330 core

in vec4 frag_Color;

out vec4 outputColor;

void main(void) {
  outputColor = frag_Color;
}