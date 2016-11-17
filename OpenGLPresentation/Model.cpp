#include "model.hpp"
#include <SDL/SDL.h>
#include "Camera.hpp"
#include "Light.hpp"
#include "Animator.hpp"
#include "Shader.hpp"
#include <assimp/vector3.h>
#include <OpenGL/gl3.h>
#include <OpenGL/glu.h>

enum VB_TYPES {
  INDEX_BUFFER,
  POS_VB,
  NORMAL_VB,
  TEXCOORD_VB,
  BONE_VB,
  NUM_VBs
};

typedef enum {
  VertexAttribPosition = 0,
  VertexAttribColor
} VertexAttributes;

typedef struct {
  GLfloat Position[3];
  GLfloat Color[4];
} Vertex;

#define POSITION_LOCATION    0
#define TEX_COORD_LOCATION   1
#define NORMAL_LOCATION      2
#define BONE_ID_LOCATION     3
#define BONE_WEIGHT_LOCATION 4

static const char* s_sShaderVertSource = "#version 330 core\n"
"\n"
"uniform mat4 projectionMatrix;\n"
"uniform mat4 viewMatrix;\n"
"uniform mat4 modelMatrix;\n"
"\n"
"in vec4 inPosition;\n"
"in vec3 inNormal;\n"
"in vec4 inColor;\n"
"\n"
//"out vec4 worldPosition;\n"
//"out vec3 worldNormal;\n"
"out vec4 outColor;\n"
//"out vec2 outTexCoord;\n"
"\n"
"void main()\n"
"{\n"
//"  vec4 newNormal = vec4(inNormal, 0.0);\n"
//"	 worldNormal = (modelMatrix * newNormal).xyz;\n"
"\n"
"	 gl_Position = projectionMatrix * viewMatrix * modelMatrix * inPosition;\n"
//"	 worldPosition = modelMatrix * inPosition;\n"
"	 outColor = inColor;\n"
"}\n";

static const char* s_sShaderFragSource = "#version 330 core\n"
"\n"
"uniform vec3 lightPosition;\n"
"uniform vec4 lightAmbientColor;\n"
"uniform vec4 lightDiffuseColor;\n"
"\n"
//"in vec4 worldPosition;\n"
//"in vec3 worldNormal;\n"
"in vec4 outColor;\n"
//"out vec4 outputColor;\n"
"\n"
"void main()\n"
"{\n"
//"	 vec3 normal = normalize(worldNormal);\n"
//"  vec3 position = worldPosition.xyz - worldPosition.w;\n"
//"  vec3 lightVector = normalize(lightPosition);\n"
//"  vec4 fragColor;\n"
"  \n"
"	  outputColor = outColor;\n"
"  \n"
//"  vec4 ambient = fragColor * lightAmbientColor;\n"
//"  vec4 diffuse = fragColor * lightDiffuseColor * max(0.0, dot(normal, lightVector));\n"
//"  \n"
//"	 outputColor = ambient + diffuse;\n"
"}\n";

long g_lLastTime = 0;
long g_lElapsedTime = 0;

Model::Model(std::string sModelPath, glm::vec3 vLightPosition, glm::vec4 vLightAmbientColor,
  glm::vec4 vLightDiffuseColor, GLfloat fCameraDistance, GLfloat fCameraHeight, GLfloat fCameraAngle) {
  m_pShader = NULL;
  m_pScene = NULL;
  m_pAnimator = NULL;
  m_vTextures = NULL;
  m_mModelMatrix = glm::mat4(1.0f);
  m_sModelPath = sModelPath;

  m_pLight = new Light(vLightPosition, vLightAmbientColor, vLightDiffuseColor);
  m_pCamera = new Camera(fCameraDistance, fCameraHeight, fCameraAngle);

  m_mModelMatrix = glm::mat4(1.0f);
}

Model::~Model() {
  if (m_pScene != NULL) {
    aiReleaseImport(m_pScene);
    aiReleasePropertyStore(m_pStore);
  }

  if (m_pShader != NULL) {
    delete m_pShader;
    m_pShader = NULL;
  }

  if (m_vMeshes.size() > 0) {
    for (unsigned int i = 0; i < m_vMeshes.size(); i++) {
      delete m_vMeshes[i];
    }
  }

  for (int i = 0; i < m_iNumMeshes; i++) {
    if (m_vTextures[i] != -1) {
      glDeleteTextures(1, &m_vTextures[i]);
    }
  }

  if (m_vTextures != NULL) {
    delete[] m_vTextures;
  }

  if (m_pAnimator != NULL) {
    delete m_pAnimator;
  }

  if (m_pLight != NULL) {
    delete m_pLight;
    m_pLight = NULL;
  }

  if (m_pCamera != NULL) {
    delete m_pCamera;
    m_pCamera = NULL;
  }
}

bool Model::Init() {
  m_pShader = new Shader(s_sShaderVertSource, s_sShaderFragSource);

  //import the model via Assimp
  m_pStore = aiCreatePropertyStore();
  aiSetImportPropertyInteger(m_pStore, AI_CONFIG_IMPORT_TER_MAKE_UVS, 1);
  aiSetImportPropertyFloat(m_pStore, AI_CONFIG_PP_GSN_MAX_SMOOTHING_ANGLE, 80.0f);
  aiSetImportPropertyInteger(m_pStore, AI_CONFIG_PP_SBP_REMOVE, aiPrimitiveType_LINE | aiPrimitiveType_POINT);

  m_pScene = aiImportFileExWithProperties(m_sModelPath.c_str(),
    aiProcessPreset_TargetRealtime_Quality |
	  aiProcess_FindInstances |
	  aiProcess_ValidateDataStructure |
	  aiProcess_OptimizeMeshes,
    NULL,
    m_pStore);

  if (m_pScene) {
    m_vSceneMin.x = 1e10f;
    m_vSceneMin.y = 1e10f;
    m_vSceneMin.z = 1e10f;
    m_vSceneMax.x = -1e10f;
    m_vSceneMax.y = -1e10f;
    m_vSceneMax.z = -1e10f;

    GetBoundingBox(m_pScene->mRootNode, &m_vSceneMin, &m_vSceneMax);

    m_vSceneCenter.x = (m_vSceneMin.x + m_vSceneMax.x) / 2.0f;
    m_vSceneCenter.y = (m_vSceneMin.y + m_vSceneMax.y) / 2.0f;
    m_vSceneCenter.z = (m_vSceneMin.z + m_vSceneMax.z) / 2.0f;

    m_iNumMeshes = m_pScene->mNumMeshes;

    for (int i = 0; i < m_iNumMeshes; i++) {
      aiMesh* pCurrentMesh = m_pScene->mMeshes[i];
      Mesh* pNewMesh = new Mesh();

      pNewMesh->m_iNumFaces = pCurrentMesh->mNumFaces;
      pNewMesh->m_iNumVertices = pCurrentMesh->mNumVertices;
      pNewMesh->m_iNumBones = pCurrentMesh->mNumBones;
      pNewMesh->m_iMaterialIndex = pCurrentMesh->mMaterialIndex;

      if ((pNewMesh->m_iNumFaces == 0) || (pNewMesh->m_iNumVertices == 0)) {
        continue;
      }

      if (!pCurrentMesh->HasPositions()) {
        std::cerr << "A mesh of the model has no vertices and is not loaded." << std::endl; 

        continue;
      }

      if (!pCurrentMesh->HasNormals()) {
        std::cerr << "A mesh of the model has no normals and is not loaded." << std::endl; 

        continue;
      }

      if (!pCurrentMesh->HasFaces()) {
        std::cerr << "A mesh of the model has no polygon faces and is not loaded." << std::endl; 

        continue;
      }

      m_vMeshes.push_back(pNewMesh);

      pNewMesh->m_pVertices = new glm::vec4[pNewMesh->m_iNumVertices];
      pNewMesh->m_pNormals = new glm::vec3[pNewMesh->m_iNumVertices];
      pNewMesh->m_pColors = new glm::vec4[pNewMesh->m_iNumVertices];
      pNewMesh->m_pTexCoords = new glm::vec2[pNewMesh->m_iNumVertices];
      pNewMesh->m_pIndices = new GLint[pNewMesh->m_iNumFaces * 3];
      pNewMesh->m_pBoneIndices = new glm::vec4[pNewMesh->m_iNumVertices];
      pNewMesh->m_pWeights = new glm::vec4[pNewMesh->m_iNumVertices];

      for (int j = 0; j < pNewMesh->m_iNumVertices; j++) {
        pNewMesh->m_pVertices[j].x = pCurrentMesh->mVertices[j].x;
        pNewMesh->m_pVertices[j].y = pCurrentMesh->mVertices[j].y;
        pNewMesh->m_pVertices[j].z = pCurrentMesh->mVertices[j].z;
        pNewMesh->m_pVertices[j].w = 1.0f;

        pNewMesh->m_pNormals[j].x = pCurrentMesh->mNormals[j].x;
        pNewMesh->m_pNormals[j].y = pCurrentMesh->mNormals[j].y;
        pNewMesh->m_pNormals[j].z = pCurrentMesh->mNormals[j].z;

        pNewMesh->m_pColors[j].r = 0.0;
        pNewMesh->m_pColors[j].g = 0.0;
        pNewMesh->m_pColors[j].b = 1.0;
        pNewMesh->m_pColors[j].a = 1.0f;
      }

      printf("%s\n", pCurrentMesh->mName.C_Str());
      for (int j = 0; j < pNewMesh->m_iNumFaces; j++) {
        printf("index %d: {%d, %d, %d}\n", j, pCurrentMesh->mFaces[j].mIndices[0], pCurrentMesh->mFaces[j].mIndices[1], pCurrentMesh->mFaces[j].mIndices[2]);
        pNewMesh->m_pIndices[j * 3] = pCurrentMesh->mFaces[j].mIndices[0];
        pNewMesh->m_pIndices[j * 3 + 1] = pCurrentMesh->mFaces[j].mIndices[1];
        pNewMesh->m_pIndices[j * 3 + 2] = pCurrentMesh->mFaces[j].mIndices[2];
      }
    }

  }
  else {
    std::cerr << "Loading model failed." << std::endl;

    return false;
  }

  float fScale = GetScaleFactor();

//  m_mModelMatrix = glm::scale(glm::mat4(1.0f), glm::vec3(fScale, fScale, fScale));
  m_mModelMatrix = glm::translate(m_mModelMatrix, glm::vec3(0.0f, 0.0f, 0.0f));
//  m_mModelMatrix = glm::mat4(1.0f);
  return true;
}

GLfloat Model::GetScaleFactor() const {
  GLfloat fXDistance = sqrt(m_vSceneMax.x * m_vSceneMax.x + m_vSceneMin.x * m_vSceneMin.x);
  GLfloat fYDistance = sqrt(m_vSceneMax.y * m_vSceneMax.y + m_vSceneMin.y * m_vSceneMin.y);
  GLfloat fZDistance = sqrt(m_vSceneMax.z * m_vSceneMax.z + m_vSceneMin.z * m_vSceneMin.z);
  GLfloat fScale = sqrt(fXDistance * fXDistance + fYDistance * fYDistance + fZDistance * fZDistance);

  return 1.0f / fScale;
}

void Model::GetBoundingBox(const struct aiNode* pNode, aiVector3D* pMin, aiVector3D* pMax) {
  for (unsigned int n = 0; n < pNode->mNumMeshes; n++) {
    const struct aiMesh* pMesh = m_pScene->mMeshes[pNode->mMeshes[n]];

    for (unsigned int t = 0; t < pMesh->mNumVertices; t++) {
      aiVector3D vTmp = pMesh->mVertices[t];

      if (pMin->x > vTmp.x) {
        pMin->x = vTmp.x;
      }

      if (pMin->y > vTmp.y) {
        pMin->y = vTmp.y;
      }

      if (pMin->z > vTmp.z) {
        pMin->z = vTmp.z;
      }

      if (pMax->x < vTmp.x) {
        pMax->x = vTmp.x;
      }

      if (pMax->y < vTmp.y) {
        pMax->y = vTmp.y;
      }

      if (pMax->z < vTmp.z) {
        pMax->z = vTmp.z;
      }
    }
  }

  for (unsigned int m = 0; m < pNode->mNumChildren; m++) {
    GetBoundingBox(pNode->mChildren[m], pMin, pMax);
  }
}

bool Model::Draw() {
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  m_pShader->Bind();

  glUniformMatrix4fv(m_pShader->GetProjectionMatrixLocation(), 1, GL_FALSE, glm::value_ptr(m_pCamera->GetProjectionMatrix()));
  glUniformMatrix4fv(m_pShader->GetViewMatrixLocation(), 1, GL_FALSE, glm::value_ptr(glm::lookAt(glm::vec3(-2, -10, -10), glm::vec3(0,0,0), glm::vec3(0,1,0))));
  glUniformMatrix4fv(m_pShader->GetModelMatrixLocation(), 1, GL_FALSE, glm::value_ptr(glm::mat4(1.0)));
  glUniform3fv(m_pShader->GetLightPositionLocation(), 1, glm::value_ptr(m_pLight->GetPosition()));
  glUniform4fv(m_pShader->GetLightAmbientColorLocation(), 1, glm::value_ptr(m_pLight->GetAmbient()));
  glUniform4fv(m_pShader->GetLightDiffuseColorLocation(), 1, glm::value_ptr(m_pLight->GetDiffuse()));

  if (m_pScene->mRootNode != NULL) {
    RenderNode(m_pScene->mRootNode);
  }

  m_pShader->Unbind();

  return true;
}

void Model::RenderNode(aiNode * pNode) {
  printf("Name: %s\n", pNode->mName.C_Str());
  for (unsigned int i = 0; i < pNode->mNumMeshes; i++) {
    DrawMesh(pNode->mMeshes[i]);
  }

  //render all child nodes
  printf("mesh has this many children: %d\n", pNode->mNumChildren);
  for (unsigned int i = 0; i < pNode->mNumChildren; i++) {
    RenderNode(pNode->mChildren[i]);
  }
}

void Model::DrawMesh(unsigned int uIndex) {
  GLuint _vaob;
  GLuint _indexBuffer;
  GLuint _vertexBuffer;
  Mesh* pMesh = m_vMeshes.at(uIndex);

//
//  glGenVertexArrays(1, &_vaob);
//  glBindVertexArray(_vaob);

  glGenBuffers(1, &_vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  printf("Size of Vertex: %lu\n", sizeof(pMesh->m_pVertices[0]));
  printf("Number of Vertices: %lu\n", sizeof(pMesh->m_pVertices));
  printf("iNum of Vertices: %d\n", pMesh->m_iNumVertices);
  printf("Index Count: %lu\n", sizeof(pMesh->m_iNumFaces) * 3);

  glBufferData(GL_ARRAY_BUFFER, sizeof(pMesh->m_pVertices[0]) * pMesh->m_iNumVertices, pMesh->m_pVertices, GL_STATIC_DRAW);
  glEnableVertexAttribArray(m_pShader->GetVertexLocation());
  glVertexAttribPointer(m_pShader->GetVertexLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pVertices);

  for (int i=0; i < pMesh->m_iNumVertices; i++) {
    printf("Vertex (%d) - x:%f, y:%f, z:%f, w:%f\n", i, pMesh->m_pVertices[i].x, pMesh->m_pVertices[i].y, pMesh->m_pVertices[i].z, pMesh->m_pVertices[i].w);
  }

  glGenBuffers(1, &_indexBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, pMesh->m_iNumFaces * 3 * sizeof(GLint), pMesh->m_pIndices, GL_STATIC_DRAW);

  for (int i=0; i < sizeof(pMesh->m_pIndices); i++) {
    printf("Index- %d\n", pMesh->m_pIndices[i]);
  }

  glEnableVertexAttribArray(m_pShader->GetColorLocation());
  glVertexAttribPointer(m_pShader->GetColorLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pColors);

  printf("Drawing...\n\n");
  printf("Number of faces: %d\n", pMesh->m_iNumFaces);

//  glBindVertexArray(_vao);
  glDrawElements(GL_TRIANGLES, pMesh->m_iNumFaces * 3, GL_UNSIGNED_INT, pMesh->m_pIndices);
//  glBindVertexArray(0);
}