#version 330 core

in vec2 frag_TexCoord;
in vec3 frag_Normal;
in vec3 frag_Position;

uniform sampler2D u_Texture;
uniform float u_MatSpecularIntensity;
uniform float u_Shininess;
uniform vec4 u_MatColor;
uniform bool u_makeItBlack;
uniform bool u_nothingIsNormal;


struct Light {
  vec3 Color;
  float AmbientIntensity;
  float DiffuseIntensity;
  vec3 Direction;
};
uniform Light u_Light;

out vec4 outputColor;

void main(void) {

  // Ambient
  vec3 AmbientColor = u_Light.Color * u_Light.AmbientIntensity;
  
  // Diffuse
  vec3 Normal = normalize(frag_Normal);
  float DiffuseFactor = max(-dot(Normal, u_Light.Direction), 0.0);
  vec3 DiffuseColor = u_Light.Color * u_Light.DiffuseIntensity * DiffuseFactor;

  // Specular
  vec3 Eye = normalize(frag_Position);
  vec3 Reflection = reflect(u_Light.Direction, Normal);
  float SpecularFactor = pow(max(0.0, -dot(Reflection, Eye)), u_Shininess);
  vec3 SpecularColor = u_Light.Color * u_MatSpecularIntensity * SpecularFactor;
  
  if (u_makeItBlack) {
    outputColor = vec4(0,0,0,1);
  } else {
//    if (u_Texture) {
      if (u_nothingIsNormal) {
        outputColor = u_MatColor * texture(u_Texture, frag_TexCoord);
      } else {
        outputColor = u_MatColor * texture(u_Texture, frag_TexCoord) * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
      }
//    } else {
//      outputColor = u_MatColor * vec4((AmbientColor + DiffuseColor + SpecularColor), 1.0);
//    }

  }
}