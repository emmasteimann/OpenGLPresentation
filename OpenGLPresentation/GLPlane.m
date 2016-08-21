//
//  GLPlane.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/22/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLPlane.h"
#import "GLVertex.h"

@implementation GLPlane
const static GLVertex vertices[] = {
  {{1, -1, 0}, {1, 0, 0, 1},{1, 0},{1,1,1}}, // V0
  {{1, 1, 0}, {0, 1, 0, 1},{1, 1},{1,1,1}}, // V1
  {{-1, 1, 0}, {0, 0, 1, 1},{0, 1},{1,1,1}}, // V2
  {{-1, -1, 0}, {0, 0, 0, 0},{0, 0},{1,1,1}} // V3
};

const static GLubyte indices[] = {
  0, 1, 2,
  2, 3, 0
};

- (instancetype)initWithShader:(GLBaseEffect *)shader {
  if ((self = [super initWithName:"plane" shader:shader vertices:(GLVertex *)vertices vertexCount:sizeof(vertices)/sizeof(vertices[0]) inidices:(GLubyte *)indices indexCount:sizeof(indices)/sizeof(indices[0])])) {

    [self loadTexture:@"grasslight.png"];
    self.rotationX = -(M_PI / 2);
    self.scale = 50.0f;
  }
  return self;
}

- (void)updateWithDelta:(NSTimeInterval)dt {
//  self.rotationZ += M_PI * dt;
//  self.position = GLKVector3Make(self.position.x, self.position.y - dt, self.position.z);
}

@end
