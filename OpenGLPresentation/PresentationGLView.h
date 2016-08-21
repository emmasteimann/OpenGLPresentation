//
//  PresentationGLView.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PresentationGLViewDelegate <NSObject>

-(void)updateGLView;

@end

@interface PresentationGLView : NSOpenGLView
@property (weak, nonatomic) id<PresentationGLViewDelegate>delegate;
@end
