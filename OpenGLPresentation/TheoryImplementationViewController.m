//
//  TheoryImplementationViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/14/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "TheoryImplementationViewController.h"
@import CoreGraphics;

@interface TheoryImplementationViewController ()
@end

@implementation TheoryImplementationViewController {
  NSView *leftChart;
  NSView *rightChart;
  NSTextView *leftLabel;
  NSTextView *rightLabel;
  BOOL _initialLoad;
  CGFloat centerX;
  CGFloat centerY;
  int _slideCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  [self.view setNeedsDisplay:YES];
  [self.view setNeedsLayout:YES];
  _currentPage = 0;
  _slideCount = 4;
  _initialLoad = YES;
  leftChart = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
  [leftChart setWantsLayer:YES];
  leftChart.layer.backgroundColor = [NSColor colorWithCalibratedRed:30/255.0f green:144/255.0f blue:255/255.0f alpha:1].CGColor;
  [self.view addSubview:leftChart];

  rightChart = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
  [rightChart setWantsLayer:YES];
  rightChart.layer.backgroundColor = [NSColor colorWithCalibratedRed:30/255.0f green:144/255.0f blue:255/255.0f alpha:1].CGColor;
  [self.view addSubview:rightChart];

  leftLabel = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  leftLabel.string = @"Theory";
  [leftLabel setFont:[NSFont fontWithName:@"Avenir" size:16]];
  [leftLabel setDrawsBackground: NO];
  [self.view addSubview:leftLabel];

  rightLabel = [[NSTextView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  rightLabel.string = @"Implementation";
  [rightLabel setFont:[NSFont fontWithName:@"Avenir" size:16]];
  [rightLabel setDrawsBackground: NO];

  [self.view addSubview:rightLabel];

}

-(void)viewWillLayout {
  [super viewWillLayout];
  if (_initialLoad) {
    centerX = (self.view.frame.size.width/2);
    centerY = (self.view.frame.size.height/2);
    [leftChart setFrame:CGRectMake(centerX-150, centerY-100, 100, 50)];
    [rightChart setFrame:CGRectMake(centerX+150, centerY-100, 100, 50)];
    [leftLabel setFrame:CGRectMake(centerX-140, centerY-150, 200, 50)];
    [rightLabel setFrame:CGRectMake(centerX+140, centerY-150, 200, 50)];
    _initialLoad = NO;
  }
}

- (void)nextPage {
  if (_currentPage + 1 <= _slideCount) {
    _currentPage++;
    [self animatePage];
  }
}

- (void)previousPage {
  if (_currentPage - 1 >= 0) {
    _currentPage--;
    [self animatePage];
  }
}

-(void)animatePage {
  NSLog(@"thoery page: %d",_currentPage);
  switch (_currentPage) {
    case 1:
      [self animateDownImplementation];
      [self animateDownTheory];
      break;
    case 2:
      [self animateUpTheory];
      [self animateDownImplementation];
      break;
    case 3:
      [self animateDownTheory];
      [self animateUpImplementation];
      break;
    case 4:
      [self animateWayUp];
      break;
    default:
      [self viewWillLayout];
      break;
  }

}

-(void)animateWayUp {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:2.0f];
  [[rightChart animator] setFrame:CGRectMake(centerX+150, centerY-100, 100, 600)];
  [[leftChart animator] setFrame:CGRectMake(centerX-150, centerY-100, 100, 600)];
  [NSAnimationContext endGrouping];
}

-(void)animateUpImplementation {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:2.0f];
  [[rightChart animator] setFrame:CGRectMake(centerX+150, centerY-100, 100, 200)];
  [NSAnimationContext endGrouping];
}

-(void)animateUpTheory {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:2.0f];
  [[leftChart animator] setFrame:CGRectMake(centerX-150, centerY-100, 100, 200)];
  [NSAnimationContext endGrouping];
}

-(void)animateDownImplementation {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:2.0f];
  [[rightChart animator] setFrame:CGRectMake(centerX+150, centerY-100, 100, 50)];
  [NSAnimationContext endGrouping];
}

-(void)animateDownTheory {
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:2.0f];
  [[leftChart animator] setFrame:CGRectMake(centerX-150, centerY-100, 100, 50)];
  [NSAnimationContext endGrouping];
}

@end
