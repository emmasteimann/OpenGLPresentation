//
//  GLDirector.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GLNode;

@interface GLDirector : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, strong) NSView *view;
@property (nonatomic, strong) GLNode *scene;
@end
