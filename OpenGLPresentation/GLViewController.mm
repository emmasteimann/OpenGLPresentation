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
#import "Model.hpp"
#import "Common.hpp"

@interface GLViewController ()

@end

@implementation GLViewController {
  GLBaseEffect *_shader;
  GLScene *_scene;
  Model* g_pModel;
}

- (void)setupScene {
  [GLDirector sharedInstance].view = self.view;

  NSBundle *bundle = [NSBundle mainBundle];
  NSString *path = [bundle pathForResource:@"walking" ofType:@"dae"];
  const char *cPath =[path cStringUsingEncoding: NSUTF8StringEncoding];
  std::string sModelPath = cPath; //add the path to the model

  g_pModel = new Model(sModelPath,
                       glm::vec3(500.0, 30.0, 50.0), //light position
                       glm::vec4(0.6f, 0.6f, 0.56f, 1.0f), //ambient light color
                       glm::vec4(0.75f, 0.75f, 0.68f, 1.0f), //diffuse light color
                       2.0f, //camera distance
                       0.0f, //camera height
                       0.0f); //camera angle
  g_pModel->Init();

//  if (g_pModel->Init()) {
//    while (true) {
//      if ((g_pModel == NULL) || (!g_pModel->Draw())) {
//        break;
//      }
//    }
//  }

//  delete g_pModel;
  //
  //  _shader = [[GLBaseEffect alloc] initWithVertexShader:@"GLSimpleVertex.glsl" fragmentShader:@"GLSimpleFragment.glsl"];
//
//  _scene = [[GLScene alloc] initWithShader:_shader];
//  _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);
//
//  [GLDirector sharedInstance].scene = _scene;
//  [GLDirector sharedInstance].sceneProjectionMatrix = _shader.projectionMatrix;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PresentationGLView *view = (PresentationGLView *)self.view;
    [view setDelegate:self];
    [self setupScene];
}

- (void)updateGLView:(NSTimeInterval)deltaTime {
  g_pModel->Draw();
//  GLKMatrix4 viewMatrix = GLKMatrix4Identity;
//  [_scene updateWithDelta:deltaTime];
//  [[GLDirector sharedInstance].scene renderWithParentModelViewMatrix:viewMatrix];
}

@end
