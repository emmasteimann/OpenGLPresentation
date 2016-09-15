//
//  GLScene.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLScene.h"
#import "GLMushroom.h"
#import "GLPlane.h"
#import "AssimpMesh.h"
#import "GLDirector.h"

@import GLKit;

typedef enum {
  EverythingIsPeachy,
  EverythingWentDark,
  EverythingSpinning
} SceneState;

@interface GLScene ()
@property (assign, nonatomic) SceneState sceneState;
@property (strong, nonatomic) GLKTextureInfo *textureInfo;
@property (strong, nonatomic) GLKSkyboxEffect *skyboxEffect;
@property (strong, nonatomic) GLBaseEffect *shader;
@property (assign, nonatomic) GLKMatrix4 initialModelMatrix;

@end

@implementation GLScene{
  CGSize _gameArea;
  float _sceneOffset;
  GLMushroom *_mushroom;
  GLPlane *_plane;
  AssimpMesh *_mesh;
  AssimpMesh *_k9;
  BOOL _switched;
  NSTimer *_timer;
}

- (instancetype)initWithShader:(GLBaseEffect *)shader {

  if ((self = [super initWithName:"GLScene" shader:shader vertices:nil vertexCount:0])) {
    _sceneState = EverythingIsPeachy;
    _shader = shader;

    _switched = NO;
    // Load cubeMap texture
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"skybox1" ofType:@"png"];
    NSAssert(nil != path, @"Path to skybox image not found");
    NSError *error = nil;
    self.textureInfo = [GLKTextureLoader
                        cubeMapWithContentsOfFile:path
                        options:nil
                        error:&error];


    // Create and configure skybox
    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.textureCubeMap.name = self.textureInfo.name;
    self.skyboxEffect.textureCubeMap.target = self.textureInfo.target;
    self.skyboxEffect.xSize = 100.0f;
    self.skyboxEffect.ySize = 100.0f;
    self.skyboxEffect.zSize = 100.0f;

    _plane = [[GLPlane alloc] initWithShader:shader];
    _plane.position = GLKVector3Make(0, -15, 0);

    [self.children addObject:_plane];

    _mesh = [[AssimpMesh alloc] initWithName:"Emma" andFileName:@"TeamFlareAdmin" andExtenstion:@"DAE"];
    _mesh.position = GLKVector3Make(0, -15, 0);
    _mesh.rotationZ += M_PI;
    _mesh.scale = 0.05;
    [self.children addObject:_mesh];

    _mushroom = [[GLMushroom alloc] initWithShader:shader];
    _mushroom.position = GLKVector3Make(5, -15, -5);
    _mushroom.scale = 0.5;
    [self.children addObject:_mushroom];

    GLMushroom *mushroomA = [[GLMushroom alloc] initWithShader:shader];
    mushroomA.position = GLKVector3Make(-5, -15, 5);
    mushroomA.scale = 0.5;
    [self.children addObject:mushroomA];

    _k9 = [[AssimpMesh alloc] initWithName:"k9" andFileName:@"k9" andExtenstion:@"dae"];
    _k9.position = GLKVector3Make(-5, -15, 0);
    _k9.scale = 0.05;
    _k9.matColor = GLKVector4Make(0.3,0.3,0.3, 1);
    [self.children addObject:_k9];

    // Distance Shot
//    self.initialModelMatrix = GLKMatrix4MakeLookAt(-2, -10, -10, _mesh.position.x, _mesh.position.y, _mesh.position.z, 0, 1, 0);

    // Good for Orthographic projection
//    self.initialModelMatrix = GLKMatrix4MakeLookAt(-2, -10, 0, _mesh.position.x, _mesh.position.y+4.5, _mesh.position.z, 0, 1, 0);

//    Close Up on Emma
    self.initialModelMatrix = GLKMatrix4MakeLookAt(0, -8.5, -3, _mesh.position.x, _mesh.position.y+5.5, _mesh.position.z, 0, 2, 0);

//    Close up on K9
//    self.initialModelMatrix = GLKMatrix4MakeLookAt(-4, -13, -2, _k9.position.x, _k9.position.y+1, _k9.position.z, 0, 2, 0);
//    [self performSelector:@selector(updateBones:)
//               withObject:nil
//               afterDelay:5.0];

  }
  return self;
}

- (void)renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix {
//   Draw skybox centered on eye position
  if (_sceneState != EverythingWentDark) {
    self.skyboxEffect.center = GLKVector3Make(-2, 0, -5);
    self.skyboxEffect.transform.projectionMatrix = _shader.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = [self modelMatrix];
    [self.skyboxEffect prepareToDraw];
    glDepthMask(false);
    [self.skyboxEffect draw];
    glDepthMask(true);
    [super renderWithParentModelViewMatrix:parentModelViewMatrix];
  }
}

- (GLKMatrix4)modelMatrix {
//    GLKMatrix4 modelMatrix = self.initialModelMatrix;
  // Handles Camera Tranformation Matrix, which transform every sub-modelViewMatrix
//  GLKMatrix4 modelMatrix = GLKMatrix4MakeLookAt(-2, 2, -5, _mushroom.position.x, _mushroom.position.y, _mushroom.position.z, 0, 1, 0);
//  return modelMatrix;
  GLKMatrix4 modelMatrix = self.initialModelMatrix;
  modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationX, 1, 0, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationZ, 0, 0, 1);
  modelMatrix = GLKMatrix4Scale(modelMatrix, self.scale, self.scale, self.scale);
  return modelMatrix;
}

- (void)updateBones:(NSTimer*) timer {
//  self.initialModelMatrix = GLKMatrix4MakeLookAt(-4, -13, -2, _k9.position.x, _k9.position.y+1, _k9.position.z, 0, 2, 0);
//  NSLog(@"updating");
//  [_mesh boneTransformWithTime:[[GLDirector sharedInstance] getRunningTime]];
}

- (void)updateWithDelta:(NSTimeInterval)dt {
  _sceneState = EverythingIsPeachy;
  switch ([[GLDirector sharedInstance] currentView]) {
    case ShowDog:
      self.initialModelMatrix = GLKMatrix4MakeLookAt(-4, -13, -2, _k9.position.x, _k9.position.y+1, _k9.position.z, 0, 2, 0);
      self.rotationY = 0;
      break;
    case EverythingBlack:
      self.initialModelMatrix = GLKMatrix4MakeLookAt(-4, -13, -2, _k9.position.x, _k9.position.y+1, _k9.position.z, 0, 2, 0);
      _sceneState = EverythingWentDark;
      break;
    case WideShot:
      self.initialModelMatrix = GLKMatrix4MakeLookAt(-2, -10, -10, _mesh.position.x, _mesh.position.y, _mesh.position.z, 0, 1, 0);
      self.rotationY += M_PI * dt/7;
      _sceneState = EverythingSpinning;
      break;
//    case ShowWireFrame:
//      self.initialModelMatrix = GLKMatrix4MakeLookAt(-2, -10, -10, _mesh.position.x, _mesh.position.y, _mesh.position.z, 0, 1, 0);
//      break;
    default:
      self.initialModelMatrix = GLKMatrix4MakeLookAt(0, -8.5, -3, _mesh.position.x, _mesh.position.y+5.5, _mesh.position.z, 0, 2, 0);
      self.rotationY = 0;
      break;
  }
//  [_mesh boneTransformWithTime:[[GLDirector sharedInstance] getRunningTime]];
//  self.rotationY += M_PI * dt/7;
  [super updateWithDelta:dt];
}
@end
