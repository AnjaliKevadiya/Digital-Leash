//
//  ViewController.h
//  DigitalLeashChild
//
//  Created by Anjali Kevadiya on 10/18/18.
//  Copyright © 2018 Anjali Kevadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "iToast.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;

    IBOutlet UIView *usernameView,*reportedView,*viewError;
    IBOutlet UITextField *txtUsername;
    IBOutlet UIButton *btnReportOrDone;
    BOOL isReported;
    IBOutlet UILabel *lblError;
}
-(IBAction)ReportedOrDoneTap:(id)sender;

@end

