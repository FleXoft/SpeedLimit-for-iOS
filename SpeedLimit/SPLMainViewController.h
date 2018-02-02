//
//  SPLMainViewController.h
//  SpeedLimit
//
//  Created by FLEISCHMANN György on 23/02/14.
//  Copyright (c) 2014 FLEISCHMANN György. All rights reserved.
//

#import "SPLFlipsideViewController.h"

#import <CoreLocation/CoreLocation.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SPLMainViewController : UIViewController <SPLFlipsideViewControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

// MainViewController
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@property (weak, nonatomic) IBOutlet UIButton *button50;
@property (weak, nonatomic) IBOutlet UIButton *button70;
@property (weak, nonatomic) IBOutlet UIButton *button130;

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

// CoreLocation
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startLocation;

@end
