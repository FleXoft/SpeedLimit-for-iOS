//
//  SPLMainViewController.m
//  SpeedLimit
//
//  Created by FLEISCHMANN György on 23/02/14.
//  Copyright (c) 2014 FLEISCHMANN György. All rights reserved.
//

#import "SPLMainViewController.h"

// Constans
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
const float MAXSPEED = 160.0;
const float TIMEOUT = 5.0 * 60.0; // 5m disable Core Location
const float RECHECK = 5.0; // 5s checking battery charger

// Variables

// arrow object
UIImageView *arcImageView;

// needle image objects
UIImageView *needleImageView;
UIImageView *meterImageViewDot;
float needleAngle;

// speed limit states
BOOL greaterThanLimit = NO;
BOOL greaterThanLimitPlus10 = NO;

// speedWarning
int speedWarning = 50;

//
float currentSpeedkmh;
float previousSpeedkmh;

@interface SPLMainViewController ()

//- (void) rotateImageViewWithAnimated:(UIView*)view
//                     withDuration:(CFTimeInterval)duration
//                          byAngle:(CGFloat)angle;

//- (void)swipeUp:(UISwipeGestureRecognizer *)gesture;
//- (void)swipeDown:(UISwipeGestureRecognizer *)gesture;

//- (void)timerRoutine:(NSTimer *)timer;
//- (void)timerRoutine5Minute:(NSTimer *)timer;
//- (void)startupDelay:(NSTimer *)timer;

//- (void)switchOn;

@end

@implementation SPLMainViewController

//////////////
// View Setup
//////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.button50.tintColor = [UIColor redColor];
    
    // kell ez?
    // http://stackoverflow.com/questions/12856099/how-to-re-enable-the-idle-timer-in-ios-once-it-has-been-disabled-to-allow-the-d
    //[UIApplication sharedApplication].idleTimerDisabled = NO;
    
    // arrow background
    arcImageView = [[UIImageView alloc] initWithFrame:CGRectMake(143,155, 44, 168)];
	arcImageView.layer.anchorPoint = CGPointMake(arcImageView.layer.anchorPoint.x,arcImageView.layer.anchorPoint.y*2);
	arcImageView.image = [UIImage imageNamed:@"revarrow.png"];
    [self.view addSubview:arcImageView];
    // move to start position
    [self rotateImageViewWithAnimated: arcImageView withDuration:0 byAngle:[self speedToAngle:160]];
    [self rotateImageViewWithAnimated: arcImageView withDuration:2 byAngle:[self speedToAngle:50]];
    
    //////////
    // Needle
    //////////
	needleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(143,155, 44, 168)];
	needleImageView.layer.anchorPoint = CGPointMake(needleImageView.layer.anchorPoint.x,needleImageView.layer.anchorPoint.y*2);
	needleImageView.image = [UIImage imageNamed:@"arrow.png"];
    [self.view addSubview:needleImageView];
    // move to start position
    [self rotateImageViewWithAnimated: needleImageView withDuration:0 byAngle:[self speedToAngle:160]];
    [self rotateImageViewWithAnimated: needleImageView withDuration:2 byAngle:[self speedToAngle:0]];
    
    ////////////////
    // Needle Dot //
    ////////////////
	UIImageView *meterImageViewDot = [[UIImageView alloc]initWithFrame:CGRectMake(142, 215, 45,44)];
	meterImageViewDot.image = [UIImage imageNamed:@"center_wheel.png"];
	[self.view addSubview:meterImageViewDot];
    
    ////////////
    // Gestures
    ////////////
    //UISwipeGestureRecognizer *gestureRight;
    //UISwipeGestureRecognizer *gestureLeft;
    UISwipeGestureRecognizer *gestureUp;
    UISwipeGestureRecognizer *gestureDown;
    //
    //gestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)]; //direction is set by default.
    //gestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)]; //need to set direction.
    gestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    gestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    //
    //[gestureRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
    //[gestureLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [gestureUp setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [gestureDown setDirection:(UISwipeGestureRecognizerDirectionDown)];
    
    //[gesture setNumberOfTouchesRequired:1];//default is 1
    //[[self view] addGestureRecognizer:gestureRight];//this gets things rolling.
    //[[self view] addGestureRecognizer:gestureLeft];//this gets things rolling.
    [[self view] addGestureRecognizer:gestureUp];//this gets things rolling.
    [[self view] addGestureRecognizer:gestureDown];//this gets things rolling.
    
    // test
    //NSLog(@"Direction is: %f", [self speedToAngle:160]);
    
    /////////////////
    // Core Location
    /////////////////
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    // iOS 8 compatibility
    // http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        //[_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
    }
    
    //[_locationManager startUpdatingLocation];
    //
    _startLocation = nil;
    
    //
    // Enable battery charger monitoring
    //
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    ///////////////////////////////////////////////
    // Setup a timer for battery charger detection
    ///////////////////////////////////////////////
    [NSTimer scheduledTimerWithTimeInterval:RECHECK
                                     target:self
                                   selector:@selector(timerRoutine:)
                                   userInfo:nil
                                    repeats:YES];
    
    //////////////////////////////////
    // Setup a timer for power saving
    //////////////////////////////////
    [NSTimer scheduledTimerWithTimeInterval:TIMEOUT
                                     target:self
                                   selector:@selector(timerRoutine5Minute:)
                                   userInfo:nil
                                    repeats:YES];
    
    ///////////////////////////////////
    // Setup a timer for startup delay
    ///////////////////////////////////
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(startupDelay:)
                                   userInfo:nil
                                    repeats:NO];
    
    // beep
    AudioServicesPlaySystemSound (1057);
    
}

////////////////////////////
// Timer handlers/selectors
////////////////////////////
- (void)startupDelay:(NSTimer *)timer {
    
    // Setup the switch
    [self.enableSwitch setOn:YES animated:YES];
    [self switchOn];
    //[_locationManager startUpdatingLocation];
    
}

- (void)timerRoutine:(NSTimer *)timer {

    //NSLog(@"######## Timer time.");
    
    // Disable lock screen when charging!
    if ( [[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateUnplugged ) {
        // Disable Lock Screen
        //[UIApplication sharedApplication].idleTimerDisabled = NO;
        //[UIApplication sharedApplication].idleTimerDisabled = YES;
        //NSLog(@"Device is charging so lock screen will be disabled.");
        //self.screenLockStatus.text = [NSString stringWithFormat:@"ScreenLockDisabled"];
        
        // on
        if ( self.enableSwitch.on == NO ) {
            
            [self.enableSwitch setOn:YES animated:YES];
            [self switchOn];
            
        }
    }
    else {
        // Enable Lock Screen
        //self.screenLockStatus.text = [NSString stringWithFormat:@"ScreenLockEnabled"];
        //[UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
}

- (void)timerRoutine5Minute:(NSTimer *)timer {
    
    if ( currentSpeedkmh < 5 && previousSpeedkmh == currentSpeedkmh && [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateUnplugged ) {
        
        // possible stopped the movement so disable
        [self.enableSwitch setOn:NO animated:YES];
        [self switchOff];
        
    }
    
    // store the current speed
    previousSpeedkmh = currentSpeedkmh;
    
}

/////////////////////////
// Enabel/disable switch
/////////////////////////

- (IBAction)enableSwitch:(id)sender {
    
    if( [sender isOn] ) {
        [self switchOn];
        
    } else {
        [self switchOff];
    }
    
}

- (void)switchOn {
    
    self.enableSwitch.thumbTintColor = [UIColor greenColor];
    [_locationManager startUpdatingLocation];
    
}

- (void)switchOff {
    self.enableSwitch.thumbTintColor = [UIColor redColor];
    self.enableSwitch.tintColor = [UIColor greenColor];
    [_locationManager stopUpdatingLocation];
    
    [self rotateImageViewWithAnimated: needleImageView withDuration:2 byAngle:[self speedToAngle:0]];
}

///////////
// Buttons
///////////
- (IBAction)button50:(id)sender {
    if ( speedWarning != 50 ) {
        speedWarning = 50;
        self.button50.tintColor = [UIColor redColor];
        self.button70.tintColor = [UIColor greenColor];
        self.button130.tintColor = [UIColor greenColor];
        //
        AudioServicesPlaySystemSound (1306);
        
        [self rotateImageViewWithAnimated: arcImageView withDuration:0 byAngle:[self speedToAngle:50]];
    }
}

- (IBAction)button70:(id)sender {
    if ( speedWarning != 70 ) {
        speedWarning = 70;
        self.button50.tintColor = [UIColor greenColor];
        self.button70.tintColor = [UIColor redColor];
        self.button130.tintColor = [UIColor greenColor];
        //
        AudioServicesPlaySystemSound (1306);
        
        [self rotateImageViewWithAnimated: arcImageView withDuration:0 byAngle:[self speedToAngle:70]];
    }
}

- (IBAction)button130:(id)sender {
    if ( speedWarning != 130 ) {
        speedWarning = 130;
        self.button50.tintColor = [UIColor greenColor];
        self.button70.tintColor = [UIColor greenColor];
        self.button130.tintColor = [UIColor redColor];
        //
        AudioServicesPlaySystemSound (1306);
        
        [self rotateImageViewWithAnimated: arcImageView withDuration:0 byAngle:[self speedToAngle:130]];
    }
}

/////////////////
// Location part
/////////////////
#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    currentSpeedkmh = newLocation.speed * 3.6; // store km/h
    
    self.speedLabel.textColor = [UIColor greenColor];
    if ( currentSpeedkmh < 1 ) {
        self.speedLabel.text = [NSString stringWithFormat:@"--- km/h"];
    }
    else {
        self.speedLabel.text = [NSString stringWithFormat:@"%.1f km/h", currentSpeedkmh];
    }
    
    if (_startLocation == nil) self.startLocation = newLocation;
    
    //CLLocationDistance distanceBetween = [newLocation distanceFromLocation:self.startLocation];
    //NSLog(@"Location distance %@", [NSString stringWithFormat:@"%f", distanceBetween]);
    
    //NSTimeInterval locationAge = fabs([oldLocation.timestamp timeIntervalSinceNow]);
    //NSLog(@"Location Age is %@", [NSString stringWithFormat:@"%f", locationAge]);
    
    if ( greaterThanLimit == YES && greaterThanLimitPlus10 == NO && currentSpeedkmh > ( speedWarning + 10 ) ) {
        // maxspeed + 10
        greaterThanLimitPlus10 = YES;
        AudioServicesPlaySystemSound (1057);
        sleep(1);
        AudioServicesPlaySystemSound (1057);
    }
    else if ( greaterThanLimit == NO && currentSpeedkmh > speedWarning ) {
        // maxspeed
        greaterThanLimit = YES;
        AudioServicesPlaySystemSound (1057);
    }
    else if ( greaterThanLimit == YES && greaterThanLimitPlus10 == YES && currentSpeedkmh < speedWarning+10) {
        //
        greaterThanLimitPlus10 = NO;
    }
    else if ( greaterThanLimit == YES && currentSpeedkmh < speedWarning ) {
        //
        greaterThanLimit = NO;
        greaterThanLimitPlus10 = NO;
    }
    
    // update needle
    [self rotateImageViewWithAnimated: needleImageView withDuration:1 byAngle:[self speedToAngle:currentSpeedkmh]];
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.speedLabel.text = @"No GPS!";
    self.speedLabel.textColor = [UIColor redColor];
    
    [self rotateImageViewWithAnimated: needleImageView withDuration:2 byAngle:[self speedToAngle:0]];
    
    // set these to be able to disable if this state tokes too long
    currentSpeedkmh = -1;
    previousSpeedkmh = -1;
    
}

- (float) speedToAngle:(float)speed
{
    return ( speed < (MAXSPEED/2.0) ) ? ( 280.0 + ( ( 80.0 / ( MAXSPEED / 2.0 ) ) * speed ) ) : ( ( 80.0 / ( MAXSPEED / 2.0 ) ) * ( speed - ( MAXSPEED / 2.0 ) ) );

}

- (void) rotateImageViewWithAnimated:(UIView*)view
               withDuration:(CFTimeInterval)duration
                    byAngle:(CGFloat)angle
{

    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	[view setTransform: CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(angle) )];
    [UIView commitAnimations];
    
}

////////////
// Gestures
////////////
- (void)swipeUp:(UISwipeGestureRecognizer *)gesture
{
    //NSLog(@"Up Swipe received.");//Lets you know this method was called by gesture recognizer.
    //NSLog(@"Direction is: %i", (int)gesture.direction);//Lets you know the numeric value of the gesture direction for confirmation (1=right).
    //only interested in gesture if gesture state == changed or ended (From Paul Hegarty @ standford U
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        //do something for a right swipe gesture.
        //AudioServicesPlaySystemSound (1057);
        
        //[self rotateNeedleWithAnimated: needleImageView withDuration:1 byAngle:[self speedToAngle:80]];
        
        if ( speedWarning == 50 ) {
            [self button70:self];
        }
        else if ( speedWarning == 70 ) {
            [self button130:self];
        }
    }
}

- (void)swipeDown:(UISwipeGestureRecognizer *)gesture
{
    //NSLog(@"Down Swipe received.");//Lets you know this method was called by gesture recognizer.
    //NSLog(@"Direction is: %i", (int)gesture.direction);//Lets you know the numeric value of the gesture direction for confirmation (1=right).
    //only interested in gesture if gesture state == changed or ended (From Paul Hegarty @ standford U
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        
        //do something for a right swipe gesture.
        //AudioServicesPlaySystemSound (1057);
        
        //[self rotateNeedleWithAnimated: needleImageView withDuration:1 byAngle:[self speedToAngle:160]];
        
        if ( speedWarning == 130 ) {
            [self button70:self];
        }
        else if ( speedWarning == 70 ) {
            [self button50:self];
        }
    }
}

- (void)torchOnOff: (BOOL) onOff
{
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: onOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(SPLFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        // [[segue destinationViewController] setDelegate:self];
        [(SPLFlipsideViewController *)segue.destinationViewController setDelegate:self]; // ???

    }
}

@end