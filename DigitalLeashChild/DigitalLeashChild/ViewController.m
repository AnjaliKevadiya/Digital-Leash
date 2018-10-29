//
//  ViewController.m
//  DigitalLeashChild
//
//  Created by Anjali Kevadiya on 10/18/18.
//  Copyright © 2018 Anjali Kevadiya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }

    btnReportOrDone.layer.cornerRadius = btnReportOrDone.frame.size.height / 2;
    reportedView.hidden = true;
    isReported = false;
    viewError.hidden = true;
}

-(IBAction)ReportedOrDoneTap:(id)sender
{
    if (isReported == false)
    {
        if (txtUsername.text.length == 0) {
            lblError.text = @"Error : Username can not be blank";
            viewError.hidden = false;
            viewError.alpha = 1.0f;
            [UIView animateWithDuration:0.5 delay:2.0 options:0 animations:^{
                viewError.alpha = 0.0f;
            } completion:^(BOOL finished) {
                viewError.hidden = true;
            }];
        }
        else
        {
            isReported = true;
            [UIView transitionWithView:self.view duration:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                usernameView.hidden = true;
            } completion:^(BOOL finished) {
                
                reportedView.hidden = false;
                [btnReportOrDone setTitle:@"DONE" forState:UIControlStateNormal];
                
                NSUserDefaults *childLong = [NSUserDefaults standardUserDefaults];
                NSString *strUserLongitude = [childLong stringForKey:@"current_longitude"];
                
                NSUserDefaults *childLat = [NSUserDefaults standardUserDefaults];
                NSString *strUserLatitude = [childLat stringForKey:@"current_latitude"];
                
                NSMutableDictionary *dicUser = [[NSMutableDictionary alloc] init];
                [dicUser setValue:txtUsername.text forKey:@"username"];
                [dicUser setValue:strUserLongitude forKey:@"current_longitude"];
                [dicUser setValue:strUserLatitude forKey:@"current_latitude"];
                
                NSData *userData = [NSJSONSerialization dataWithJSONObject:dicUser options:NSJSONWritingPrettyPrinted error:nil];
                
                NSString *url = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json",txtUsername.text];
                
                if ([AppDelegate isNetworkRechability] == NO) {
                    [[[iToast makeText:NSLocalizedString(@"No Internet", @"")] setDuration:iToastDurationShort] show];
                }
                else
                {
                    [self patchDataFrom:url withBody:userData];
                }
            }];
        }
    }
    else
    {
        isReported = false;
        txtUsername.text = @"";
        [UIView transitionWithView:self.view duration:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            reportedView.hidden = true;
        } completion:^(BOOL finished) {
            usernameView.hidden = false;
            [btnReportOrDone setTitle:@"REPORT LOCATION" forState:UIControlStateNormal];
        }];
    }
}

#pragma mark - PATCH Request
- (NSString *) patchDataFrom:(NSString *)url withBody:(NSData *)body{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"PATCH"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", [body length]] forHTTPHeaderField:@"Content-Length"];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               NSDictionary *json_dict = (NSDictionary *)[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                               NSLog(@"json_dict\n%@",json_dict);
                           }];

    return [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
}


#pragma mark - CLLocationDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"New Location %@",newLocation);
    CLLocation *currLocation = newLocation;
    
    if (currLocation != nil) {

        NSUserDefaults *childLong = [NSUserDefaults standardUserDefaults];
        [childLong setObject:[NSString stringWithFormat:@"%.4f",currLocation.coordinate.longitude] forKey:@"current_longitude"];
        
        NSUserDefaults *childLat = [NSUserDefaults standardUserDefaults];
        [childLat setObject:[NSString stringWithFormat:@"%.4f",currLocation.coordinate.latitude] forKey:@"current_latitude"];

        NSLog(@"long %@",[NSString stringWithFormat:@"%.4f",currLocation.coordinate.longitude]);
        NSLog(@"lat %@",[NSString stringWithFormat:@"%.4f",currLocation.coordinate.latitude]);
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed to detech current location %@",error.localizedDescription);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
