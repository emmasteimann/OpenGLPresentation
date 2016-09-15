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
#import "GLDirector.h"
#import "SceneKitController.h"
#import "TheoryImplementationViewController.h"
#import "CodeViewViewController.h"
#import "SimpleGLController.h"

@interface PresentationSplitViewController ()
@property (strong, nonatomic) SimpleGLController *simpleGLController;
@property (strong, nonatomic) GLViewController *glController;
@property (strong, nonatomic) PresentationViewController *prezController;
@property (strong, nonatomic) NSViewController *connectDotsViewController;
@property (strong, nonatomic) TheoryImplementationViewController *theoryController;
@property (strong, nonatomic) CodeViewViewController *codeController;
@property (strong, nonatomic) NSSplitViewItem *codeItem;
@property (strong, nonatomic) NSSplitViewItem *simpleGLItem;
@property (strong, nonatomic) NSSplitViewItem *glItem;
@property (strong, nonatomic) NSSplitViewItem *theoryItem;
@property (strong, nonatomic) NSSplitViewItem *connectItem;
@end

@implementation PresentationSplitViewController{
  BOOL _keyIsDown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    _glController = (GLViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"GLViewController"];
    _prezController = (PresentationViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PresentationViewController"];
    _theoryController = (TheoryImplementationViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"TheoryImplementationViewController"];
    _connectDotsViewController = (NSViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"ConnectTheDots"];
    _simpleGLController = (SimpleGLController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"SimpleGLController"];
    _codeController = (CodeViewViewController *)[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"CodeViewViewController"];

    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent *(NSEvent * aEvent) {
      [self keyDown:aEvent];
      return aEvent;
    }];

    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyUpMask handler:^NSEvent *(NSEvent * aEvent) {
      [self keyUp:aEvent];
      return aEvent;
    }];

    _glItem = [NSSplitViewItem splitViewItemWithViewController:_glController];
    _theoryItem = [NSSplitViewItem splitViewItemWithViewController:_theoryController];
    _connectItem = [NSSplitViewItem splitViewItemWithViewController:_connectDotsViewController];
    _simpleGLItem = [NSSplitViewItem splitViewItemWithViewController:_simpleGLController];
    _codeItem = [NSSplitViewItem splitViewItemWithViewController:_codeController];

    [_connectItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];
    [_simpleGLItem setCollapsed:YES];
    [_codeItem setCollapsed:YES];

    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:_prezController]];
    [self addSplitViewItem:_glItem];
    [self addSplitViewItem:_theoryItem];
    [self addSplitViewItem:_connectItem];
    [self addSplitViewItem:_simpleGLItem];
    [self addSplitViewItem:_codeItem];
}

- (void)nextPage {
  [_prezController nextPage];

  NSLog(@"next -> cur. page: %d", [GLDirector sharedInstance].currentPage);
  if([GLDirector sharedInstance].currentPage == 7) {
    _theoryController.currentPage = 0;
  }

  if([GLDirector sharedInstance].currentPage >= 7 && [GLDirector sharedInstance].currentPage <= 10) {
    [_glItem setCollapsed:YES];
    [_theoryItem setCollapsed:NO];
    [_simpleGLItem setCollapsed:YES];
    [_theoryController nextPage];
  }

  if ([GLDirector sharedInstance].currentPage == 11) {
    [_glItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:NO];
    [_simpleGLItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage >= 12 && [GLDirector sharedInstance].currentPage < 20) {
    [_glItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:YES];
    [_simpleGLItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage >= 20 && [GLDirector sharedInstance].currentPage < 24) {
    [_glItem setCollapsed:YES];
    [_simpleGLItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage == 22) {
    [_simpleGLController loadColorShader];
  }

  if ([GLDirector sharedInstance].currentPage >= 24) {
    [_glItem setCollapsed:YES];
    [_simpleGLItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:YES];
    [_codeItem setCollapsed:NO];
    [_codeController updateSlides];
  }

  [self.splitView setPosition:self.view.frame.size.width/2 ofDividerAtIndex:0];
  [self.splitView display];
  [self.splitView layout];
}

- (void)previousPage {

  if ([GLDirector sharedInstance].currentPage < 20) {
    [_simpleGLItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage == 11) {
    [_glItem setCollapsed:YES];
    [_theoryItem setCollapsed:NO];
    [_connectItem setCollapsed:YES];
  }
  if ([GLDirector sharedInstance].currentPage == 12) {
    [_glItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:NO];
  }

  [_prezController previousPage];

  if ([GLDirector sharedInstance].currentPage >= 24) {
    [_codeController updateSlides];
  }

  if ([GLDirector sharedInstance].currentPage < 24) {
    [_codeItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage == 23) {
    [_simpleGLItem setCollapsed:NO];
  }

  NSLog(@"prev -> cur. page: %d", [GLDirector sharedInstance].currentPage);
  
  if([GLDirector sharedInstance].currentPage < 7) {

    [_glItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage >= 7 && [GLDirector sharedInstance].currentPage < 10) {
    [_theoryController previousPage];
  }

  if ([GLDirector sharedInstance].currentPage > 12 && [GLDirector sharedInstance].currentPage < 20) {
    [_glItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:YES];
    [_simpleGLItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage == 21) {
    [_simpleGLController backToWhite];
  }

  [self.splitView setPosition:self.view.frame.size.width/2 ofDividerAtIndex:0];
  [self.splitView display];
  [self.splitView layout];
}


#pragma mark - Key Event Delegate Methods

-(void)keyUp:(NSEvent *)theEvent {
  if ([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
    NSString *theArrow = [theEvent charactersIgnoringModifiers];
    unichar keyChar = 0;
    if ( [theArrow length] == 0 )
      return;            // reject dead keys
    if ( [theArrow length] == 1 ) {
      keyChar = [theArrow characterAtIndex:0];
      if ( keyChar == NSLeftArrowFunctionKey ) {
        _keyIsDown = NO;
        return;
      }
      if ( keyChar == NSRightArrowFunctionKey ) {
        _keyIsDown = NO;
        return;
      }
    }
  }
}

-(void)keyDown:(NSEvent *)theEvent {
  if (!_keyIsDown) {
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) { // arrow keys have this mask
      NSString *theArrow = [theEvent charactersIgnoringModifiers];
      unichar keyChar = 0;
      if ( [theArrow length] == 0 )
        return;            // reject dead keys
      if ( [theArrow length] == 1 ) {
        keyChar = [theArrow characterAtIndex:0];
        if ( keyChar == NSLeftArrowFunctionKey ) {
          _keyIsDown = YES;
          [self previousPage];
          return;
        }
        if ( keyChar == NSRightArrowFunctionKey ) {
          _keyIsDown = YES;
          [self nextPage];
          return;
        }
      }
    }
  }
}

- (BOOL)performKeyEquivalent:(NSEvent *)event {
  return YES;
}

@end
