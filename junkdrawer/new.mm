//
//  AssimpMesh.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/22/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//


#import "AssimpMesh.h"
#include "AssimpMeshEntry.hpp"
#import "GLDirector.h"
#import "GLAssimpEffect.hpp"

#include <map>

#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>
#include "Matrix4f.hpp"

#define POSITION_LOCATION    0
#define TEX_COORD_LOCATION   1
#define NORMAL_LOCATION      2
#define BONE_ID_LOCATION     3
#define BONE_WEIGHT_LOCATION 4

#define GLCheckError() (glGetError() == GL_NO_ERROR)

@interface AssimpMesh()
@end

@implementation AssimpMesh {
  std::vector<MeshEntry> m_Entries;
  std::vector<GLKTextureInfo*> m_Textures;
  char *_name;
  GLAssimpEffect *_assimpShader;
  GLuint _vao;
  GLuint m_VAO;
  std::map<std::string,uint> m_BoneMapping;
  uint m_NumBones;
  std::vector<BoneInfo> m_BoneInfo;
  aiMatrix4x4 m_GlobalInverseTransform;
  GLuint m_Buffers[NUM_VBs];
  const aiScene* m_pScene;
  Assimp::Importer m_Importer;
  BOOL _modelFullyLoaded;
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
    _modelFullyLoaded = NO;
    ZERO_MEM(m_Buffers);

    _assimpShader = [[GLAssimpEffect alloc] initWithVertexShader:@"GLSimpleBoneVertex.glsl" fragmentShader:@"GLSimpleBoneFragment.glsl"];

    if ([self loadMeshWithFileName:@"walking" andExtension:@"dae"]) {
      _modelFullyLoaded = YES;
    }
  }
  return self;
}

#pragma mark - Assimp Boiler Plate

- (BOOL)loadMeshWithFileName:(NSString *)fileName andExtension:(NSString *)extension  {

  // should do a Clear here?

  // Create the VAO
  glGenVertexArrays(1, &m_VAO);
  glBindVertexArray(m_VAO);

  // Create the buffers for the vertices attributes
  glGenBuffers(ARRAY_SIZE_IN_ELEMENTS(m_Buffers), m_Buffers);

  BOOL Ret = false;

  Assimp::Importer importer;
  importer.SetExtraVerbose(true);

  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource:fileName ofType:extension];
  const char *cPath =[path cStringUsingEncoding: NSUTF8StringEncoding];

  m_pScene = importer.ReadFile(cPath, aiProcessPreset_TargetRealtime_Quality);

  if (m_pScene) {
    m_GlobalInverseTransform = m_pScene->mRootNode->mTransformation;
    m_GlobalInverseTransform.Inverse();
    Ret = [self initFromScene:m_pScene withFilePath:cPath];
  } else {
    printf("Error parsing '%s': '%s'\n", cPath, importer.GetErrorString());
  }

  glBindVertexArray(0);

  return Ret;
}

- (BOOL)initFromScene:(const aiScene *)pScene withFilePath:(const char *)filePath {
  m_Entries.resize(pScene->mNumMeshes);
  m_Textures.resize(pScene->mNumMaterials);

  std::vector<GLKVector3> Positions;
  std::vector<GLKVector3> Normals;
  std::vector<GLKVector2> TexCoords;
  std::vector<VertexBoneData> Bones;
  std::vector<uint> Indices;

  uint NumVertices = 0;
  uint NumIndices = 0;

  // Count the number of vertices and indices
  for (uint i = 0 ; i < m_Entries.size() ; i++) {
    m_Entries[i].MaterialIndex = pScene->mMeshes[i]->mMaterialIndex;
    m_Entries[i].NumIndices    = pScene->mMeshes[i]->mNumFaces * 3;
    m_Entries[i].BaseVertex    = NumVertices;
    m_Entries[i].BaseIndex     = NumIndices;

    NumVertices += pScene->mMeshes[i]->mNumVertices;
    NumIndices  += m_Entries[i].NumIndices;
  }

  // Reserve space in the vectors for the vertex attributes and indices
  Positions.reserve(NumVertices);
  Normals.reserve(NumVertices);
  TexCoords.reserve(NumVertices);
  Bones.resize(NumVertices);
  Indices.reserve(NumIndices);


  // Initialize the meshes in the scene one by one
  for (unsigned int i = 0 ; i < pScene->mNumMeshes ; i++) {
    const aiMesh* paiMesh = pScene->mMeshes[i];
    [self initMesh:paiMesh withIndex:i andPosition:Positions andNormals:Normals andTex:TexCoords andBones:Bones andIndices:Indices];
  }

  if (![self initMaterials:pScene withFilePath:filePath]) {
    return NO;
  }

  // Generate and populate the buffers with vertex attributes and the indices
  glBindBuffer(GL_ARRAY_BUFFER, m_Buffers[POS_VB]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Positions[0]) * Positions.size(), &Positions[0], GL_STATIC_DRAW);
  glEnableVertexAttribArray(POSITION_LOCATION);
  glVertexAttribPointer(POSITION_LOCATION, 3, GL_FLOAT, GL_FALSE, 0, 0);

  glBindBuffer(GL_ARRAY_BUFFER, m_Buffers[TEXCOORD_VB]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(TexCoords[0]) * TexCoords.size(), &TexCoords[0], GL_STATIC_DRAW);
  glEnableVertexAttribArray(TEX_COORD_LOCATION);
  glVertexAttribPointer(TEX_COORD_LOCATION, 2, GL_FLOAT, GL_FALSE, 0, 0);

  glBindBuffer(GL_ARRAY_BUFFER, m_Buffers[NORMAL_VB]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Normals[0]) * Normals.size(), &Normals[0], GL_STATIC_DRAW);
  glEnableVertexAttribArray(NORMAL_LOCATION);
  glVertexAttribPointer(NORMAL_LOCATION, 3, GL_FLOAT, GL_FALSE, 0, 0);

  glBindBuffer(GL_ARRAY_BUFFER, m_Buffers[BONE_VB]);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Bones[0]) * Bones.size(), &Bones[0], GL_STATIC_DRAW);

  glEnableVertexAttribArray(BONE_ID_LOCATION);
  glVertexAttribIPointer(BONE_ID_LOCATION, 4, GL_INT, sizeof(VertexBoneData), (const GLvoid*) offsetof(VertexBoneData, IDs));
  glEnableVertexAttribArray(BONE_WEIGHT_LOCATION);
  glVertexAttribPointer(BONE_WEIGHT_LOCATION, 4, GL_FLOAT, GL_FALSE, sizeof(VertexBoneData), (const GLvoid*) offsetof(VertexBoneData, Weights));

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_Buffers[INDEX_BUFFER]);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices[0]) * Indices.size(), &Indices[0], GL_STATIC_DRAW);

  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(boneTransformWithTime:) userInfo:nil repeats:YES];
//  [self boneTransformWithTime:[[GLDirector sharedInstance] getRunningTime]];

  return GLCheckError();
}

- (void)initMesh:(const aiMesh*)paiMesh withIndex:(unsigned int)MeshIndex andPosition:(std::vector<GLKVector3> &)Positions andNormals:(std::vector<GLKVector3> &)Normals andTex:(std::vector<GLKVector2> &)TexCoords andBones:(std::vector<VertexBoneData> &)Bones andIndices:(std::vector<uint> &)Indices {
  
  const aiVector3D Zero3D(0.0f, 0.0f, 0.0f);

  // Populate the vertex attribute vectors
  for (uint i = 0 ; i < paiMesh->mNumVertices ; i++) {
    const aiVector3D* pPos      = &(paiMesh->mVertices[i]);
    const aiVector3D* pNormal   = &(paiMesh->mNormals[i]);
    const aiVector3D* pTexCoord = paiMesh->HasTextureCoords(0) ? &(paiMesh->mTextureCoords[0][i]) : &Zero3D;

    Positions.push_back(GLKVector3Make(pPos->x, pPos->y, pPos->z));
    Normals.push_back(GLKVector3Make(pNormal->x, pNormal->y, pNormal->z));
    TexCoords.push_back(GLKVector2Make(pTexCoord->x, pTexCoord->y));
  }
//
//  for (int i=0; i<Positions.size(); i++)
//    printf("Px: %f, Py: %f, Pz: %f", Positions.at(i).x, Positions.at(i).y, Positions.at(i).z);
//  for (int i=0; i<Normals.size(); i++)
//    printf("Nx: %f, Ny: %f, Nz: %f", Normals.at(i).x, Normals.at(i).y, Normals.at(i).z);



  [self loadBones:Bones withMesh:paiMesh andIndex:MeshIndex];

  // Populate the index buffer
  for (uint i = 0 ; i < paiMesh->mNumFaces ; i++) {
    const aiFace& Face = paiMesh->mFaces[i];
    assert(Face.mNumIndices == 3);
    Indices.push_back(Face.mIndices[0]);
    Indices.push_back(Face.mIndices[1]);
    Indices.push_back(Face.mIndices[2]);
  }
}

- (void)loadBones:(std::vector<VertexBoneData>&)Bones withMesh:(const aiMesh*)pMesh andIndex:(uint)MeshIndex {
  for (uint i = 0 ; i < pMesh->mNumBones; i++) {
    uint BoneIndex = 0;
    std::string BoneName(pMesh->mBones[i]->mName.data);

    if (m_BoneMapping.find(BoneName) == m_BoneMapping.end()) {
      // Allocate an index for a new bone
      BoneIndex = m_NumBones;
      m_NumBones++;
      BoneInfo bi;
      m_BoneInfo.push_back(bi);
      m_BoneInfo[BoneIndex].BoneOffset = pMesh->mBones[i]->mOffsetMatrix;
      m_BoneMapping[BoneName] = BoneIndex;
    }
    else {
      BoneIndex = m_BoneMapping[BoneName];
    }

    for (uint j = 0 ; j < pMesh->mBones[i]->mNumWeights ; j++) {
      uint VertexID = m_Entries[MeshIndex].BaseVertex + pMesh->mBones[i]->mWeights[j].mVertexId;
      float Weight  = pMesh->mBones[i]->mWeights[j].mWeight;
      Bones[VertexID].AddBoneData(BoneIndex, Weight);
    }
  }

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

  glBindVertexArray(m_VAO);

  for (unsigned int i = 0 ; i < m_Entries.size() ; i++) {

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

//    printf("Num indices: %d", m_Entries[i].NumIndices);
//    printf("Num indices: %d", m_Entries[i].BaseIndex);
//    printf("Num indices: %d", m_Entries[i].BaseVertex);

    [_assimpShader prepareToDraw];

    glDrawElementsBaseVertex(GL_TRIANGLES,
                             m_Entries[i].NumIndices,
                             GL_UNSIGNED_INT,
                             (void*)(sizeof(uint) * m_Entries[i].BaseIndex),
                             m_Entries[i].BaseVertex);
  }

  glBindVertexArray(0);
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

#pragma mark - Bone Methods

- (uint)findPositionWithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  for (uint i = 0 ; i < pNodeAnim->mNumPositionKeys - 1 ; i++) {
    if (AnimationTime < (float)pNodeAnim->mPositionKeys[i + 1].mTime) {
      return i;
    }
  }

  assert(0);

  return 0;
}

- (uint)findRotationWithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  assert(pNodeAnim->mNumRotationKeys > 0);

  for (uint i = 0 ; i < pNodeAnim->mNumRotationKeys - 1 ; i++) {
    if (AnimationTime < (float)pNodeAnim->mRotationKeys[i + 1].mTime) {
      return i;
    }
  }

  assert(0);

  return 0;
}

- (uint)findScalingWithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  assert(pNodeAnim->mNumScalingKeys > 0);

  for (uint i = 0 ; i < pNodeAnim->mNumScalingKeys - 1 ; i++) {
    if (AnimationTime < (float)pNodeAnim->mScalingKeys[i + 1].mTime) {
      return i;
    }
  }

  assert(0);

  return 0;
}

- (void)calcInterpolatedPositionWithVector:(aiVector3D&)Out WithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  if (pNodeAnim->mNumPositionKeys == 1) {
    Out = pNodeAnim->mPositionKeys[0].mValue;
    return;
  }

  uint PositionIndex = [self findPositionWithTime:AnimationTime withAnimation:pNodeAnim];
  uint NextPositionIndex = (PositionIndex + 1);
  assert(NextPositionIndex < pNodeAnim->mNumPositionKeys);
  float DeltaTime = (float)(pNodeAnim->mPositionKeys[NextPositionIndex].mTime - pNodeAnim->mPositionKeys[PositionIndex].mTime);
  float Factor = (AnimationTime - (float)pNodeAnim->mPositionKeys[PositionIndex].mTime) / DeltaTime;
  assert(Factor >= 0.0f && Factor <= 1.0f);
  const aiVector3D& Start = pNodeAnim->mPositionKeys[PositionIndex].mValue;
  const aiVector3D& End = pNodeAnim->mPositionKeys[NextPositionIndex].mValue;
  aiVector3D Delta = End - Start;
  Out = Start + Factor * Delta;
}

- (void)calcInterpolatedRotationWithQuaternion:(aiQuaternion&)Out WithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  // we need at least two values to interpolate...
  if (pNodeAnim->mNumRotationKeys == 1) {
    Out = pNodeAnim->mRotationKeys[0].mValue;
    return;
  }

  uint RotationIndex = [self findRotationWithTime:AnimationTime withAnimation:pNodeAnim];
  uint NextRotationIndex = (RotationIndex + 1);
  assert(NextRotationIndex < pNodeAnim->mNumRotationKeys);
  float DeltaTime = (float)(pNodeAnim->mRotationKeys[NextRotationIndex].mTime - pNodeAnim->mRotationKeys[RotationIndex].mTime);
  float Factor = (AnimationTime - (float)pNodeAnim->mRotationKeys[RotationIndex].mTime) / DeltaTime;
  assert(Factor >= 0.0f && Factor <= 1.0f);
  const aiQuaternion& StartRotationQ = pNodeAnim->mRotationKeys[RotationIndex].mValue;
  const aiQuaternion& EndRotationQ   = pNodeAnim->mRotationKeys[NextRotationIndex].mValue;
  aiQuaternion::Interpolate(Out, StartRotationQ, EndRotationQ, Factor);
  Out = Out.Normalize();
}


- (void)calcInterpolatedScalingWithVector:(aiVector3D&)Out WithTime:(float)AnimationTime withAnimation:(const aiNodeAnim*)pNodeAnim
{
  if (pNodeAnim->mNumScalingKeys == 1) {
    Out = pNodeAnim->mScalingKeys[0].mValue;
    return;
  }

  uint ScalingIndex = [self findScalingWithTime:AnimationTime withAnimation:pNodeAnim];
  uint NextScalingIndex = (ScalingIndex + 1);
  assert(NextScalingIndex < pNodeAnim->mNumScalingKeys);
  float DeltaTime = (float)(pNodeAnim->mScalingKeys[NextScalingIndex].mTime - pNodeAnim->mScalingKeys[ScalingIndex].mTime);
  float Factor = (AnimationTime - (float)pNodeAnim->mScalingKeys[ScalingIndex].mTime) / DeltaTime;
  assert(Factor >= 0.0f && Factor <= 1.0f);
  const aiVector3D& Start = pNodeAnim->mScalingKeys[ScalingIndex].mValue;
  const aiVector3D& End   = pNodeAnim->mScalingKeys[NextScalingIndex].mValue;
  aiVector3D Delta = End - Start;
  Out = Start + Factor * Delta;
}

- (void)readNodeHeirarchyWithTime:(float)AnimationTime andNode:(const aiNode*)pNode andTransform:(aiMatrix4x4&)ParentTransform
{
  std::string NodeName(pNode->mName.data);

  const aiAnimation* pAnimation = m_pScene->mAnimations[0];

  aiMatrix4x4 NodeTransformation(pNode->mTransformation);

  const aiNodeAnim* pNodeAnim = [self findNodeAnim:pAnimation withNode:NodeName];

  if (pNodeAnim) {
    // Interpolate scaling and generate scaling transformation matrix
    aiVector3D Scaling;
    [self calcInterpolatedScalingWithVector:Scaling WithTime:AnimationTime withAnimation:pNodeAnim];

//    aiMatrix4x4 ScalingM;
//    ScalingM.InitScaleTransform(Scaling.x, Scaling.y, Scaling.z);

    // Interpolate rotation and generate rotation transformation matrix
    aiQuaternion RotationQ;
    [self calcInterpolatedRotationWithQuaternion:RotationQ WithTime:AnimationTime withAnimation:pNodeAnim];
//    aiMatrix4x4 RotationM = Matrix4f(RotationQ.GetMatrix());

    // Interpolate translation and generate translation transformation matrix
    aiVector3D Translation;
    [self calcInterpolatedPositionWithVector:Translation WithTime:AnimationTime withAnimation:pNodeAnim];
//    aiMatrix4x4 TranslationM;
//    TranslationM.InitTranslationTransform(Translation.x, Translation.y, Translation.z);

    // Combine the above transformations
    NodeTransformation = aiMatrix4x4t<float>(Scaling, RotationQ, Translation);
  }

  aiMatrix4x4 GlobalTransformation = ParentTransform * NodeTransformation;

  if (m_BoneMapping.find(NodeName) != m_BoneMapping.end()) {
    uint BoneIndex = m_BoneMapping[NodeName];
    m_BoneInfo[BoneIndex].FinalTransformation = m_GlobalInverseTransform * GlobalTransformation * m_BoneInfo[BoneIndex].BoneOffset;
  }

  for (uint i = 0 ; i < pNode->mNumChildren ; i++) {
    [self readNodeHeirarchyWithTime:AnimationTime andNode:pNode->mChildren[i] andTransform:GlobalTransformation];
  }
}

- (const aiNodeAnim *)findNodeAnim:(const aiAnimation*)pAnimation withNode:(const std::string)NodeName
{
  for (uint i = 0 ; i < pAnimation->mNumChannels ; i++) {
    const aiNodeAnim* pNodeAnim = pAnimation->mChannels[i];

    if (std::string(pNodeAnim->mNodeName.data) == NodeName) {
      return pNodeAnim;
    }
  }

  return NULL;
}

#pragma mark - Crazy Bone Transform Entry Point

- (void)boneTransformWithTime:(float)TimeInSeconds andTransforms:(std::vector<aiMatrix4x4>&)Transforms
{
  aiMatrix4x4 Identity = aiMatrix4x4t<float>();
  NSLog(@"Model is loaded: %@", _modelFullyLoaded ? @"YES": @"NO");
  NSLog(@"# of Animations: %d", m_pScene->mNumAnimations);
  if (m_pScene->HasAnimations()) {
    NSLog(@"Running...");
    float TicksPerSecond = (float)(m_pScene->mAnimations[0]->mTicksPerSecond != 0.0f ? m_pScene->mAnimations[0]->mTicksPerSecond : 25.0f);
    float TimeInTicks = TimeInSeconds * TicksPerSecond;
    float AnimationTime = fmod(TimeInTicks, (float)m_pScene->mAnimations[0]->mDuration);

    [self readNodeHeirarchyWithTime:AnimationTime andNode:m_pScene->mRootNode andTransform:Identity];

    Transforms.resize(m_NumBones);

    for (uint i = 0 ; i < m_NumBones ; i++) {
      Transforms[i] = m_BoneInfo[i].FinalTransformation;
    }
  }
}

- (void)boneTransformWithTime:(float)TimeInSeconds
{
  std::vector<aiMatrix4x4> Transforms;
  [self boneTransformWithTime:TimeInSeconds andTransforms:Transforms];

  for (uint i = 0 ; i < Transforms.size() ; i++) {
    [_assimpShader setBoneTransform:Transforms[i] onIndex:i];
  }


}

@end
