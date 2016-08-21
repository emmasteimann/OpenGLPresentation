//
//  GLNode.h
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/21/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>
#import "GLVertex.h"

@import GLKit;

@class GLBaseEffect;

@interface GLNode : NSObject

// Basic Attributes For Node
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic) float rotationX;
@property (nonatomic) float rotationY;
@property (nonatomic) float rotationZ;
@property (nonatomic) float scale;
@property (nonatomic) GLuint texture;
@property (assign) GLKVector4 matColor;
@property (assign) float width;
@property (assign) float height;

@property (nonatomic, strong) NSMutableArray *children;
- (instancetype)initWithName:(char *)name shader:(GLBaseEffect *)shader vertices:(GLVertex *)vertices vertexCount:(unsigned int)vertexCount;
- (instancetype)initWithName:(char *)name shader:(GLBaseEffect *)shader vertices:(GLVertex *)vertices vertexCount:(unsigned int)vertexCount inidices:(GLubyte *)indices indexCount:(unsigned int)indexCount;
- (void)renderWithParentModelViewMatrix:(GLKMatrix4)parentModelViewMatrix;
- (void)updateWithDelta:(NSTimeInterval)dt;
- (void)loadTexture:(NSString *)filename;
- (CGRect)boundingBoxWithModelViewMatrix:(GLKMatrix4)parentModelViewMatrix;
@end
