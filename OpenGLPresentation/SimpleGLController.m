//
//  SimpleGLController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/15/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SimpleGLController.h"
#import "SimplePresentationGLView.h"
#import "RWTBaseEffect.h"
#import "GLBaseEffect.h"
#import "GLVertex.h"
#import "GLDirector.h"
@interface SimpleGLController ()

@end

@implementation SimpleGLController {
  GLuint _squareVertexBuffer;
  GLuint _triangleVertexBuffer;
  GLuint _indexBuffer;
  RWTBaseEffect *_shader;
  GLsizei _indexCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    SimplePresentationGLView *view = (SimplePresentationGLView *)self.view;
    [view setDelegate:self];

  _shader = [[RWTBaseEffect alloc] initWithVertexShader:@"RWTSimpleVertexWhite.glsl" fragmentShader:@"RWTSimpleFragmentWhite.glsl"];

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

  glGenBuffers(1, &_triangleVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _triangleVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

  // Generate vertex buffer
  glGenBuffers(1, &_squareVertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _squareVertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
  // Generate index buffer
  glGenBuffers(1, &_indexBuffer);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);


}

-(void)loadColorShader {
  _shader = [[RWTBaseEffect alloc] initWithVertexShader:@"RWTSimpleVertex.glsl" fragmentShader:@"RWTSimpleFragment.glsl"];
}

-(void)backToWhite {
  _shader = [[RWTBaseEffect alloc] initWithVertexShader:@"RWTSimpleVertexWhite.glsl" fragmentShader:@"RWTSimpleFragmentWhite.glsl"];
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
      glBindBuffer(GL_ARRAY_BUFFER, _triangleVertexBuffer);
      glDrawArrays(GL_TRIANGLES, 0, 3);
      break;
    default:
      glBindBuffer(GL_ARRAY_BUFFER, _squareVertexBuffer);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
      glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, 0);
      break;
  }


  glDisableVertexAttribArray(GLVertexAttribPosition);
  glDisableVertexAttribArray(GLVertexAttribColor);
  glBindVertexArray(0);

}
@end
