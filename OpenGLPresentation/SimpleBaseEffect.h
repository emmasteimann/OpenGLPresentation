#import <Foundation/Foundation.h>
#include <GLKit/GLKit.h>

@interface SimpleBaseEffect : NSObject

@property (nonatomic, assign) GLuint programHandle;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;

- (id)initWithVertexShader:(NSString *)vertexShader
            fragmentShader:(NSString *)fragmentShader;
- (void)prepareToDraw;
@end
