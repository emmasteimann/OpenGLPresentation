//
//  GLViewController.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationGLView.h"

@interface GLViewController : NSViewController <PresentationGLViewDelegate>
- (void)nextPage;
- (void)previousPage;
@end
