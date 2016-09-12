//
//  SceneKitController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/6/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "SceneKitController.h"
@import SceneKit;
@import GLKit;

@interface SceneKitController ()
@property (weak) IBOutlet SCNView *scnView;
@end

@implementation SceneKitController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scnView.scene = [[SCNScene alloc] init];
    SCNScene *emmaScene = [SCNScene sceneNamed:@"walking.dae"];
  for (SCNNode *node in emmaScene.rootNode.childNodes){
    NSLog(@"Name: %@", node.name);
  }
    SCNNode *emmaWave = [emmaScene.rootNode childNodeWithName:@"TeamFlareAdminF"
                                                            recursively:YES];

//    emmaWave.eulerAngles = SCNVector3Make(0, M_PI/2, 0);
//    emmaWave.rotation = SCNVector4Make(0, 0, 0, 0);

    [self.scnView.scene.rootNode addChildNode:emmaWave];


    SCNLight *light = [[SCNLight alloc] init];
    light.type = SCNLightTypeDirectional;

//    light.castsShadow = YES;
    emmaWave.light = light;


    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.zFar = 200;
    cameraNode.camera.zNear = 0.1;

    cameraNode.position = SCNVector3Make(5,8,1);
//    cameraNode.eulerAngles = SCNVector3Make(0, 0, -M_PI/2);
    SCNLookAtConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:emmaWave];
    constraint.gimbalLockEnabled = YES;
    [cameraNode setConstraints:@[constraint]];
    [self.scnView.scene.rootNode addChildNode:cameraNode];


    NSURL          *sceneURL        = [[NSBundle mainBundle] URLForResource:@"emma" withExtension:@"dae"];
    SCNSceneSource *sceneSource     = [SCNSceneSource sceneSourceWithURL:sceneURL options:nil];
    NSArray *entries = [sceneSource identifiersOfEntriesWithClass:[CAAnimation class]];
    for (NSString *entry in entries) {
      CAAnimation    *animationObject = [sceneSource entryWithIdentifier:entry withClass:[CAAnimation class]];
      [_scnView.scene.rootNode addAnimation:animationObject forKey:entry];
    }

}

@end
