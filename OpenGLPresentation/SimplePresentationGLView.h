//
//  PresentationGLView.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SimplePresentationGLViewDelegate <NSObject>

-(void)updateGLView:(NSTimeInterval)deltaTime;

@end

@interface SimplePresentationGLView : NSOpenGLView
@property (weak, nonatomic) id<SimplePresentationGLViewDelegate>delegate;
@end
