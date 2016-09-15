//
//  PresentationViewController.m
//  OpenGLPresentation
//
//  Created by Emma Steimann on 8/20/16.
//  Copyright © 2016 Emma Steimann. All rights reserved.
//

#import "PresentationViewController.h"
#import "NS(Attributed)String+Geometrics.h"
#import <WebKit/WebKit.h>
#import "GLDirector.h"

@interface PresentationViewController ()
@property (weak) IBOutlet WebView *webView;
@property (strong, nonatomic) NSMutableArray *slideContent;
@end

@implementation PresentationViewController {
  int _slideNumber;
  int _slideCount;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _slideNumber = 0;
  _slideCount = 13;
  [GLDirector sharedInstance].slideCount = _slideCount;
  [GLDirector sharedInstance].currentPage = _slideNumber;

  NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"prez-%d", _slideNumber]
                                                       ofType:@"html"
                                                  inDirectory:nil];
  NSString *html = [NSString stringWithContentsOfFile:filePath
                                             encoding:NSUTF8StringEncoding
                                                error:nil];
//  NSURL* fileURL = [NSURL fileURLWithPath:filePath];
//  NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];


  [_webView setDrawsBackground:NO];
  [[_webView mainFrame] loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
//
//  NSString *path = [[NSBundle mainBundle] pathForResource:@"default" ofType:@"css"];
//  NSString *javascriptString = @"var link = document.createElement('link'); link.href = '%@'; link.rel = 'stylesheet'; document.head.appendChild(link)";
//  NSString *javascriptWithPathString = [NSString stringWithFormat:javascriptString, path];
//  [_webView stringByEvaluatingJavaScriptFromString:javascriptWithPathString];
//
//  NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
//  NSURL *jsURL = [NSURL fileURLWithPath:jsFilePath];
//  NSString *javascriptCode = [NSString stringWithContentsOfFile:jsURL.path encoding:NSUTF8StringEncoding error:nil];
//  [_webView stringByEvaluatingJavaScriptFromString:javascriptCode];
//
//  NSString *runString = @"hljs.initHighlightingOnLoad();";
//  [_webView stringByEvaluatingJavaScriptFromString:runString];

  //  [[_webView mainFrame] loadRequest:request];
}

- (void)nextPage {
  if (_slideNumber + 1 <= _slideCount) {
    _slideNumber++;
    [self updateSlides];
    [GLDirector sharedInstance].slideCount = _slideCount;
    [GLDirector sharedInstance].currentPage = _slideNumber;
  }
}

- (void)previousPage {
  if (_slideNumber - 1 >= 0) {
    _slideNumber--;
    [self updateSlides];
    [GLDirector sharedInstance].slideCount = _slideCount;
    [GLDirector sharedInstance].currentPage = _slideNumber;
  }
}
- (void)updateSlides {
  NSString* filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"prez-%d", _slideNumber]
                                                       ofType:@"html"
                                                  inDirectory:nil];
  NSURL* fileURL = [NSURL fileURLWithPath:filePath];
  NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
  [[_webView mainFrame] loadRequest:request];
}

@end
