//
//  AssimpMesh.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/22/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "AssimpMesh.hpp"

#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>

#include "AssimpMeshEntry.hpp"
#import "GLDirector.h"

@interface AssimpMesh()
@end

@implementation AssimpMesh {
  std::vector<MeshEntry> m_Entries;
  std::vector<GLKTextureInfo*> m_Textures;
  char *_name;
  GLAssimpEffect *_assimpShader;
  GLuint _vao;
}

-(instancetype)initWithName:(char *)name {
  if (self = [super init]){
    _name = name;

    self.position = GLKVector3Make(0, 0, 0);
    self.rotationX = -M_PI_2;
    self.rotationY = 0;
    self.rotationZ = 0;
    self.scale = 1.0;
    self.children = [NSMutableArray array];
    self.matColor = GLKVector4Make(1, 1, 1, 1);

    _assimpShader = [[GLAssimpEffect alloc] initWithVertexShader:@"GLSimpleVertex.glsl" fragmentShader:@"GLSimpleFragment.glsl"];

    [self loadMeshWithFileName:@"TeamFlareAdmin" andExtension:@"DAE"];
  }
  return self;
}

#pragma mark - Assimp Boiler Plate

- (BOOL)loadMeshWithFileName:(NSString *)fileName andExtension:(NSString *)extension  {

  // should do a Clear here?

  BOOL Ret = false;

  Assimp::Importer importer;
  importer.SetExtraVerbose(true);

  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource:fileName ofType:extension];
  const char *cPath =[path cStringUsingEncoding: NSUTF8StringEncoding];

  const aiScene* pScene = importer.ReadFile(cPath, aiProcess_Triangulate | aiProcess_GenSmoothNormals | aiProcess_FlipUVs);

  if (pScene) {
    Ret = [self initFromScene:pScene withFilePath:cPath];
  } else {
    printf("Error parsing '%s': '%s'\n", cPath, importer.GetErrorString());
  }

  return Ret;
}

- (BOOL)initFromScene:(const aiScene *)pScene withFilePath:(const char *)filePath {
  m_Entries.resize(pScene->mNumMeshes);
  m_Textures.resize(pScene->mNumMaterials);

  // Initialize the meshes in the scene one by one
  for (unsigned int i = 0 ; i < pScene->mNumMeshes ; i++) {
    const aiMesh* paiMesh = pScene->mMeshes[i];
    [self initMesh:paiMesh withIndex:i];
  }

  return [self initMaterials:pScene withFilePath:filePath]; // InitMaterials(pScene, Filename);
}

- (void)initMesh:(const aiMesh*)paiMesh withIndex:(unsigned int)index {
  m_Entries[index].MaterialIndex = paiMesh->mMaterialIndex;
  std::vector<Vertex> Vertices;
  std::vector<unsigned int> Indices;
  const aiVector3D Zero3D(0.0f, 0.0f, 0.0f);

  for (unsigned int i = 0 ; i < paiMesh->mNumVertices ; i++) {
    const aiVector3D* pPos      = &(paiMesh->mVertices[i]);
    const aiVector3D* pNormal   = &(paiMesh->mNormals[i]);
    const aiVector3D* pTexCoord = paiMesh->HasTextureCoords(0) ? &(paiMesh->mTextureCoords[0][i]) : &Zero3D;

    Vertex v(GLKVector3Make(pPos->x, pPos->y, pPos->z),
             GLKVector2Make(pTexCoord->x, pTexCoord->y),
             GLKVector3Make(pNormal->x, pNormal->y, pNormal->z));

    Vertices.push_back(v);
  }

  for (unsigned int i = 0 ; i < paiMesh->mNumFaces ; i++) {
    const aiFace& Face = paiMesh->mFaces[i];
    assert(Face.mNumIndices == 3);
    Indices.push_back(Face.mIndices[0]);
    Indices.push_back(Face.mIndices[1]);
    Indices.push_back(Face.mIndices[2]);
  }
  
  m_Entries[index].Init(Vertices, Indices);
}

- (BOOL)initMaterials:(const aiScene *)pScene withFilePath:(const char *)filePath {
    // Extract the directory part from the file name
    std::string Filename = std::string(filePath);
    std::string::size_type SlashIndex = Filename.find_last_of("/");
    std::string Dir;
  
    if (SlashIndex == std::string::npos) {
      Dir = ".";
    }
    else if (SlashIndex == 0) {
      Dir = "/";
    }
    else {
      Dir = Filename.substr(0, SlashIndex);
    }
  
    bool Ret = true;
  
    // Initialize the materials
    for (unsigned int i = 0 ; i < pScene->mNumMaterials ; i++) {
      const aiMaterial* pMaterial = pScene->mMaterials[i];
  
      m_Textures[i] = NULL;
  
      if (pMaterial->GetTextureCount(aiTextureType_DIFFUSE) > 0) {
        aiString Path;
  
        if (pMaterial->GetTexture(aiTextureType_DIFFUSE, 0, &Path, NULL, NULL, NULL, NULL, NULL) == AI_SUCCESS) {
          std::string FullPath = Dir + "/" + Path.data;
          NSString *pathString = [NSString stringWithUTF8String:FullPath.c_str()];
          NSError *error = nil;

          NSString *path = [[NSBundle mainBundle] pathForResource:[pathString lastPathComponent] ofType:nil];

          NSDictionary *options = @{ };

          GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:nil error:&error];
          if (info == nil) {
            NSLog(@"%@", path);
            NSLog(@"Error loading file: %@", error.localizedDescription);
            m_Textures[i] = NULL;
            Ret = false;
          } else {
            m_Textures[i] = info;
          }
        }
      }
  
      // Load a white texture in case the model does not include its own texture
      if (!m_Textures[i]) {
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"white.png" ofType:nil];

        NSDictionary *options = @{};
        GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        m_Textures[i] = info;

        if (info == nil) {
          NSLog(@"Error loading file: %@", error.localizedDescription);
          m_Textures[i] = NULL;
          Ret = false;
        }
      }
    }
  
  return Ret;
}

#pragma mark - Integrated Rending Code

- (void)renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix {

  GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, [self modelMatrix]);

  for (id child in self.children) {
    if ([child respondsToSelector:@selector(renderWithParentModelViewMatrix:)]) {
      [child renderWithParentModelViewMatrix:modelViewMatrix];
    }
  }

  glGenVertexArrays(1, &_vao);
  glBindVertexArray(_vao);
  glEnableVertexAttribArray(0);
  glEnableVertexAttribArray(1);
  glEnableVertexAttribArray(2);
//  GLenum enums[] = {GL_TEXTURE0,GL_TEXTURE1,GL_TEXTURE2,GL_TEXTURE3,GL_TEXTURE4,GL_TEXTURE4,GL_TEXTURE6,GL_TEXTURE8,GL_TEXTURE9,GL_TEXTURE10,GL_TEXTURE11,GL_TEXTURE12,GL_TEXTURE13};
  for (unsigned int i = 0 ; i < m_Entries.size() ; i++) {
    glBindBuffer(GL_ARRAY_BUFFER, m_Entries[i].VB);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*) offsetof(Vertex, m_pos));
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*) offsetof(Vertex, m_tex));
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (const GLvoid*) offsetof(Vertex, m_normal));

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_Entries[i].IB);

    _assimpShader.modelViewMatrix = modelViewMatrix;
    _assimpShader.projectionMatrix = [GLDirector sharedInstance].sceneProjectionMatrix;
    _assimpShader.matColor = self.matColor;

    const unsigned int MaterialIndex = m_Entries[i].MaterialIndex;

    if (MaterialIndex < m_Textures.size() && m_Textures[MaterialIndex]) {
      if (m_Textures[MaterialIndex].name == 3){
        glActiveTexture(GL_TEXTURE3);
      } else if (m_Textures[MaterialIndex].name == 4) {
        glActiveTexture(GL_TEXTURE4);
      } else {
        glActiveTexture(GL_TEXTURE5);
      }
      _assimpShader.texture = m_Textures[MaterialIndex].name;
      glBindTexture(GL_TEXTURE_2D, m_Textures[MaterialIndex].name);

    }

    [_assimpShader prepareToDraw];

    glBindVertexArray(_vao);
//    glPointSize(5);
//    glDrawArrays(GL_POINTS, 0, m_Entries[i].MeshVertices.size());
    glDrawElements(GL_TRIANGLES, m_Entries[i].NumIndices, GL_UNSIGNED_INT, 0);
  }
  
  glDisableVertexAttribArray(0);
  glDisableVertexAttribArray(1);
  glDisableVertexAttribArray(2);
}

- (GLKMatrix4)modelMatrix {
  GLKMatrix4 modelMatrix = GLKMatrix4Identity;
  modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1);
  modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, self.scale);
  return modelMatrix;
}

- (void)updateWithDelta:(NSTimeInterval)dt {
  for (id child in self.children) {
    if ([child respondsToSelector:@selector(updateWithDelta:)]) {
      [child updateWithDelta:dt];
    }
  }
}

@end
