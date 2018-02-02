//
//  SPLFlipsideViewController.h
//  SpeedLimit
//
//  Created by FLEISCHMANN György on 23/02/14.
//  Copyright (c) 2014 FLEISCHMANN György. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLFlipsideViewController;

@protocol SPLFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(SPLFlipsideViewController *)controller;
@end

@interface SPLFlipsideViewController : UIViewController

@property (weak, nonatomic) id <SPLFlipsideViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)done:(id)sender;

@end
