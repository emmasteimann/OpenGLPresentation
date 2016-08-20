//
//  PresentationSplitViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "PresentationSplitViewController.h"
#import "PresentationViewController.h"
#import "GLViewController.h"

@interface PresentationSplitViewController ()

@end

@implementation PresentationSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    GLViewController *glController = (GLViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"GLViewController"];
    PresentationViewController *prezController = (PresentationViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PresentationViewController"];

    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:prezController]];
    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:glController]];
}

@end
