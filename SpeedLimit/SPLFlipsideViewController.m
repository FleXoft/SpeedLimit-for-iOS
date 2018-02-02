//
//  SPLFlipsideViewController.m
//  SpeedLimit
//
//  Created by FLEISCHMANN György on 23/02/14.
//  Copyright (c) 2014 FLEISCHMANN György. All rights reserved.
//

#import "SPLFlipsideViewController.h"

@interface SPLFlipsideViewController ()

@end

@implementation SPLFlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // webView
    //NSString *fullURL = @"http://apple.com";
    //NSURL *url = [NSURL URLWithString:fullURL];
    //NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    //[_webView loadRequest:requestObj];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]isDirectory:NO]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
