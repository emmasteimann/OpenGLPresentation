//
//  GLBaseEffect+Protected.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/25/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//
@interface GLBaseEffect (Protected)
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;
@end