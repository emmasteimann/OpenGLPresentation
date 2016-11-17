//
//  SimpleGLController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/15/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SimpleGLController.h"
#import "SimplePresentationGLView.h"
#import "SimpleBaseEffect.h"
#import "GLBaseEffect.h"
#import "GLVertex.h"
#import "GLDirector.h"
@interface SimpleGLController ()
@property (nonatomic) float rotationY;
@end

@implementation SimpleGLController {
  GLuint _squareVertexBuffer;
  GLuint _triangleVertexBuffer;
  GLuint _squareIndexBuffer;
  GLuint _cubeVertexBuffer;
  GLuint _cubeIndexBuffer;
  GLsizei _cubeIndexCount;
  SimpleBaseEffect *_shader;
  GLsizei _indexCount;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    SimplePresentationGLView *view = (SimplePresentationGLView *)self.view;
    [view setDelegate:self];
  self.rotationY = 0;

  _shader = [[SimpleBaseEffect alloc] initWithVertexShader:@"SimpleVertexWhite.glsl" fragmentShader:@"SimpleFragmentWhite.glsl"];

  const static GLVertex glVertices[] = {
    {{-1.0, -1.0, 0}}, // A
    {{1.0, -1.0, 0}}, // B
    {{1, 1, 0}}, // C
  };

  const static GLVertex vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}}, // V0
    {{1, 1, 0}, {0, 1, 0, 1}}, // V1
    {{-1, 1, 0}, {0, 0, 1, 1}}, // V2
    {{-1, -1, 0}, {0, 0, 0, 0}} // V3
  };

  const static GLubyte indices[] = {
    0, 1, 2,
    2, 3, 0
  };

  _indexCount = sizeof(indices) / sizeof(indices[0]);

  const static GLVertex cubeVertices[] = {
    // Front
    {{1, -1, 1}, {1, 0, 0, 1}},  // 0
    {{1, 1, 1}, {0, 0, 1, 1}},   // 1
    {{-1, 1, 1}, {0, 1, 0, 1}},  // 2
    {{-1, -1, 1}, {0, 0, 0, 1}}, // 3

    // Back
    {{-1, -1, -1}, {1, 0, 0, 1}}, // 4
    {{-1, 1, -1}, {0, 0, 1, 1}},  // 5
    {{1, 1, -1}, {0, 1, 0, 1}},   // 6
    {{1, -1, -1}, {0, 0, 0, 1}},  // 7
  };

  const static GLubyte cubeIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 5, 6,
    6, 7, 4,
    // Left
    3, 2, 5,
    5, 4, 3,
    // Right
    7, 6, 1,
    1, 0, 7,
    // Top
    1, 6, 5,
    5, 2, 1,
    // Bottom
    3, 4, 7,
    7, 0, 3
  };

  _cubeIndexCount = sizeof(cubeIndices) / sizeof(cubeIndices[0]);

  glGenBuffers(1, &_triangleVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _triangleVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  glGenBuffers(1, &_squareVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _squareVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  glGenBuffers(1, &_squareIndexBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _squareIndexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

  glGenBuffers(1, &_cubeVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
  //
  // Generate index buffer
  glGenBuffers(1, &_cubeIndexBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cubeIndexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW);
}

-(void)loadModelViewProjectionShader {
  _shader = [[SimpleBaseEffect alloc] initWithVertexShader:@"SimpleMVPVertex.glsl" fragmentShader:@"SimpleFragment.glsl"];
  GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(-1, 0, -5);
  GLKMatrix4 modelMatrix = GLKMatrix4Identity;
  modelMatrix = GLKMatrix4Translate(modelMatrix, 1, 1, 1);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, 0, 1, 0, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, 0, 0, 1, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, 0, 0, 0, 1);
  modelMatrix = GLKMatrix4Scale(modelMatrix, 1,1,1);

  GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
  _shader.modelViewMatrix = modelViewMatrix;
  _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width / self.view.bounds.size.height, 1, 150);
}


-(void)loadColorShader {
  _shader = [[SimpleBaseEffect alloc] initWithVertexShader:@"SimpleVertex.glsl" fragmentShader:@"SimpleFragment.glsl"];
}

-(void)backToWhite {

  _shader = [[SimpleBaseEffect alloc] initWithVertexShader:@"SimpleVertexWhite.glsl" fragmentShader:@"SimpleFragmentWhite.glsl"];
}

- (void)spinCube:(NSTimeInterval)deltaTime {
  self.rotationY += M_PI * deltaTime/7;
  GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(-1, 0, -5);
  GLKMatrix4 modelMatrix = GLKMatrix4Identity;
  modelMatrix = GLKMatrix4Translate(modelMatrix, 1, 1, 1);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, 0, 1, 0, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, self.rotationY, 0, 1, 0);
  modelMatrix = GLKMatrix4Rotate(modelMatrix, 0, 0, 0, 1);
  modelMatrix = GLKMatrix4Scale(modelMatrix, 1,1,1);

  GLKMatrix4 modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
  _shader.modelViewMatrix = modelViewMatrix;

}

- (void)updateGLView:(NSTimeInterval)deltaTime {
  glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT);
  GLuint _vao;
  glGenVertexArrays(1, &_vao);
  glBindVertexArray(_vao);
  [_shader prepareToDraw];

  glEnableVertexAttribArray(GLVertexAttribPosition);
  glVertexAttribPointer(GLVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, Position));

  glEnableVertexAttribArray(GLVertexAttribColor);
  glVertexAttribPointer(GLVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(GLVertex), (const GLvoid *) offsetof(GLVertex, Color));

  switch ([[GLDirector sharedInstance] currentView]) {
    case ShowTriangle:
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_CULL_FACE);
      glBindBuffer(GL_ARRAY_BUFFER, _triangleVertexBuffer);
      glDrawArrays(GL_TRIANGLES, 0, 3);
      break;
//    case ShowCube:
//      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//      glEnable(GL_DEPTH_TEST);
//      glEnable(GL_CULL_FACE);
//      glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffer);
//      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cubeIndexBuffer);
//      glDrawElements(GL_TRIANGLES, _cubeIndexCount, GL_UNSIGNED_BYTE, 0);
//      break;
    case SpinCube:
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
      glEnable(GL_DEPTH_TEST);
      glEnable(GL_CULL_FACE);
      [self spinCube:deltaTime];
      glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffer);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cubeIndexBuffer);
      glDrawElements(GL_TRIANGLES, _cubeIndexCount, GL_UNSIGNED_BYTE, 0);
      break;
    default:
      glDisable(GL_DEPTH_TEST);
      glDisable(GL_CULL_FACE);
      glBindBuffer(GL_ARRAY_BUFFER, _squareVertexBuffer);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _squareIndexBuffer);
      glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, 0);
      break;
  }


  glDisableVertexAttribArray(GLVertexAttribPosition);
  glDisableVertexAttribArray(GLVertexAttribColor);
  glBindVertexArray(0);

}
@end
