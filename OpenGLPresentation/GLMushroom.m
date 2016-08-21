//
//  GLNode.m
//  GLNode
//
//  Created by Emma Steimann on 08/19/16.
//

#import "GLMushroom.h"
#import "mushroom.h"

@implementation GLMushroom

- (instancetype)initWithShader:(GLBaseEffect *)shader {
  if ((self = [super initWithName:"mushroom" shader:shader vertices:(GLVertex*) Mushroom_Cylinder_mushroom_Vertices vertexCount:sizeof(Mushroom_Cylinder_mushroom_Vertices) / sizeof(Mushroom_Cylinder_mushroom_Vertices[0])])) {
    
    [self loadTexture:@"mushroom.png"];
    self.rotationY = M_PI;
    self.rotationX = M_PI_2;
//    self.scale = 0.5;  
  }
  return self;
}

- (void)updateWithDelta:(NSTimeInterval)dt {
  self.rotationZ += M_PI * dt;
//  self.position = GLKVector3Make(self.position.x, self.position.y + dt, self.position.z);
}

@end
