//
//  OpenGLHelper.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

static void logGLKMatrix(glkMatrix) {
  NSLog(@"glkMatrix:");
  NSLog(@"    %f %f %f %f",glkMatrix.m00,glkMatrix.m01,glkMatrix.m02,glkMatrix.m03);
  NSLog(@"    %f %f %f %f",glkMatrix.m10,glkMatrix.m11,glkMatrix.m12,glkMatrix.m13);
  NSLog(@"    %f %f %f %f",glkMatrix.m20,glkMatrix.m21,glkMatrix.m22,glkMatrix.m23);
  NSLog(@"    %f %f %f %f",glkMatrix.m30,glkMatrix.m31,glkMatrix.m32,glkMatrix.m33);
}