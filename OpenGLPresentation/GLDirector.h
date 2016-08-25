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

@interface GLDirector : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSView *view;
@property (nonatomic, strong) GLNode *scene;
@property (nonatomic, assign) GLKMatrix4 sceneProjectionMatrix;
@end
