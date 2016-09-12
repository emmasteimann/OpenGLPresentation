//
//  GLAssimpEffect.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "GLBaseEffect.h"
#include <assimp/Importer.hpp>      // C++ importer interface

@interface GLAssimpEffect : GLBaseEffect
- (void)setBoneTransform:(const aiMatrix4x4t<float>&)Transform onIndex:(uint)Index;
- (void)toggleBlackness;
- (void)toggleNormalcy;
@end
