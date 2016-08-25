////
////  AssimpMeshEntry.hpp
////  OpenGLPresentation
////
////  Created by Emma Steimann on 8/24/16.
////  Copyright © 2016 Emma Steimann. All rights reserved.
////

#include <GLKit/GLKit.h>
#include <vector>

#define INVALID_UNIFORM_LOCATION 0xffffffff
#define INVALID_OGL_VALUE 0xffffffff
#define INVALID_MATERIAL 0xFFFFFFFF

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
//

struct MeshEntry {
  MeshEntry();

  ~MeshEntry();

  void Init(const std::vector<Vertex>& Vertices,
            const std::vector<unsigned int>& Indices);

  GLuint VB;
  GLuint IB;
  std::vector<Vertex> MeshVertices;
  unsigned long NumIndices;
  unsigned int MaterialIndex;
};

MeshEntry::MeshEntry()
{
  VB = INVALID_OGL_VALUE;
  IB = INVALID_OGL_VALUE;
  NumIndices  = 0;
  MaterialIndex = INVALID_MATERIAL;
};

MeshEntry::~MeshEntry()
{
  if (VB != INVALID_OGL_VALUE)
  {
    glDeleteBuffers(1, &VB);
  }

  if (IB != INVALID_OGL_VALUE)
  {
    glDeleteBuffers(1, &IB);
  }
}


void MeshEntry::Init(const std::vector<Vertex>& Vertices,
                           const std::vector<unsigned int>& Indices)
{
  NumIndices = Indices.size();
  MeshVertices = Vertices;
  
  glGenBuffers(1, &VB);
  glBindBuffer(GL_ARRAY_BUFFER, VB);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * Vertices.size(), &Vertices[0], GL_STATIC_DRAW);

  glGenBuffers(1, &IB);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, IB);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned int) * NumIndices, &Indices[0], GL_STATIC_DRAW);
}