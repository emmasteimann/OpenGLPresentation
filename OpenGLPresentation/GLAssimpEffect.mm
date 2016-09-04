//
//  GLAssimpEffect.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLAssimpEffect.hpp"
#import "GLBaseEffect+Protected.h"
#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>
#include "Matrix4f.hpp"

#define POSITION_LOCATION    0
#define TEX_COORD_LOCATION   1
#define NORMAL_LOCATION      2
#define BONE_ID_LOCATION     3
#define BONE_WEIGHT_LOCATION 4
#define ARRAY_SIZE_IN_ELEMENTS(a) (sizeof(a)/sizeof(a[0]))
static const uint MAX_BONES = 100;


@implementation GLAssimpEffect {
  GLuint _programHandle;
  GLuint _modelViewMatrixUniform;
  GLuint _projectionMatrixUniform;
  GLuint _texUniform;
  GLuint _lightColorUniform;
  GLuint _lightAmbientIntensityUniform;
  GLuint _lightDiffuseIntensityUniform;
  GLuint _lightDirectionUniform;
  GLuint _matSpecularIntensityUniform;
  GLuint _shininessUniform;
  GLuint _matColorUniform;
  GLuint m_boneLocation[MAX_BONES];
}



- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
  return [super compileShader:shaderName withType:shaderType];
}

- (void)compileVertexShader:(NSString *)vertexShader
             fragmentShader:(NSString *)fragmentShader {
  GLuint vertexShaderName = [self compileShader:vertexShader
                                       withType:GL_VERTEX_SHADER];
  GLuint fragmentShaderName = [self compileShader:fragmentShader
                                         withType:GL_FRAGMENT_SHADER];

  _programHandle = glCreateProgram();
  glAttachShader(_programHandle, vertexShaderName);
  glAttachShader(_programHandle, fragmentShaderName);

  glLinkProgram(_programHandle);

  self.modelViewMatrix = GLKMatrix4Identity;

  for (unsigned int i = 0 ; i < ARRAY_SIZE_IN_ELEMENTS(m_boneLocation) ; i++) {
    NSString *nameString = [NSString stringWithFormat:@"gBones[%d]", i];
    const char *name = [nameString cStringUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"name: %s", name);
    m_boneLocation[i] = glGetUniformLocation(_programHandle, name);
  }

  _modelViewMatrixUniform = glGetUniformLocation(_programHandle, "u_ModelViewMatrix");
  _projectionMatrixUniform = glGetUniformLocation(_programHandle, "u_ProjectionMatrix");
  _texUniform = glGetUniformLocation(_programHandle, "u_Texture");

  _lightColorUniform = glGetUniformLocation(_programHandle, "u_Light.Color");
  _lightAmbientIntensityUniform = glGetUniformLocation(_programHandle, "u_Light.AmbientIntensity");
  _lightDiffuseIntensityUniform = glGetUniformLocation(_programHandle, "u_Light.DiffuseIntensity");
  _lightDirectionUniform = glGetUniformLocation(_programHandle, "u_Light.Direction");

  _matSpecularIntensityUniform = glGetUniformLocation(_programHandle, "u_MatSpecularIntensity");
  _shininessUniform = glGetUniformLocation(_programHandle, "u_Shininess");
  _matColorUniform = glGetUniformLocation(_programHandle, "u_MatColor");


  GLint linkSuccess;
  glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
  if (linkSuccess == GL_FALSE) {
    GLchar messages[256];
    glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
    NSString *messageString = [NSString stringWithUTF8String:messages];
    NSLog(@"%@", messageString);
    exit(1);
  }
}

- (void)setBoneTransform:(const aiMatrix4x4t<float>&)Transform onIndex:(uint)Index
{
//  assert(Index < MAX_BONES);
//  Transform.Print();
  const GLfloat *pointerTransform = Matrix4f(Transform);
  glUniformMatrix4fv(m_boneLocation[Index], 1, GL_TRUE, pointerTransform);
}

- (void)prepareToDraw {
  glUseProgram(_programHandle);
  glUniformMatrix4fv(_modelViewMatrixUniform, 1, 0, self.modelViewMatrix.m);
  glUniformMatrix4fv(_projectionMatrixUniform, 1, 0, self.projectionMatrix.m);
  glUniform1i(_texUniform, self.texture);

  glUniform3f(_lightColorUniform, 1, 1, 1);
  glUniform1f(_lightAmbientIntensityUniform, 0.75);
  GLKVector3 lightDirection = GLKVector3Normalize(GLKVector3Make(0, -3, -3));
  glUniform3f(_lightDirectionUniform, lightDirection.x, lightDirection.y, lightDirection.z);
  glUniform1f(_lightDiffuseIntensityUniform, 0.7);
  glUniform1f(_matSpecularIntensityUniform, 2.0);
  glUniform1f(_shininessUniform, 8.0);
  glUniform4f(_matColorUniform, self.matColor.r, self.matColor.g, self.matColor.b, self.matColor.a);

}

@end
