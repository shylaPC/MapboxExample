//
//  ViewController.m
//  MapBox
//
//  Created by Shyla PC on 4/29/16.
//  Copyright © 2016 Mobinius.com. All rights reserved.
//

#import "ViewController.h"
@import CoreLocation;
@import MapboxGeocoder;
@import Mapbox;

@interface ViewController ()<MGLMapViewDelegate>
@property (nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet MGLMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
    //point.coordinate = CLLocationCoordinate2DMake(12.9716, 77.5946);
    //  point.coordinate = CLLocationCoordinate2DMake(77.5946,12.9716);
    point.title = @"Bengaluru";
    point.subtitle = @" check it ";
    [self.mapView addAnnotation:point];
    self.mapView.delegate = self;
    
    // Geocoding
    [self jjjj];
    
    // OFFLINE REGION STORAge
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackProgressDidChange:) name:MGLOfflinePackProgressChangedNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveError:) name:MGLOfflinePackErrorNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offlinePackDidReceiveMaximumAllowedMapboxTiles:) name:MGLOfflinePackMaximumMapboxTilesReachedNotification object:nil];
}



- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    // Start downloading tiles and resources for z13-16.
    [self startOfflinePackDownload];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    // Always try to show a callout when an annotation is tapped.
    return YES;
}


- (void)dealloc {
    // Remove offline pack observers.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)jjjj{
    [self Webservice:@"jkjlj" success:^(NSDictionary *contentResponse) {
        NSLog(@" Response %@",contentResponse);
    }
             failure:^(NSError *error) {
                 NSLog(@"faiilure");
                 
             }];
    //    [[APIManager sharedManager] emailValidationInSignUp:email success:^(NSDictionary *contentResponse){
    //        [self.actvityIndicatorSignOne stopAnimating];
    //        self.continueBtn.userInteractionEnabled=YES;
    //
    //        NSLog(@" Response %@",contentResponse);
    //        //   [self.activityIndicatorSignUp stopAnimating];
    //
    //        if ([contentResponse objectForKey:@"IsSuccess"]) {
    //            NSString *IsSuccess=[contentResponse objectForKey:@"IsSuccess"];
    //            NSString *ErrorMessage=[contentResponse objectForKey:@"ErrorMessage"];
    //
    //            if ([IsSuccess integerValue]==1) {
    //
    //                self.secondSignUPViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SecondSignUPViewController" ];
    //                self.secondSignUPViewController.SignUpDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"00000000-0000-0000-0000-000000000000",@"Id",firstName,@"FirstName",lastname,@"LastName",email,@"Email",password,@"Password",matchPassword,@"MatchPassword", nil];
    //                [self.navigationController pushViewController:self.secondSignUPViewController animated:YES];
    //
    //
    //            }else{
    //                if (![ErrorMessage isKindOfClass:[NSNull class]]) {
    //                    //NSString *EmailTitel=@"Email already exists.";
    //                    self.nEmailLbl.hidden=NO;
    //                    self.nEmailLbl.text=ErrorMessage;
    //
    //                }
    //            }
    //
    //        }
    //    } failure:^(NSError *error) {
    //        NSLog(@"faiilure");
    //        [self.actvityIndicatorSignOne stopAnimating];
    //    }]
}

- (void)startOfflinePackDownload {
    // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
    // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
    id <MGLOfflineRegion> region = [[MGLTilePyramidOfflineRegion alloc] initWithStyleURL:self.mapView.styleURL bounds:self.mapView.visibleCoordinateBounds fromZoomLevel:self.mapView.zoomLevel toZoomLevel:16];
    // Store some data for identification purposes alongside the downloaded resources.
    NSDictionary *userInfo = @{ @"name": @"My Offline Pack" };
    NSData *context = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
    // Create and register an offline pack with the shared offline storage object.
    [[MGLOfflineStorage sharedOfflineStorage] addPackForRegion:region withContext:context completionHandler:^(MGLOfflinePack *pack, NSError *error) {
        if (error != nil) {
            // The pack couldn’t be created for some reason.
            NSLog(@"Error: %@", error.localizedFailureReason);
        } else {
            // Start downloading.
            [pack resume];
        }
    }];
}


#pragma mark - MGLOfflinePack notification handlers

- (void)offlinePackProgressDidChange:(NSNotification *)notification {
    MGLOfflinePack *pack = notification.object;
    // Get the associated user info for the pack; in this case, `name = My Offline Pack`
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    MGLOfflinePackProgress progress = pack.progress;
    // or [notification.userInfo[MGLOfflinePackProgressUserInfoKey] MGLOfflinePackProgressValue]
    uint64_t completedResources = progress.countOfResourcesCompleted;
    uint64_t expectedResources = progress.countOfResourcesExpected;
    // Calculate current progress percentage.
    float progressPercentage = (float)completedResources / expectedResources;
    // Setup the progress bar.
    if (!self.progressView) {
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        CGSize frame = self.view.bounds.size;
        self.progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75, frame.width / 2, 10);
        [self.view addSubview:self.progressView];
    }
    [self.progressView setProgress:progressPercentage animated:YES];
    // If this pack has finished, print its size and resource count.
    if (completedResources == expectedResources) {
        NSString *byteCount = [NSByteCountFormatter stringFromByteCount:progress.countOfBytesCompleted countStyle:NSByteCountFormatterCountStyleMemory];
        NSLog(@"Offline pack “%@” completed: %@, %llu resources", userInfo[@"name"], byteCount, completedResources);
    } else {
        // Otherwise, print download/verification progress.
        NSLog(@"Offline pack “%@” has %llu of %llu resources — %.2f%%.", userInfo[@"name"], completedResources, expectedResources, progressPercentage * 100);
    }
}

- (void)offlinePackDidReceiveError:(NSNotification *)notification
{
    MGLOfflinePack *pack = notification.object;
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    NSError *error = notification.userInfo[MGLOfflinePackErrorUserInfoKey];
    NSLog(@"Offline pack “%@” received error: %@", userInfo[@"name"], error.localizedFailureReason);
}

- (void)offlinePackDidReceiveMaximumAllowedMapboxTiles:(NSNotification *)notification
{
    MGLOfflinePack *pack = notification.object;
    NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:pack.context];
    uint64_t maximumCount = [notification.userInfo[MGLOfflinePackMaximumCountUserInfoKey] unsignedLongLongValue];
    NSLog(@"Offline pack “%@” reached limit of %llu tiles.", userInfo[@"name"], maximumCount);
}



-(void)Webservice:(NSString *)emailID success:(void (^)(NSDictionary *contentResponse))success failure:(void (^)(NSError *error))failure{
    QueryStr=@"Banashankari, Bangalore";
    NSString *escapedString = [QueryStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSLog(@"escapedString: %@", escapedString);
    //  NSString *urlStr= @"https://api.mapbox.com/geocoding/v5/mapbox.places";
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.mapbox.com/geocoding/v5/mapbox.places/%@.json?autocomplete=true&access_token=pk.eyJ1Ijoic2h5bGEiLCJhIjoiY2luaWZvbndwMHduNHVrbHl0bzJjdzhqeCJ9.5pq8jJnRx3UzFq6-4Le71w",escapedString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlAsString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //  [request setHTTPBody:data];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSMutableDictionary *mallJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];           //  NSLog(@"HttpResponseBody Login : %@",jsonResp);
            success(mallJson);
        }else{
            failure(connectionError);
            NSLog(@"HttpResponseBody connectionError : %@",connectionError);
            
        }
    }];
}


-(NSMutableURLRequest*)getUrlFor:(NSString*)strUrl andData:(NSData*)data
                       forMethod:(NSString*)method
                        withAuth:(BOOL)authKey
{
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:60];
    //set the content type
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //if authorization needed send the auth key
    if(authKey)
        //   [urlRequest addValue:[Userdefaults authKey] forHTTPHeaderField:@"X-Auth-Token"];
        //the method type
        [urlRequest setHTTPMethod:method];
    //if post send the data else no
    if(data != nil)
        [urlRequest setHTTPBody:data];
    return urlRequest;
}

@end
