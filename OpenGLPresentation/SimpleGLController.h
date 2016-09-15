//
//  SimpleGLController.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/15/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SimplePresentationGLView.h"

@interface SimpleGLController : NSViewController <SimplePresentationGLViewDelegate>
-(void)loadColorShader;
-(void)backToWhite;
@end
