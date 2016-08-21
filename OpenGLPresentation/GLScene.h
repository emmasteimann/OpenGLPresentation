//
//  GLScene.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLNode.h"
#import "GLBaseEffect.h"

@interface GLScene : GLNode
- (instancetype)initWithShader:(GLBaseEffect *)shader;
@end
