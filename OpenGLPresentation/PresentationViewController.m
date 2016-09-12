//
//  PresentationViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "PresentationViewController.h"

@interface PresentationViewController ()
@property (weak) IBOutlet NSTextField *label;
@end

@implementation PresentationViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
  [self.view setWantsLayer:YES];
  [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
//    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.label.font = [NSFont fontWithName:@"Pacifico" size:60];

}
@end
