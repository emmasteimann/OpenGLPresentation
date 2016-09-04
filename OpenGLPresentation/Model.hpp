#ifndef MODEL_H
#define MODEL_H

#include "Common.hpp"

class Shader;
class Light;
class Camera;
class Animator;

struct Mesh {
  Mesh() {
    m_pVertices = NULL;
    m_pNormals = NULL;
    m_pColors = NULL;
    m_pTexCoords = NULL;
    m_pWeights = NULL;
    m_pBoneIndices = NULL;
    m_pIndices = NULL;
    m_iMaterialIndex = -1;
    m_iNumFaces = 0;
    m_iNumVertices = 0;
    m_iNumBones = 0;
    m_uTexture = -1;
  }

  ~Mesh() {
    delete[] m_pVertices;
    m_pVertices = NULL;

    delete[] m_pNormals;
    m_pNormals = NULL;

    delete[] m_pColors;
    m_pColors = NULL;

    delete[] m_pTexCoords;
    m_pTexCoords = NULL;

    delete[] m_pBoneIndices;
    m_pBoneIndices = NULL;

    delete[] m_pWeights;
    m_pWeights = NULL;

    delete[] m_pIndices;
    m_pIndices = NULL;
  }

  glm::vec4* m_pVertices;
  glm::vec3* m_pNormals;
  glm::vec4* m_pColors;
  glm::vec2* m_pTexCoords;
  glm::vec4* m_pWeights;
  glm::vec4* m_pBoneIndices;
  int* m_pIndices;
  int m_iMaterialIndex;
  int m_iNumFaces;
  int m_iNumVertices;
  int m_iNumBones;
  unsigned int m_uTexture;
};

class Model {
  public:
    Model(std::string sModelPath, glm::vec3 vLightPosition, glm::vec4 vLightAmbientColor,
      glm::vec4 vLightDiffuseColor, GLfloat fCameraDistance, GLfloat fCameraHeight, GLfloat fCameraAngle);
    ~Model();

    bool Init();
    bool Draw();

  private:
    GLfloat GetScaleFactor() const;
    void GetBoundingBox(const struct aiNode* pNode, aiVector3D* pMin, aiVector3D* pMax);
    void DrawMesh(unsigned int uIndex);
    void RenderNode(aiNode* pNode);

    //parameters for assimp
    const struct aiScene* m_pScene;
    struct aiPropertyStore* m_pStore;
    aiVector3D m_vSceneMin;
    aiVector3D m_vSceneMax;
    aiVector3D m_vSceneCenter;

    //parameters to draw the model
    glm::mat4 m_mModelMatrix;
    std::string m_sModelPath;
    int m_iNumMeshes;
    std::vector<Mesh*> m_vMeshes;
    unsigned int* m_vTextures;
  
    Shader* m_pShader;
    Light* m_pLight;
    Camera* m_pCamera;
    Animator* m_pAnimator;
};

#endif