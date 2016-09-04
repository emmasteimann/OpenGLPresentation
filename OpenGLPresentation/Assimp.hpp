//
//  Assimp.hpp
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/2/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//
#include <GL/glew.h>
#include <OpenGL/OpenGL.h>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include <typeinfo>

#include <cstdio>
#include <cstdlib>
#include <string>
#include <iostream>
#include <fstream>

#include <assert.h>

#include <map>
#include <vector>

#include <assimp/cimport.h>
#include <assimp/scene.h>
#include <assimp/anim.h>
#include <assimp/postprocess.h>
#include <assimp/Importer.hpp>

struct VertexData
{
  GLfloat position[3];
  GLfloat normal[3];
  GLfloat textureCoord[2];
  GLfloat boneWeights[4];
  GLfloat boneIDs[4];
};

void printAssimpMatrix4x4(aiMatrix4x4 *matrix)
{
  std::cout << matrix->a1 << " " << matrix->a2 << " " << matrix->a3 << " " << matrix->a4 << std::endl;
  std::cout << matrix->b1 << " " << matrix->b2 << " " << matrix->b3 << " " << matrix->b4 << std::endl;
  std::cout << matrix->c1 << " " << matrix->c2 << " " << matrix->c3 << " " << matrix->c4 << std::endl;
  std::cout << matrix->d1 << " " << matrix->d2 << " " << matrix->d3 << " " << matrix->d4 << std::endl;
}

void insertAssimpMatrixInVector(std::vector<GLfloat> &vec, aiMatrix4x4 *matrix)
{
  vec.push_back(matrix->a1);
  vec.push_back(matrix->a2);
  vec.push_back(matrix->a3);
  vec.push_back(matrix->a4);
  vec.push_back(matrix->b1);
  vec.push_back(matrix->b2);
  vec.push_back(matrix->b3);
  vec.push_back(matrix->b4);
  vec.push_back(matrix->c1);
  vec.push_back(matrix->c2);
  vec.push_back(matrix->c3);
  vec.push_back(matrix->c4);
  vec.push_back(matrix->d1);
  vec.push_back(matrix->d2);
  vec.push_back(matrix->d3);
  vec.push_back(matrix->d4);
}

void printNodeTree(aiNode *node, int level, std::map <std::string, int>& bone_name_hash)
{
  if (level > 1)
  {
    std::string bone_name=std::string(std::string(node->mName.data));
    bone_name_hash[bone_name]=bone_name_hash.size();
    std::cout << "Level [" << level << "] " << bone_name << " id " << bone_name_hash[bone_name] << std::endl;
    printAssimpMatrix4x4(&node->mTransformation);
  }
  for (int i=0; i<node->mNumChildren; i++)
  {
    printNodeTree(node->mChildren[i], level+1, bone_name_hash);
  }
}

void printAnimations(const aiScene* scene)
{
  std::cout << "Has animations?  " << scene->HasAnimations() << std::endl;
  std::cout << "Printing " << scene->mNumAnimations << " animations names:" << std::endl;
  for (int i=0; i<scene->mNumAnimations; i++)
  {
    aiAnimation *anim=scene->mAnimations[i];
    std::cout << "Animation[" << i << "] " << anim->mName.data << std::endl;
    for (int j=0; j<anim->mNumChannels; j++)
    {
      aiNodeAnim *nodeAnim=anim->mChannels[j];
      std::cout << "Node[" << j << "] " << nodeAnim->mNodeName.data << std::endl;
    }
  }
}

inline glm::mat4 interpolate(const aiNodeAnim *node, unsigned int key, GLfloat alpha)
{
  glm::mat4 I(1.0f);
  aiQuaternion aiR;
  aiVector3D   aiS, aiT;
  Assimp::Interpolator<aiVector3D>   lerp;
  Assimp::Interpolator<aiQuaternion> slerp;

  assert(alpha >= 0.0 && alpha <= 1.0);
  lerp(aiS,  node->mScalingKeys[key].mValue, node->mScalingKeys[key].mValue, alpha);
  slerp(aiR, node->mRotationKeys[key].mValue, node->mRotationKeys[key].mValue, alpha);
  lerp(aiT,  node->mPositionKeys[key].mValue, node->mPositionKeys[key].mValue, alpha);

  glm::vec3 S((GLfloat)aiS.x, (GLfloat)aiS.y, (GLfloat)aiS.z);
  glm::quat R((GLfloat)aiR.w, (GLfloat)aiR.x, (GLfloat)aiR.y, (GLfloat)aiR.z);
  glm::vec3 T((GLfloat)aiT.x, (GLfloat)aiT.y, (GLfloat)aiT.z);

  return glm::translate(I, T) * glm::mat4_cast(glm::normalize(R));
}

void buildNodeHierarchy(const aiNode *node, std::map<std::string, int>& bone_name_hash, const glm::mat4 &T, std::vector<glm::mat4> &bone_transforms)
{
  glm::mat4 current_node_transform = T;
  if (&(node->mName) != NULL)
  {
    std::map<std::string, int>::iterator it = bone_name_hash.find(node->mName.data);
    if (it != bone_name_hash.end())
    {
      current_node_transform = current_node_transform * bone_transforms[it->second];
      bone_transforms[it->second] = current_node_transform;
    }
  }
  for (unsigned int i = 0; i < node->mNumChildren; ++i)
    buildNodeHierarchy(node->mChildren[i], bone_name_hash, current_node_transform, bone_transforms);
}

inline void printMat4(glm::mat4 &to)
{
  std::cout << to[0][0] << " " << to[1][0] << " " << to[2][0] << " " << to[3][0] << std::endl;
  std::cout << to[0][1] << " " << to[1][1] << " " << to[2][1] << " " << to[3][1] << std::endl;
  std::cout << to[0][2] << " " << to[1][2] << " " << to[2][2] << " " << to[3][2] << std::endl;
  std::cout << to[0][3] << " " << to[1][3] << " " << to[2][3] << " " << to[3][3] << std::endl;
}

inline void copyAiMatrixToGLM(const aiMatrix4x4 *from, glm::mat4 &to)
{
  to[0][0] = (GLfloat)from->a1; to[1][0] = (GLfloat)from->a2;
  to[2][0] = (GLfloat)from->a3; to[3][0] = (GLfloat)from->a4;
  to[0][1] = (GLfloat)from->b1; to[1][1] = (GLfloat)from->b2;
  to[2][1] = (GLfloat)from->b3; to[3][1] = (GLfloat)from->b4;
  to[0][2] = (GLfloat)from->c1; to[1][2] = (GLfloat)from->c2;
  to[2][2] = (GLfloat)from->c3; to[3][2] = (GLfloat)from->c4;
  to[0][3] = (GLfloat)from->d1; to[1][3] = (GLfloat)from->d2;
  to[2][3] = (GLfloat)from->d3; to[3][3] = (GLfloat)from->d4;
}