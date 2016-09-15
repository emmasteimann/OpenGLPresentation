//
//  SplitKeyView.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/14/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SplitKeyView.h"

@implementation SplitKeyView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (BOOL)acceptsFirstResponder {
  return YES;
}
- (BOOL)performKeyEquivalent:(NSEvent *)event {
  return YES;
}

@end
