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

class Cat
{
  public:
  Cat();
  ~Cat();
  void glBlue();
};

Cat::Cat() {}
void Cat::glBlue() {
//  printf("running...\n\n\n\n");
  glClearColor(0, 0, 1.0, 1);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}
Cat::~Cat(){}

@interface GLViewController ()

@end

@implementation GLViewController {
  GLBaseEffect *_shader;
  GLScene *_scene;
  Model* g_pModel;
}

- (void)setupScene {
  [GLDirector sharedInstance].view = self.view;
//
//  NSBundle *bundle = [NSBundle mainBundle];
//  NSString *path = [bundle pathForResource:@"cube" ofType:@"dae"];
//  const char *cPath =[path cStringUsingEncoding: NSUTF8StringEncoding];
//  std::string sModelPath = cPath; //add the path to the model
//
//  g_pModel = new Model(sModelPath,
//                       glm::vec3(500.0, 30.0, 50.0), //light position
//                       glm::vec4(0.6f, 0.6f, 0.56f, 1.0f), //ambient light color
//                       glm::vec4(0.75f, 0.75f, 0.68f, 1.0f), //diffuse light color
//                       2.0f, //camera distance
//                       0.0f, //camera height
//                       0.0f); //camera angle
//  g_pModel->Init();

//  if (g_pModel->Init()) {
//    while (true) {
//      if ((g_pModel == NULL) || (!g_pModel->Draw())) {
//        break;
//      }
//    }
//  }

//  delete g_pModel;
  //
    _shader = [[GLBaseEffect alloc] initWithVertexShader:@"GLSimpleVertex.glsl" fragmentShader:@"GLSimpleFragment.glsl"];

  _scene = [[GLScene alloc] initWithShader:_shader];

  // Orthographic projection
//  _shader.projectionMatrix = GLKMatrix4MakeOrtho(-self.view.bounds.size.width/16, self.view.bounds.size.width/16, -self.view.bounds.size.height/16, self.view.bounds.size.height/16, -100, 100);
// Perspective Projection
  _shader.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(85.0), self.view.bounds.size.width/self.view.bounds.size.height, 1, 150);

  [GLDirector sharedInstance].scene = _scene;
  [GLDirector sharedInstance].sceneProjectionMatrix = _shader.projectionMatrix;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    PresentationGLView *view = (PresentationGLView *)self.view;
    [view setDelegate:self];
    [self setupScene];
}

- (void)updateGLView:(NSTimeInterval)deltaTime {
//  Cat Kitty;
//  Kitty.glBlue();
//  g_pModel->Draw();
  GLKMatrix4 viewMatrix = GLKMatrix4Identity;
  [_scene updateWithDelta:deltaTime];
  [[GLDirector sharedInstance].scene renderWithParentModelViewMatrix:viewMatrix];
}
@end




