#ifndef SHADER_H
#define SHADER_H

#include "Common.hpp"

class Shader {
public:
  Shader(const char* sVertexSource, const char* sFragmentSource);
  ~Shader();

  void Bind() const;
  void Unbind() const;
  GLuint GetAttribLocation(const char * sName) const;
  GLuint GetUniformLocation(const char * sName) const;
  GLuint GetProjectionMatrixLocation();
  GLuint GetViewMatrixLocation();
  GLuint GetModelMatrixLocation();
  GLuint GetLightPositionLocation();
  GLuint GetLightAmbientColorLocation();
  GLuint GetLightDiffuseColorLocation();
  GLuint GetVertexLocation();
  GLuint GetNormalLocation();
  GLuint GetColorLocation();
  GLuint GetTexCoordLocation();
  GLuint GetBoneWeightsLocation();
  GLuint GetBoneMatricesLocation();
  GLuint GetBoneIndicesLocation();
  GLuint GetUseTextureLocation();
  GLuint GetTextureLocation();

private:
  GLuint m_uVertexShader;
  GLuint m_uFragmentShader;
  GLuint m_uProgram;
  GLuint m_uProjectionMatrixLocation;
  GLuint m_uViewMatrixLocation;
  GLuint m_uModelMatrixLocation;
  GLuint m_uLightPositionLocation;
  GLuint m_uLightAmbientColorLocation;
  GLuint m_uLightDiffuseColorLocation;
  GLuint m_uVertexLocation;
  GLuint m_uNormalLocation;
  GLuint m_uColorLocation;
  GLuint m_uTexCoordLocation;
  GLuint m_uBoneWeightsLocation;
  GLuint m_uBoneMatricesLocation;
  GLuint m_uBoneIndicesLocation;
  GLuint m_uUseTextureLocation;
  GLuint m_uTextureLocation;
};

#endif