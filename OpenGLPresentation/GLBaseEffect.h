//
//  GLBaseEffect.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GLKit;

@interface GLBaseEffect : NSObject
@property (nonatomic, assign) GLuint programHandle;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (assign) GLuint texture;
@property (assign) GLKVector4 matColor;

- (id)initWithVertexShader:(NSString *)vertexShader
            fragmentShader:(NSString *)fragmentShader;
- (void)prepareToDraw;

@end

