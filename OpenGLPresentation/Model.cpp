#include "model.hpp"
#include <SDL/SDL.h>
#include "Camera.hpp"
#include "Light.hpp"
#include "Animator.hpp"
#include "Shader.hpp"
#include <assimp/vector3.h>
#include <OpenGL/gl3.h>
#include <OpenGL/glu.h>

static const char* s_sShaderVertSource = "#version 330 core\n"
"\n"
"uniform mat4 projectionMatrix;\n"
"uniform mat4 viewMatrix;\n"
"uniform mat4 modelMatrix;\n"
"uniform mat4 boneMatrices[60];\n"
"\n"
"in vec4 inPosition;\n"
"in vec3 inNormal;\n"
"in vec4 inColor;\n"
"in vec2 inTexCoord;\n"
"in vec4 inBoneWeights;\n"
"in vec4 inBoneIndices;\n"
"\n"
"out vec4 worldPosition;\n"
"out vec3 worldNormal;\n"
"out vec4 outColor;\n"
"out vec2 outTexCoord;\n"
"\n"
"void main()\n"
"{\n"
"  vec4 boneWeights = inBoneWeights;\n"
"  boneWeights.w = 1.0 - dot(boneWeights.xyz, vec3(1.0, 1.0, 1.0));\n"
"\n"
"  mat4 transformMatrix = boneWeights.x * boneMatrices[int(inBoneIndices.x)];\n"
"  transformMatrix += boneWeights.y * boneMatrices[int(inBoneIndices.y)];\n"
"  transformMatrix += boneWeights.z * boneMatrices[int(inBoneIndices.z)];\n"
"  transformMatrix += boneWeights.w * boneMatrices[int(inBoneIndices.w)];\n"
"\n"
"  vec4 newPosition = transformMatrix * inPosition;\n"
"  vec4 newNormal = transformMatrix * vec4(inNormal, 0.0);\n"
"	 worldNormal = (modelMatrix * newNormal).xyz;\n"
"\n"
"	 gl_Position = projectionMatrix * viewMatrix * modelMatrix * newPosition;\n"
"	 worldPosition = modelMatrix * newPosition;\n"
"	 outColor = inColor;\n"
"	 outTexCoord = inTexCoord;\n"
"}\n";

static const char* s_sShaderFragSource = "#version 330 core\n"
"\n"
"uniform vec3 lightPosition;\n"
"uniform vec4 lightAmbientColor;\n"
"uniform vec4 lightDiffuseColor;\n"
"uniform int useTexture;\n"
//"uniform sampler2D texture;\n"
"\n"
"in vec4 worldPosition;\n"
"in vec3 worldNormal;\n"
"in vec4 outColor;\n"
"in vec2 outTexCoord;\n"
"out vec4 outputColor;\n"
"\n"
"void main()\n"
"{\n"
"	 vec3 normal = normalize(worldNormal);\n"
"  vec3 position = worldPosition.xyz - worldPosition.w;\n"
"  vec3 lightVector = normalize(lightPosition);\n"
"  vec4 fragColor;\n"
"  \n"
//"  if (useTexture == 0)\n"
//"  {\n"
"	  fragColor = outColor;\n"
//"  } else\n"
//"  {\n"
//"	  fragColor = texture(texture, outTexCoord);\n"
//"  }\n"
"  \n"
"  vec4 ambient = fragColor * lightAmbientColor;\n"
"  vec4 diffuse = fragColor * lightDiffuseColor * max(0.0, dot(normal, lightVector));\n"
"  \n"
"	 outputColor = ambient + diffuse;\n"
"}\n";

//SDL_Surface* g_pSDLSurface = NULL;
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
  if (SDL_Init(SDL_INIT_TIMER) < 0 ) {
    std::cerr << "SDL_Init() failed" << std::endl;

    return false;
  }
//    if (SDL_Init(SDL_INIT_TIMER | SDL_INIT_VIDEO) < 0 ) {
//    std::cerr << "SDL_Init() failed" << std::endl;
//
//    return false;
//  }

//  SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
//  SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
//  SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
//  SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
//  SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
//  SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
//  SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
//  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 1);
//  SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, MULTISAMPLING);
//
//  SDL_WM_SetCaption("AssimpOpenGLDemo", "");
//
//  g_pSDLSurface = SDL_SetVideoMode(WIDTH, HEIGHT, COLORBITS, SDL_OPENGL | SDL_RESIZABLE | SDL_HWSURFACE | SDL_DOUBLEBUF);
//
//  if (g_pSDLSurface == NULL) {
//    std::cerr << "SDL_SetVideoMode() failed" << std::endl;
//
//    return false;
//  }
//
//  GLenum err = glewInit();
//
//  if (GLEW_OK != err) {
//    std::cerr << "glewInit() failed" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_EXT_framebuffer_object")) {
//    std::cerr << "GL_EXT_framebuffer_object not supported" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_EXT_framebuffer_sRGB")) {
//    std::cerr << "GL_EXT_framebuffer_sRGB not supported" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_EXT_vertex_array")) {
//    std::cerr << "GL_EXT_vertex_array not supported" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_ARB_vertex_program")) {
//    std::cerr << "GL_ARB_vertex_program not supported" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_ARB_fragment_program")) {
//    std::cerr << "GL_ARB_fragment_program not supported" << std::endl;
//
//    return false;
//  }
//
//  if (!ExtensionSupported("GL_ARB_vertex_buffer_object")) {
//    std::cerr << "GL_ARB_vertex_buffer_object not supported" << std::endl;
//
//    return false;
//  }
//
//  glEnable(GL_TEXTURE_2D);
//
//  //enable normalization of normals
//  glEnable(GL_NORMALIZE);
//
//  glEnable(GL_BLEND);
//  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//
//  glEnable(GL_LINE_SMOOTH);
//  glEnable(GL_POLYGON_SMOOTH);
//  glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
//  glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
//
//  glEnable(GL_MULTISAMPLE);
//
//  //set polygon mode
//  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL); //polygons filled
//  //glPolygonMode(GL_FRONT_AND_BACK, GL_LINE); //wireframe
//
//  //background color
  glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
//  glClearDepth(1.0f);
//
//  //z-buffer
//  glEnable(GL_DEPTH_TEST);
//  glDepthFunc(GL_LEQUAL);
//
//  //back face culling
//  glFrontFace(GL_CCW);
//  glEnable(GL_CULL_FACE);
//  glCullFace(GL_BACK);
//
//  glViewport(0, 0, WIDTH, HEIGHT);

//  if (CheckErrors()) {
//    return false;
//  }

  m_pShader = new Shader(s_sShaderVertSource, s_sShaderFragSource);

//  if (CheckErrors()) {
//    return false;
//  }

  m_pShader->Bind();

//  if (CheckErrors()) {
//    return false;
//  }

  m_pShader->Unbind();

//  if (CheckErrors()) {
//    return false;
//  }

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

    //load the textures into the vram
    m_vTextures = new GLuint[m_pScene->mNumMaterials];

    struct aiString* sTexturePath = (aiString*) malloc(sizeof(struct aiString));

    for (int i = 0; i < (int) m_pScene->mNumMaterials; i++) {
      m_vTextures[i] = 0;
      aiMaterial* pMat = m_pScene->mMaterials[i];
      aiGetMaterialTexture(pMat, aiTextureType_DIFFUSE, 0, sTexturePath, 0, 0, 0, 0, 0, 0); 
//
//      SDL_Surface* pTex = SDL_LoadBMP(GetFullPath(m_sModelPath, sTexturePath->data).c_str());
//
//      if (pTex) {
//        glGenTextures(1, &m_vTextures[i]);
//        glBindTexture(GL_TEXTURE_2D, m_vTextures[i]);
//
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//
//        gluBuild2DMipmaps(GL_TEXTURE_2D, 3, pTex->w,	pTex->h, GL_BGR, GL_UNSIGNED_BYTE, pTex->pixels);
//      }
//
//      SDL_FreeSurface(pTex);
    }

    free(sTexturePath);

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

        printf("Vertices: x:%f, y:%f, z:%f\n", pNewMesh->m_pVertices[j].x, pNewMesh->m_pVertices[j].y, pNewMesh->m_pVertices[j].z);


        pNewMesh->m_pNormals[j].x = pCurrentMesh->mNormals[j].x;
        pNewMesh->m_pNormals[j].y = pCurrentMesh->mNormals[j].y;
        pNewMesh->m_pNormals[j].z = pCurrentMesh->mNormals[j].z;

        if ((!pCurrentMesh->HasVertexColors(0)) || (pCurrentMesh->mColors[j] == NULL)) {
          if ((pCurrentMesh->mMaterialIndex < m_pScene->mNumMaterials) &&
            (m_pScene->mMaterials[pCurrentMesh->mMaterialIndex] != NULL)) {
              aiMaterial * pCurrentMaterial = m_pScene->mMaterials[pCurrentMesh->mMaterialIndex];
              aiColor4D color(0.5f, 0.5f, 0.5f, 1.0f);
              aiGetMaterialColor(pCurrentMaterial, AI_MATKEY_COLOR_DIFFUSE, &color);

              pNewMesh->m_pColors[j].r = color.r;
              pNewMesh->m_pColors[j].g = color.g;
              pNewMesh->m_pColors[j].b = color.b;
              pNewMesh->m_pColors[j].a = 1.0f;
          }
          else {
            pNewMesh->m_pColors[j].r = 0.5f;
            pNewMesh->m_pColors[j].g = 0.5f;
            pNewMesh->m_pColors[j].b = 0.5f;
            pNewMesh->m_pColors[j].a = 1.0f;
          }
        }
        else {
          pNewMesh->m_pColors[j].r = pCurrentMesh->mColors[j]->r;
          pNewMesh->m_pColors[j].g = pCurrentMesh->mColors[j]->g;
          pNewMesh->m_pColors[j].b = pCurrentMesh->mColors[j]->b;
          pNewMesh->m_pColors[j].a = pCurrentMesh->mColors[j]->a;
        }

        if ((pCurrentMesh->mTextureCoords != NULL) && (pCurrentMesh->mTextureCoords[0] != NULL)) {
            pNewMesh->m_pTexCoords[j].x = pCurrentMesh->mTextureCoords[0][j].x;
            pNewMesh->m_pTexCoords[j].y = 1.0f - pCurrentMesh->mTextureCoords[0][j].y;
        }
        else {
          pNewMesh->m_pTexCoords[j].x = 0.0f;
          pNewMesh->m_pTexCoords[j].y = 0.0f;
        }
      }

      for (int j = 0; j < pNewMesh->m_iNumFaces; j++) {
        pNewMesh->m_pIndices[j * 3] = pCurrentMesh->mFaces[j].mIndices[0];
        pNewMesh->m_pIndices[j * 3 + 1] = pCurrentMesh->mFaces[j].mIndices[1];
        pNewMesh->m_pIndices[j * 3 + 2] = pCurrentMesh->mFaces[j].mIndices[2];
      }

      //read bone indices and weights for bone animation
      std::vector<aiVertexWeight> * vTempWeightsPerVertex = new std::vector<aiVertexWeight>[pCurrentMesh->mNumVertices];

      for (unsigned int j = 0; j < pCurrentMesh->mNumBones; j++) {
        const aiBone * pBone = pCurrentMesh->mBones[j];

        for (unsigned int b = 0; b < pBone->mNumWeights; b++) {
          vTempWeightsPerVertex[pBone->mWeights[b].mVertexId].push_back(aiVertexWeight(j, pBone->mWeights[b].mWeight));
        }
      }

      for (int j = 0; j < pNewMesh->m_iNumVertices; j++) {
        pNewMesh->m_pBoneIndices[j] = glm::uvec4(0, 0, 0, 0);
        pNewMesh->m_pWeights[j] = glm::vec4(0.0f, 0.0f, 0.0f, 0.0f);

        if (pCurrentMesh->HasBones()) {
          if (vTempWeightsPerVertex[j].size() > 4) {
            std::cerr << "The model has invalid bone weights and is not loaded." << std::endl;

            return false;
          }

          for (unsigned int k = 0; k < vTempWeightsPerVertex[j].size(); k++) {
            pNewMesh->m_pBoneIndices[j][k] = (GLfloat) vTempWeightsPerVertex[j][k].mVertexId;
            pNewMesh->m_pWeights[j][k] = (GLfloat) vTempWeightsPerVertex[j][k].mWeight;
          }
        }
      }

      if (vTempWeightsPerVertex != NULL) {
        delete[] vTempWeightsPerVertex;
        vTempWeightsPerVertex = NULL;
      }
    }

    if (m_pScene->HasAnimations()) {
      m_pAnimator = new Animator(m_pScene, 0);
    }
  }
  else {
    std::cerr << "Loading model failed." << std::endl;

    return false;
  }

  float fScale = GetScaleFactor();

  m_mModelMatrix = glm::scale(glm::mat4(1.0f), glm::vec3(fScale, fScale, fScale));
  m_mModelMatrix = glm::translate(m_mModelMatrix, glm::vec3(0.0f, -m_vSceneCenter.y, 0.0f));

//  g_lLastTime =151;

  g_lLastTime = SDL_GetTicks();

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

//  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//  glClearColor(0,1,0,1.0);

//  //check for key strokes
//  SDL_PumpEvents();
//  unsigned char* keystate;
//  SDL_Event sdlEvent;
//  int numkeys;
//
//  keystate = SDL_GetKeyState(&numkeys);
//
//  if (keystate[SDLK_ESCAPE])
//  {
//    return false;
//  }
//
//  while (SDL_PollEvent(&sdlEvent))
//  {
//    if (sdlEvent.type == SDL_QUIT)
//    {
//      return false;
//    }
//  }

  //set the bone animation to the specified timestamp
  if (m_pAnimator != NULL) {
//    long lTimeNow = 150;
    long lTimeNow = SDL_GetTicks();
    printf("Time: %ld\n", lTimeNow);
    long lTimeDifference = lTimeNow - g_lLastTime;
    g_lLastTime = lTimeNow;
    g_lElapsedTime += lTimeDifference;

    m_pAnimator->UpdateAnimation(g_lElapsedTime, ANIMATION_TICKS_PER_SECOND);
  }

  m_pShader->Bind();

  //set shader uniforms
  glUniformMatrix4fv(m_pShader->GetProjectionMatrixLocation(), 1, GL_FALSE, glm::value_ptr(m_pCamera->GetProjectionMatrix()));
  glUniformMatrix4fv(m_pShader->GetViewMatrixLocation(), 1, GL_FALSE, glm::value_ptr(m_pCamera->GetViewMatrix()));
  glUniformMatrix4fv(m_pShader->GetModelMatrixLocation(), 1, GL_FALSE, glm::value_ptr(m_mModelMatrix));
  glUniform3fv(m_pShader->GetLightPositionLocation(), 1, glm::value_ptr(m_pLight->GetPosition()));
  glUniform4fv(m_pShader->GetLightAmbientColorLocation(), 1, glm::value_ptr(m_pLight->GetAmbient()));
  glUniform4fv(m_pShader->GetLightDiffuseColorLocation(), 1, glm::value_ptr(m_pLight->GetDiffuse()));

  //draw the model
  if (m_pScene->mRootNode != NULL) {
    RenderNode(m_pScene->mRootNode);
  }

  m_pShader->Unbind();

//  SDL_GL_SwapBuffers();
//  SDL_Delay(10);

  return true;
}

void Model::RenderNode(aiNode * pNode) {
  for (unsigned int i = 0; i < pNode->mNumMeshes; i++) {
    const aiMesh* pCurrentMesh = m_pScene->mMeshes[pNode->mMeshes[i]];
    glm::mat4* pMatrices = new glm::mat4[MAXBONESPERMESH];

    //upload bone matrices
    if ((pCurrentMesh->HasBones()) && (m_pAnimator != NULL)) {
      const std::vector<aiMatrix4x4>& vBoneMatrices = m_pAnimator->GetBoneMatrices(pNode, i);

      if (vBoneMatrices.size() != pCurrentMesh->mNumBones) {
        continue;
      }

      for (unsigned int j = 0; j < pCurrentMesh->mNumBones; j++) {
        if (j < MAXBONESPERMESH) {
          pMatrices[j][0][0] = vBoneMatrices[j].a1;
          pMatrices[j][0][1] = vBoneMatrices[j].b1;
          pMatrices[j][0][2] = vBoneMatrices[j].c1;
          pMatrices[j][0][3] = vBoneMatrices[j].d1;
          pMatrices[j][1][0] = vBoneMatrices[j].a2;
          pMatrices[j][1][1] = vBoneMatrices[j].b2;
          pMatrices[j][1][2] = vBoneMatrices[j].c2;
          pMatrices[j][1][3] = vBoneMatrices[j].d2;
          pMatrices[j][2][0] = vBoneMatrices[j].a3;
          pMatrices[j][2][1] = vBoneMatrices[j].b3;
          pMatrices[j][2][2] = vBoneMatrices[j].c3;
          pMatrices[j][2][3] = vBoneMatrices[j].d3;
          pMatrices[j][3][0] = vBoneMatrices[j].a4;
          pMatrices[j][3][1] = vBoneMatrices[j].b4;
          pMatrices[j][3][2] = vBoneMatrices[j].c4;
          pMatrices[j][3][3] = vBoneMatrices[j].d4;
        }
      }
    }

    //upload the complete bone matrices to the shaders
    glUniformMatrix4fv(m_pShader->GetBoneMatricesLocation(), MAXBONESPERMESH, GL_FALSE, glm::value_ptr(*pMatrices));

    delete[] pMatrices;
     printf("Number of Meshes: %d\n", pNode->mNumMeshes);
    DrawMesh(pNode->mMeshes[i]);
  }

  //render all child nodes

  for (unsigned int i = 0; i < pNode->mNumChildren; i++) {
    RenderNode(pNode->mChildren[i]);
  }
}

void Model::DrawMesh(unsigned int uIndex) {
  printf("Drawing mesh: %d\n", uIndex);
  GLuint _vao;
  GLuint _indexBuffer;
  glGenVertexArrays(1, &_vao);
  glBindVertexArray(_vao);
  Mesh* pMesh = m_vMeshes.at(uIndex);

  glEnableVertexAttribArray(m_pShader->GetVertexLocation());
  glVertexAttribPointer(m_pShader->GetVertexLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pVertices);
//  printf("Vertices: x:%f, y:%f, z:%f\n", pMesh->m_pVertices->x, pMesh->m_pVertices->y, pMesh->m_pVertices->z);
  glEnableVertexAttribArray(m_pShader->GetNormalLocation());
  glVertexAttribPointer(m_pShader->GetNormalLocation(), 3, GL_FLOAT, GL_FALSE, 0, pMesh->m_pNormals);

  glEnableVertexAttribArray(m_pShader->GetBoneWeightsLocation());
  glVertexAttribPointer(m_pShader->GetBoneWeightsLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pWeights);

  glEnableVertexAttribArray(m_pShader->GetBoneIndicesLocation());
  glVertexAttribPointer(m_pShader->GetBoneIndicesLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pBoneIndices);

  glEnableVertexAttribArray(m_pShader->GetTexCoordLocation());
  glVertexAttribPointer(m_pShader->GetTexCoordLocation(), 2, GL_FLOAT, GL_FALSE, 0, pMesh->m_pTexCoords);
  glBindVertexArray(0);

  if (m_vTextures[pMesh->m_iMaterialIndex] != -1)
  {
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_vTextures[pMesh->m_iMaterialIndex]);
    glUniform1i(m_pShader->GetTextureLocation(), 0);
    glUniform1i(m_pShader->GetUseTextureLocation(), 1);
  } else
  {
    glEnableVertexAttribArray(m_pShader->GetColorLocation());
    glVertexAttribPointer(m_pShader->GetColorLocation(), 4, GL_FLOAT, GL_FALSE, 0, pMesh->m_pColors);
    glUniform1i(m_pShader->GetUseTextureLocation(), 0);
  }

  glBindVertexArray(_vao);
//  glDrawArrays(GL_POINTS, 0, pMesh->m_iNumFaces * 3);
//  glBindVertexArray(0);
//  glDrawArrays(GL_POINTS, pMesh->m_iNumFaces * 3, <#GLsizei count#>)
  glGenBuffers(1, &_indexBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, pMesh->m_iNumFaces * 3 * sizeof(GLubyte), pMesh->m_pIndices, GL_STATIC_DRAW);
  glDrawElements(GL_TRIANGLES, pMesh->m_iNumFaces * 3, GL_UNSIGNED_INT, pMesh->m_pIndices);
}