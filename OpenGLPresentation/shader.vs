#version 330

uniform mat4 u_ModelViewMatrix;
uniform mat4 u_ProjectionMatrix;

in vec4 a_Position;

void main()
{
    gl_Position = u_ProjectionMatrix * u_ModelViewMatrix * a_Position;
}