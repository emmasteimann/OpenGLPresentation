//
//  PresentationGLView.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "PresentationGLView.h"
@import GLKit;
//#include <GLUT/glut.h>
#include <OpenGL/gl.h>
//#include <OpenGL/glu.h>

@interface PresentationGLView()
@property (assign) float secsPerFlash;
@end

@implementation PresentationGLView {
  float _curRed;
  CVDisplayLinkRef displayLink;
  NSTimeInterval _dt;
  NSTimeInterval _lastUpdateTime;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.layer.borderWidth = 5.0f;
  self.layer.borderColor = [NSColor blackColor].CGColor;
  _dt = 0.0;
  _lastUpdateTime = 0.0;

//  NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
//  {
//    NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
//    NSOpenGLPFAColorSize, 24,
//    NSOpenGLPFAAlphaSize, 8,
//    NSOpenGLPFADoubleBuffer, NSOpenGLPFADepthSize, 32,
//    0
//  };
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
      NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion4_1Core,
      NSOpenGLPFADoubleBuffer,NSOpenGLPFADepthSize, 64, NSOpenGLPFAMultisample,NSOpenGLPFASampleBuffers, 8, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8,
      0
    };
  NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
  NSOpenGLContext* openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
  [self setOpenGLContext:openGLContext];
  [openGLContext makeCurrentContext];

}
-(void)reshape {
  CGRect frame = self.frame;
  GLsizei width = frame.size.width;
  GLsizei height = frame.size.height;

  // Update the viewport.
  glViewport(0, 0, width, height);
}

-(void)drawRect: (NSRect) bounds
{
 [super drawRect:bounds];
  glClearColor(_curRed, 104.0/255.0, 55.0/255.0, 1.0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_DOUBLEBUFFER);
  glEnable(GL_CULL_FACE);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  [[self openGLContext] update];
}

-(void)drawAnObject
{
  // This only works in legacy mode...
  glColor3f(1.0f, 0.85f, 0.35f);
  glBegin(GL_TRIANGLES);
  {
    glVertex3f(  0.0,  0.6, 0.0);
    glVertex3f( -0.2, -0.3, 0.0);
    glVertex3f(  0.2, -0.3 ,0.0);
  }
  glEnd();
}

- (void)prepareOpenGL
{
  // Synchronize buffer swaps with vertical refresh rate
  GLint swapInt = 1;
  [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];

  // Create a display link capable of being used with all active displays
  CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);

  // Set the renderer output callback function
  CVDisplayLinkSetOutputCallback(displayLink, &renderCallback, (__bridge void *)(self));

  // Set the display link for the current renderer
  CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
  CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
  CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);

  // Activate the display link
  CVDisplayLinkStart(displayLink);
}

static CVReturn renderCallback(CVDisplayLinkRef displayLink,
                               const CVTimeStamp *inNow,
                               const CVTimeStamp *inOutputTime,
                               CVOptionFlags flagsIn,
                               CVOptionFlags *flagsOut,
                               void *displayLinkContext)
{
  // Get time since last refresh
  NSTimeInterval deltaTime = 1.0 / (inOutputTime->rateScalar * (double)inOutputTime->videoTimeScale / (double)inOutputTime->videoRefreshPeriod);

  // Call referring object
  [(__bridge PresentationGLView *)displayLinkContext renderLoop:deltaTime];
  return kCVReturnSuccess;
}

-(void) renderLoop:(NSTimeInterval) deltaTime
{
  [[self openGLContext] makeCurrentContext];

  float secsPerFlash = 2;

  _dt = deltaTime;
  _lastUpdateTime += deltaTime;

  _curRed = (sinf(_lastUpdateTime * 2*M_PI / secsPerFlash) * 0.5) + 0.5;

//  glClearColor(_curRed, 104.0/255.0, 55.0/255.0, 1.0);
  glClearColor(1,0,0,1.0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  [self.delegate updateGLView:deltaTime];

//  [self drawAnObject];

  // Single Buffering
  // glFlush();

  // Note: You no longer call glutSwapBuffers();
  // to Double Buffer, you enable NSOpenGLPFADoubleBuffer on you PixelFormat
  // Attributes and then call
  [[self openGLContext] flushBuffer];

}

-(void)update {
  CGRect frame = self.frame;
  GLsizei width = frame.size.width;
  GLsizei height = frame.size.height;

  // Update the viewport.
  glViewport(0, 0, width, height);
}

@end
