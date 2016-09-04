////
////  AssimpMeshEntry.hpp
////  OpenGLPresentation
////
////  Created by Emma Steimann on 8/24/16.
////  Copyright © 2016 Emma Steimann. All rights reserved.
////

#include <GLKit/GLKit.h>
#include <vector>
#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>

#define INVALID_UNIFORM_LOCATION 0xffffffff
#define INVALID_OGL_VALUE 0xffffffff
#define INVALID_MATERIAL 0xFFFFFFFF
#define NUM_BONES_PER_VEREX 4
#define ZERO_MEM(a) memset(a, 0, sizeof(a))
#define ARRAY_SIZE_IN_ELEMENTS(a) (sizeof(a)/sizeof(a[0]))

enum VB_TYPES {
  INDEX_BUFFER,
  POS_VB,
  NORMAL_VB,
  TEXCOORD_VB,
  BONE_VB,
  NUM_VBs
};

struct Vertex
{
  GLKVector3 m_pos;
  GLKVector2 m_tex;
  GLKVector3 m_normal;

  Vertex() {}

  Vertex(const GLKVector3& pos, const GLKVector2& tex, const GLKVector3& normal)
  {
    m_pos    = pos;
    m_tex    = tex;
    m_normal = normal;
  }
};

struct BoneInfo
{
  aiMatrix4x4 BoneOffset;
  aiMatrix4x4 FinalTransformation;

  BoneInfo()
  {
    BoneOffset = aiMatrix4x4t<float>();
    FinalTransformation = aiMatrix4x4t<float>();
  }
};

struct VertexBoneData
{
  uint IDs[NUM_BONES_PER_VEREX];
  float Weights[NUM_BONES_PER_VEREX];

  VertexBoneData()
  {
    Reset();
  };

  void Reset()
  {
    ZERO_MEM(IDs);
    ZERO_MEM(Weights);
  }

  void AddBoneData(uint BoneID, float Weight);
};

void VertexBoneData::AddBoneData(uint BoneID, float Weight)
{
  for (uint i = 0 ; i < ARRAY_SIZE_IN_ELEMENTS(IDs) ; i++) {
    if (Weights[i] == 0.0) {
      IDs[i]     = BoneID;
      Weights[i] = Weight;
      return;
    }
  }

  // should never get here - more bones than we have space for
//  assert(0);
}

struct MeshEntry {
  MeshEntry()
  {
    NumIndices    = 0;
    BaseVertex    = 0;
    BaseIndex     = 0;
    MaterialIndex = INVALID_MATERIAL;
  }

  unsigned int NumIndices;
  unsigned int BaseVertex;
  unsigned int BaseIndex;
  unsigned int ReferenceId;
  unsigned int MaterialIndex;
  aiNode* node;
};
