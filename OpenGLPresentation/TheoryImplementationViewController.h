//
//  TheoryImplementationViewController.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/14/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TheoryImplementationViewController : NSViewController
@property (nonatomic, assign) int currentPage;
- (void)nextPage;
- (void)previousPage;
@end
