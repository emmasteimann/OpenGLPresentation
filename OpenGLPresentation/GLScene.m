//
//  GLScene.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLScene.h"
#import "GLMushroom.h"

@implementation GLScene{
  CGSize _gameArea;
  float _sceneOffset;
  GLMushroom *_mushroom;
}

- (instancetype)initWithShader:(GLBaseEffect *)shader {

  if ((self = [super initWithName:"GLScene" shader:shader vertices:nil vertexCount:0])) {

    // Create the initial scene position (i.e. camera)
    _gameArea = CGSizeMake(48, 48);
    
    _mushroom = [[GLMushroom alloc] initWithShader:shader];
    _mushroom.position = GLKVector3Make(_gameArea.width/2, _gameArea.height * 0.05, 20);


    _sceneOffset = _gameArea.height/2 / tanf(GLKMathDegreesToRadians(85.0/2));
    self.position = GLKVector3Make(-_gameArea.width/2, -_gameArea.height/2 + 10, -_sceneOffset);
    self.rotationX = GLKMathDegreesToRadians(-20);

    [self.children addObject:_mushroom];



//    // Create the initial scene position (i.e. camera)
//    _gameArea = CGSizeMake(self.width, self.height);
//
//    _mushroom = [[GLMushroom alloc] initWithShader:shader];
//    _mushroom.position = GLKVector3Make(_gameArea.width/2,_gameArea.height/2, 0);
//
//
//    _sceneOffset = _gameArea.height/2 / tanf(GLKMathDegreesToRadians(85.0/2));
//
//    self.position = GLKVector3Make(0, 10, -4);
//
//    GLKMatrix4 lookAtMatrix = GLKMatrix4MakeLookAt(self.position.x, self.position.y, self.position.z, _mushroom.position.x,_mushroom.position.y, _mushroom.position.z, 0, 1, 0);
//
//    shader.modelViewMatrix = GLKMatrix4Multiply(shader.modelViewMatrix, lookAtMatrix);
//
//    [self.children addObject:_mushroom];
  }
  return self;
}

- (void)updateWithDelta:(NSTimeInterval)dt {
  [super updateWithDelta:dt];
}
@end
