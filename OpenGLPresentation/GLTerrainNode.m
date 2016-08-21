////
////  GLTerrainNode.m
////  OpenGLPresentation
////
////  Created by Emma Steimann on 8/22/16.
////  Copyright © 2016 Emma Steimann. All rights reserved.
////
//
//#import "GLTerrainNode.h"
//
//@implementation GLTerrainNode
//
//static float SIZE = 800;
//static int VERTEX_COUNT = 128;
//static int count = 16384;
//
//static NSDictionary *generateTerrain() {
//  int count = VERTEX_COUNT * VERTEX_COUNT;
//  float vertices[count * 3];
//  float normals[count * 3];
//  float textureCoords[count*2];
//  int indices[6*(VERTEX_COUNT-1)*(VERTEX_COUNT*1)];
//
//  int vertexPointer = 0;
//  for(int i=0;i<VERTEX_COUNT;i++){
//    for(int j=0;j<VERTEX_COUNT;j++){
//      vertices[vertexPointer*3] = -(float)j/((float)VERTEX_COUNT - 1) * SIZE;
//      vertices[vertexPointer*3+1] = 0;
//      vertices[vertexPointer*3+2] = -(float)i/((float)VERTEX_COUNT - 1) * SIZE;
//      normals[vertexPointer*3] = 0;
//      normals[vertexPointer*3+1] = 1;
//      normals[vertexPointer*3+2] = 0;
//      textureCoords[vertexPointer*2] = (float)j/((float)VERTEX_COUNT - 1);
//      textureCoords[vertexPointer*2+1] = (float)i/((float)VERTEX_COUNT - 1);
//      vertexPointer++;
//    }
//  }
//
//  int pointer = 0;
//  for(int gz=0;gz<VERTEX_COUNT-1;gz++){
//    for(int gx=0;gx<VERTEX_COUNT-1;gx++){
//      int topLeft = (gz*VERTEX_COUNT)+gx;
//      int topRight = topLeft + 1;
//      int bottomLeft = ((gz+1)*VERTEX_COUNT)+gx;
//      int bottomRight = bottomLeft + 1;
//      indices[pointer++] = topLeft;
//      indices[pointer++] = bottomLeft;
//      indices[pointer++] = topRight;
//      indices[pointer++] = topRight;
//      indices[pointer++] = bottomLeft;
//      indices[pointer++] = bottomRight;
//    }
//  }
//
//  return @{ @"vertices": *vertices
//
//
//            };
//
//}
//
//- (instancetype)init {
//  
//  
//  
//  if ((self = [super initWithName:"mushroom" shader:shader vertices:(GLVertex*) Mushroom_Cylinder_mushroom_Vertices vertexCount:sizeof(Mushroom_Cylinder_mushroom_Vertices) / sizeof(Mushroom_Cylinder_mushroom_Vertices[0])])) {
//
//    [self loadTexture:@"mushroom.png"];
//    self.rotationY = M_PI;
//    self.rotationX = M_PI_2;
//    self.scale = 0.5;
//  }
//  return self;
//}
//
//@end
