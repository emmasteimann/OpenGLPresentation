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
  _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width / self.view.bounds.size.height, 0.1, 600);

  [GLDirector sharedInstance].scene = _scene;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PresentationGLView *view = (PresentationGLView *)self.view;
    [view setDelegate:self];
    [self setupScene];
    NSLog(@"setup scene");
}

- (void)updateGLView {
  GLKMatrix4 viewMatrix = GLKMatrix4Identity;
  [[GLDirector sharedInstance].scene renderWithParentModelViewMatrix:viewMatrix];
}

@end
