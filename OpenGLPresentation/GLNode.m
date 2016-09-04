//
//  GLNode.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLNode.h"
#import "GLBaseEffect.h"

@implementation GLNode {
  char *_name;
  GLuint _vao;
  GLuint _vertexBuffer;
  GLuint _indexBuffer;
  unsigned int _vertexCount;
  unsigned int _indexCount;
  GLBaseEffect *_shader;
}

- (instancetype)initWithName:(char *)name shader:(GLBaseEffect *)shader vertices:(GLVertex *)vertices vertexCount:(unsigned int)vertexCount {
  return [self initWithName:name shader:shader vertices:vertices vertexCount:vertexCount inidices:nil indexCount:0];
}

- (instancetype)initWithName:(char *)name shader:(GLBaseEffect *)shader vertices:(GLVertex *)vertices vertexCount:(unsigned int)vertexCount inidices:(GLubyte *)indices indexCount:(unsigned int)indexCount {
  if ((self = [super init])) {

    _name = name;
    _vertexCount = vertexCount;
    _indexCount = indexCount;
    _shader = shader;
    
    self.position = GLKVector3Make(0, 0, 0);
    self.rotationX = 0;
    self.rotationY = 0;
    self.rotationZ = 0;
    self.scale = 1.0;
    self.children = [NSMutableArray array];
    self.matColor = GLKVector4Make(1, 1, 1, 1);

    // Bind current vertices
    glGenVertexArrays(1, &_vao);
    glBindVertexArray(_vao);

    // Generate vertex buffer
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, vertexCount * sizeof(GLVertex), vertices, GL_STATIC_DRAW);

    if (_indexCount > 0) {
      // Generate index buffer
      glGenBuffers(1, &_indexBuffer);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(GLubyte), indices, GL_STATIC_DRAW);
    }

    // Enable vertex attributes
    glEnableVertexAttribArray(GLVertexAttribPosition);
    glVertexAttribPointer(GLVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, Position));

    glEnableVertexAttribArray(GLVertexAttribColor);
    glVertexAttribPointer(GLVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, Color));

    glEnableVertexAttribArray(GLVertexAttribTexCoord);
    glVertexAttribPointer(GLVertexAttribTexCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, TexCoord));

    glEnableVertexAttribArray(GLVertexAttribNormal);
    glVertexAttribPointer(GLVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, Normal));


    // Unbind by binding to nothing
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  }
  return self;
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

- (void)renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix {

  GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, [self modelMatrix]);
  for (id child in self.children) {
//    NSLog(@"%@", child);
    if ([child respondsToSelector:@selector(renderWithParentModelViewMatrix:)]) {
      [child renderWithParentModelViewMatrix:modelViewMatrix];
    }
  }

  _shader.modelViewMatrix = modelViewMatrix;
  _shader.texture = self.texture;
  _shader.matColor = self.matColor;
  [_shader prepareToDraw];

  glBindVertexArray(_vao);
  if (_indexCount > 0) {
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, 0);
  } else {
    glDrawArrays(GL_TRIANGLES, 0, _vertexCount);
//    glPointSize(5);
//    glDrawArrays(GL_POINTS, 0, _vertexCount);
  }
  glBindVertexArray(0);

}

- (void)updateWithDelta:(NSTimeInterval)dt {
  for (GLNode *child in self.children) {
    [child updateWithDelta:dt];
  }
}

- (void)loadTexture:(NSString *)filename {
  NSError *error = nil;
  NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];

  NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft: @YES };
//  NSLog(@"GL Error = %u", glGetError());
  GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
  if (info == nil) {
    NSLog(@"Error loading file: %@", error.localizedDescription);
  } else {
    self.texture = info.name;
  }
}

- (CGRect)boundingBoxWithModelViewMatrix:(GLKMatrix4)parentModelViewMatrix {

  GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(parentModelViewMatrix, [self modelMatrix]);

  GLKVector4 lowerLeft = GLKVector4Make(-self.width/2, -self.height/2, 0, 1);
  lowerLeft = GLKMatrix4MultiplyVector4(modelViewMatrix, lowerLeft);
  GLKVector4 upperRight = GLKVector4Make(self.width/2, self.height/2, 0, 1);
  upperRight = GLKMatrix4MultiplyVector4(modelViewMatrix, upperRight);

  CGRect boundingBox = CGRectMake(lowerLeft.x, lowerLeft.y, upperRight.x - lowerLeft.x, upperRight.y - lowerLeft.y);
  return boundingBox;

}

@end
