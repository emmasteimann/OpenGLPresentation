//
//  GLVertex.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

typedef enum {
  GLVertexAttribPosition = 0,
  GLVertexAttribColor,
  GLVertexAttribTexCoord,
  GLVertexAttribNormal
} GLVertexAttributes;

typedef struct {
  GLfloat Position[3];
  GLfloat Color[4];
  GLfloat TexCoord[2];
  GLfloat Normal[3];
} GLVertex;