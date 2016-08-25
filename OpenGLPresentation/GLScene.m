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
#import "AssimpMesh.hpp"

@import GLKit;

@interface GLScene ()
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
}

- (instancetype)initWithShader:(GLBaseEffect *)shader {

  if ((self = [super initWithName:"GLScene" shader:shader vertices:nil vertexCount:0])) {
    _shader = shader;

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
    self.skyboxEffect.textureCubeMap.target =
    self.textureInfo.target;
    self.skyboxEffect.xSize = 100.0f;
    self.skyboxEffect.ySize = 100.0f;
    self.skyboxEffect.zSize = 100.0f;


    AssimpMesh *mesh = [[AssimpMesh alloc] initWithName:"test"];
    mesh.position = GLKVector3Make(0, -5, 0);
    [self.children addObject:mesh];
    

    _plane = [[GLPlane alloc] initWithShader:shader];
    _plane.position = GLKVector3Make(0, -15, 0);

    [self.children addObject:_plane];

    _mushroom = [[GLMushroom alloc] initWithShader:shader];
    _mushroom.position = GLKVector3Make(0, -5, 0);
//    [self.children addObject:_mushroom];

    self.initialModelMatrix = GLKMatrix4MakeLookAt(-2, 5, -20, mesh.position.x, mesh.position.y, mesh.position.z, 0, 1, 0);
  }
  return self;
}

- (void)renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix {
  // Draw skybox centered on eye position
//  self.skyboxEffect.center = GLKVector3Make(-2, 0, -5);
//  self.skyboxEffect.transform.projectionMatrix = _shader.projectionMatrix;
//  self.skyboxEffect.transform.modelviewMatrix = [self modelMatrix];
//  [self.skyboxEffect prepareToDraw];
//  glDepthMask(false);
//  [self.skyboxEffect draw];
//  glDepthMask(true);
  [super renderWithParentModelViewMatrix:parentModelViewMatrix];
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

- (void)updateWithDelta:(NSTimeInterval)dt {
  self.rotationY += M_PI * dt/7;
  [super updateWithDelta:dt];
}
@end
