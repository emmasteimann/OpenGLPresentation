#include "Shader.hpp"
#include <GLFW/glfw3.h>

Shader::Shader(const char* sVertexSource, const char* sFragmentSource) {
  m_uProjectionMatrixLocation = -1;
  m_uViewMatrixLocation = -1;
  m_uModelMatrixLocation = -1;
  m_uLightPositionLocation = -1;
  m_uLightAmbientColorLocation = -1;
  m_uLightDiffuseColorLocation = -1;
  m_uVertexLocation = -1;
  m_uNormalLocation = -1;
  m_uColorLocation = -1;
  m_uTexCoordLocation = -1;
  m_uBoneWeightsLocation = -1;
  m_uBoneMatricesLocation = -1;
  m_uBoneIndicesLocation = -1;
  m_uUseTextureLocation = -1;
  m_uTextureLocation = -1;

  m_uVertexShader = glCreateShader(GL_VERTEX_SHADER);
  m_uFragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(m_uVertexShader, 1, (const GLchar**) &sVertexSource, NULL);
  glShaderSource(m_uFragmentShader, 1, (const GLchar**) &sFragmentSource, NULL);
  glCompileShader(m_uVertexShader);		

  GLint iVertexShaderCompileStatus;
  glGetShaderiv(m_uVertexShader, GL_COMPILE_STATUS, &iVertexShaderCompileStatus);

  if ((iVertexShaderCompileStatus) && (glIsShader(m_uVertexShader))) {
    std::cout << "Vertex shader compiled" << std::endl;
  }
  else {
    std::cerr << "Vertex shader not compiled" << std::endl;
  }

  glCompileShader(m_uFragmentShader);

  GLint iFragmentShaderCompileStatus;
  glGetShaderiv(m_uFragmentShader, GL_COMPILE_STATUS, &iFragmentShaderCompileStatus);

//  GLint compileSuccess;
//  glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
//  if (compileSuccess == GL_FALSE) {
//    GLchar messages[256];
//    glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
//    NSString *messageString = [NSString stringWithUTF8String:messages];
//    NSLog(@"%@", messageString);
//    exit(1);
//  }


  if ((iFragmentShaderCompileStatus) && (glIsShader(m_uFragmentShader))) {
    std::cout << "Fragment shader compiled" << std::endl;
  }
  else {
    GLchar messages[256];
    glGetShaderInfoLog(m_uFragmentShader, sizeof(messages), 0, &messages[0]);
    printf("%s", messages);
    std::cerr << "Fragment shader not compiled" << std::endl;
  }

  m_uProgram = glCreateProgram();
  glAttachShader(m_uProgram, m_uVertexShader);
  glAttachShader(m_uProgram, m_uFragmentShader);

  glLinkProgram(m_uProgram);

  GLint iLinkedStatus;
  glGetProgramiv(m_uProgram, GL_LINK_STATUS, &iLinkedStatus);

  if ((iLinkedStatus) && (glIsProgram(m_uProgram))) {
    std::cout << "Shader linked" << std::endl;
  }
  else {
    std::cerr << "Shader not linked" << std::endl;
  }
}

Shader::~Shader() {
  glDeleteProgram(m_uProgram);
  glDeleteShader(m_uVertexShader);
  glDeleteShader(m_uFragmentShader);
}

void Shader::Bind() const {
  glUseProgram(m_uProgram);
}

void Shader::Unbind() const {
  glUseProgram(0);
}

GLuint Shader::GetAttribLocation(const char* sName) const {
  return glGetAttribLocation(m_uProgram, sName);
}

GLuint Shader::GetUniformLocation(const char* sName) const {
  return glGetUniformLocation(m_uProgram, sName);
}

GLuint Shader::GetVertexLocation() {
  if (m_uVertexLocation == -1) {
    m_uVertexLocation = GetAttribLocation("inPosition");
  }

  return m_uVertexLocation;
}

GLuint Shader::GetNormalLocation() {
  if (m_uNormalLocation == -1) {
    m_uNormalLocation = GetAttribLocation("inNormal");
  }

  return m_uNormalLocation;
}

GLuint Shader::GetColorLocation() {
  if (m_uColorLocation == -1) {
    m_uColorLocation = GetAttribLocation("inColor");
  }

  return m_uColorLocation;
}

GLuint Shader::GetTexCoordLocation() {
  if (m_uTexCoordLocation == -1) {
    m_uTexCoordLocation = GetAttribLocation("inTexCoord");
  }

  return m_uTexCoordLocation;
}

GLuint Shader::GetBoneWeightsLocation() {
  if (m_uBoneWeightsLocation == -1) {
    m_uBoneWeightsLocation = GetAttribLocation("inBoneWeights");
  }

  return m_uBoneWeightsLocation;
}

GLuint Shader::GetBoneIndicesLocation() {
  if (m_uBoneIndicesLocation == -1) {
    m_uBoneIndicesLocation = GetAttribLocation("inBoneIndices");
  }

  return m_uBoneIndicesLocation;
}

GLuint Shader::GetProjectionMatrixLocation() {
  if (m_uProjectionMatrixLocation == -1) {
    m_uProjectionMatrixLocation = GetUniformLocation("projectionMatrix");
  }

  return m_uProjectionMatrixLocation;
}

GLuint Shader::GetViewMatrixLocation() {
  if (m_uViewMatrixLocation == -1) {
    m_uViewMatrixLocation = GetUniformLocation("viewMatrix");
  }

  return m_uViewMatrixLocation;
}

GLuint Shader::GetModelMatrixLocation() {
  if (m_uModelMatrixLocation == -1) {
    m_uModelMatrixLocation = GetUniformLocation("modelMatrix");
  }

  return m_uModelMatrixLocation;
}

GLuint Shader::GetLightPositionLocation() {
  if (m_uLightPositionLocation == -1) {
    m_uLightPositionLocation = GetUniformLocation("lightPosition");
  }

  return m_uLightPositionLocation;
}

GLuint Shader::GetLightAmbientColorLocation() {
  if (m_uLightAmbientColorLocation == -1) {
    m_uLightAmbientColorLocation = GetUniformLocation("lightAmbientColor");
  }

  return m_uLightAmbientColorLocation;
}

GLuint Shader::GetLightDiffuseColorLocation() {
  if (m_uLightDiffuseColorLocation == -1) {
    m_uLightDiffuseColorLocation = GetUniformLocation("lightDiffuseColor");
  }

  return m_uLightDiffuseColorLocation;
}

GLuint Shader::GetBoneMatricesLocation() {
  if (m_uBoneMatricesLocation == -1) {
    m_uBoneMatricesLocation = GetUniformLocation("boneMatrices");
  }

  return m_uBoneMatricesLocation;
}

GLuint Shader::GetUseTextureLocation() {
  if (m_uUseTextureLocation == -1) {
    m_uUseTextureLocation = GetUniformLocation("useTexture");
  }

  return m_uUseTextureLocation;
}

GLuint Shader::GetTextureLocation() {
  if (m_uTextureLocation == -1) {
    m_uTextureLocation = GetUniformLocation("texture");
  }

  return m_uTextureLocation;
}