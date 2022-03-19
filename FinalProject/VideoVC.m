//
//  VideoVC.m
//  FinalProject
//
//  Created by Michael Lipman on 6/6/14.
//  Copyright (c) 2014 mouthy. All rights reserved.
//

#import "VideoVC.h"

@interface VideoVC ()

@end

@implementation VideoVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self embedVideo];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [self embedVideo];
}

- (void)viewDidLayoutSubviews {
    [self embedVideo];
}

- (void)embedVideo {
    
    // Reference: stackoverflow question 3793109
    // If the url is like:
    NSString *videoURL = @"http://tiny.cc/ml193p";
    NSString *videoHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <head>\
                           <style type=\"text/css\">\
                           iframe {position:absolute; margin-top:0;}\
                           body {background-color:#000; margin:0;}\
                           </style>\
                           </head>\
                           <body>\
                           <iframe width=\"100%%\" height=\"100%%\" src=\"%@\" frameborder=\"0\" allowfullscreen></iframe>\
                           </body>\
                           </html>", videoURL];
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:self.view.frame];
    videoView.backgroundColor = [UIColor blackColor];
    videoView.opaque = NO;
    [self.view addSubview:videoView];
    [videoView loadHTMLString:videoHTML baseURL:nil];
    
}

@end
