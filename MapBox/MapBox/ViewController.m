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
#import "PlaceRegion.h"
#import "Place.h"

@interface ViewController ()<MGLMapViewDelegate,UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *searchResultArr;
}
@property (nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet MGLMapView *mapView;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    searchResultArr= [[NSMutableArray alloc]init];
    searchTable.allowsMultipleSelectionDuringEditing = NO;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    searchTable.tableHeaderView = self.searchController.searchBar;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;// default is YES
    self.definesPresentationContext = YES;
    MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
    //point.coordinate = CLLocationCoordinate2DMake(12.9716, 77.5946);
    //  point.coordinate = CLLocationCoordinate2DMake(77.5946,12.9716);
    point.title = @"Bengaluru";
    point.subtitle = @" check it ";
    [self.mapView addAnnotation:point];
    //self.mapView.delegate = self;
    
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
        
        PlaceRegion *placeInfo = [[PlaceRegion alloc] initWithJSON:contentResponse];
        [searchResultArr addObjectsFromArray:placeInfo.placeInfoArr];
        NSLog(@" placeInfo %@",placeInfo);
        NSLog(@" searchResultArr %lu",(unsigned long)[searchResultArr count]);

        [self setTableViewheightOfTable:searchTable ByArrayName:searchResultArr];
        [searchTable reloadData];

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
    QueryStr=@"basavangudi";
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


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    
//    [self.arrData removeAllObjects];
//    self.arrData = [self.arrServerData mutableCopy];
//    [self.sections removeAllObjects];
//    NSLog(@"%ld %ld",[self.arrServerData count],[self.arrData count]);
//    [self assignDictonarytoTable];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.searchController mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"strName"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
//    [self.arrData removeAllObjects];
//    [self.sections removeAllObjects];
//    self.arrData = searchResults;
//    [self assignDictonarytoTable];
}



#pragma mark - UITableView Methods

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@" rows : %ld ",[searchResultArr count]);
    return [searchResultArr count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    NSString *placeName;
    double lati,longi;
    Place *place =[[Place alloc]init];
    place = [searchResultArr objectAtIndex:indexPath.row];

    cell.textLabel.text = place.nameRegion;
   // cell.detailTextLabel.text=[NSString stringWithFormat:@"%f %f ",lati,longi];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    Place *place =[[Place alloc]init];
    place = [searchResultArr objectAtIndex:indexPath.row];
    
    MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitud
                                                  );
    //  point.coordinate = CLLocationCoordinate2DMake(77.5946,12.9716);
    point.title = place.nameRegion;
    point.subtitle = @" check it ";
    [self.mapView addAnnotation:point];
}

-(void)setTableViewheightOfTable :(UITableView *)tableView ByArrayName:(NSArray *)array
{
    CGFloat height = searchTable.rowHeight+200;
    height *= array.count;
    
    CGRect tableFrame = tableView.frame;
    tableFrame.size.height = height;
    searchTable.frame = tableFrame;
   // [searchTable layoutIfNeeded];

}
@end
