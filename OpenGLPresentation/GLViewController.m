//
//  GLViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLViewController.h"
#import "PresentationGLView.h"
#import "GLVertex.h"
#import "GLBaseEffect.h"
#import "GLScene.h"
#import "GLDirector.h"
#import "AssimpAccessor.h"

@interface GLViewController ()

@end

@implementation GLViewController {
  GLBaseEffect *_shader;
  GLScene *_scene;
}

- (void)setupScene {
  [GLDirector sharedInstance].view = self.view;

  _shader = [[GLBaseEffect alloc] initWithVertexShader:@"GLSimpleVertex.glsl" fragmentShader:@"GLSimpleFragment.glsl"];

  _scene = [[GLScene alloc] initWithShader:_shader];
  _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
  [[AssimpAccessor alloc] init];
  [GLDirector sharedInstance].scene = _scene;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PresentationGLView *view = (PresentationGLView *)self.view;
    [view setDelegate:self];
    [self setupScene];
}

- (void)updateGLView:(NSTimeInterval)deltaTime {
  GLKMatrix4 viewMatrix = GLKMatrix4Identity;
  [_scene updateWithDelta:deltaTime];
  [[GLDirector sharedInstance].scene renderWithParentModelViewMatrix:viewMatrix];
}

@end
