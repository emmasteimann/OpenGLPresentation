//
//  CodeViewViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 9/16/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "CodeViewViewController.h"
#import "GLDirector.h"
@import WebKit;

@interface CodeViewViewController ()

@end

@implementation CodeViewViewController{
  int _slideNumber;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _slideNumber = [GLDirector sharedInstance].currentPage - 24;

  NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"code-%d", _slideNumber]
                                                       ofType:@"html"
                                                  inDirectory:nil];
  NSString *html = [NSString stringWithContentsOfFile:filePath
                                             encoding:NSUTF8StringEncoding
                                                error:nil];
  WebView *webView = (WebView *)self.view;
  [webView setDrawsBackground:NO];
  [[webView mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)updateSlides {
  _slideNumber = [GLDirector sharedInstance].currentPage - 24;
  WebView *webView = (WebView *)self.view;
  NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"code-%d", _slideNumber]
                                                       ofType:@"html"
                                                  inDirectory:nil];
  NSURL* fileURL = [NSURL fileURLWithPath:filePath];
  NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
  [[webView mainFrame] loadRequest:request];
}

@end
