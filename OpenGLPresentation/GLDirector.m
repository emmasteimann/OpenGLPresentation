//
//  GLDirector.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLDirector.h"

@implementation GLDirector {
  CFTimeInterval _startTime;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t pred;
  static GLDirector *_sharedInstance;
  dispatch_once(&pred, ^{ _sharedInstance = [[self alloc] init]; });
  return _sharedInstance;
}

- (instancetype)init {
  if ((self = [super init])) {
    _startTime = CACurrentMediaTime();
  }
  return self;
}

- (CFTimeInterval)getRunningTime {
  return CACurrentMediaTime() - _startTime;
}
@end
