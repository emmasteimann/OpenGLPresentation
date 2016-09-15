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
    _currentPage = 0;
  }
  return self;
}

- (CFTimeInterval)getRunningTime {
  return CACurrentMediaTime() - _startTime;
}

- (DesiredView)currentView {
  switch (_currentPage) {
    case 1:
      return ShowDog;
      break;
    case 2:
      return EverythingBlack;
      break;
    case 4:
    case 5:
    case 6:
      return WideShot;
      break;
    case 12:
      return ShowDots;
      break;
    case 13:
      return ShowColorDots;
      break;
    default:
      return ShowEmma;
  }
}

@end
