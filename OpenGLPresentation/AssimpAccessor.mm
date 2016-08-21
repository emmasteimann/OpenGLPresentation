//
//  Assimp.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/22/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "AssimpAccessor.h"
#include <assimp/Importer.hpp>      // C++ importer interface
#include <assimp/scene.h>           // Output data structure
#include <assimp/postprocess.h>

@implementation AssimpAccessor

-(instancetype)init {
  if (self = [super init]){
    Assimp::Importer importer;
    importer.SetExtraVerbose(true);
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource: @"TeamFlareAdmin" ofType:@"DAE"];
    NSLog(@"%@", path);
//    // now get the c string from the path
//    const char *cPath =[path cStringUsingEncoding: NSUTF8StringEncoding];
//    const aiScene* pScene = importer.ReadFile(cPath, aiProcess_Triangulate | aiProcess_GenSmoothNormals | aiProcess_FlipUVs);
//    NSLog(@"%@",pScene);
  }
  return self;
}

@end
