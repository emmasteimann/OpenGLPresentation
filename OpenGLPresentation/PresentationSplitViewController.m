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

@interface PresentationSplitViewController ()
@property (strong, nonatomic) GLViewController *glController;
@property (strong, nonatomic) PresentationViewController *prezController;
@property (strong, nonatomic) NSViewController *connectDotsViewController;
@property (strong, nonatomic) TheoryImplementationViewController *theoryController;
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

    [_connectItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];

    [self addSplitViewItem:[NSSplitViewItem splitViewItemWithViewController:_prezController]];
    [self addSplitViewItem:_glItem];
    [self addSplitViewItem:_theoryItem];
    [self addSplitViewItem:_connectItem];
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
    [_theoryController nextPage];
  }

  if ([GLDirector sharedInstance].currentPage == 11) {
    [_glItem setCollapsed:YES];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:NO];
  }

  if ([GLDirector sharedInstance].currentPage >= 12) {
    [_glItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
    [_connectItem setCollapsed:YES];
  }

  [self.splitView setPosition:self.view.frame.size.width/2 ofDividerAtIndex:0];
  [self.splitView display];
  [self.splitView layout];
}

- (void)previousPage {
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
  NSLog(@"prev -> cur. page: %d", [GLDirector sharedInstance].currentPage);
  
  if([GLDirector sharedInstance].currentPage < 7) {

    [_glItem setCollapsed:NO];
    [_theoryItem setCollapsed:YES];
  }

  if ([GLDirector sharedInstance].currentPage >= 7 && [GLDirector sharedInstance].currentPage < 10) {
    [_theoryController previousPage];
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
