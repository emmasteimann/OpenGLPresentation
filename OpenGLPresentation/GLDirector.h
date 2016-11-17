//
//  GLDirector.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <GLKit/GLKit.h>
@class GLNode;

typedef enum {
  ShowEmma,
  ShowDog,
  EverythingBlack,
  WideShot,
  ShowDots,
  ShowColorDots,
  ShowWireFrame,
  ShowNormals,
  ShowTriangle,
  ShowSquare,
  ShowCube,
  SpinCube
} DesiredView;

@interface GLDirector : NSObject
+ (instancetype)sharedInstance;
- (CFTimeInterval)getRunningTime;
@property (nonatomic, assign) int currentPage;
@property (nonatomic, assign) int slideCount;
- (DesiredView)currentView;
@property (nonatomic, strong) NSView *view;
@property (nonatomic, strong) GLNode *scene;
@property (nonatomic, assign) GLKMatrix4 sceneProjectionMatrix;
@end
