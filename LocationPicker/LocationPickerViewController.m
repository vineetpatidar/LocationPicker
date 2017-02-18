//
//  BABLocationPickerViewController.m
//  BeABoss
//
//  Created by vineet patidar on 07/02/17.
//  Copyright © 2017 Apptology. All rights reserved.
//

#import "LocationPickerViewController.h"
#import "AppDelegate.h"

#define kLocatioPickerScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kGoogleAPIKey @"YOURAPIKEYHERE"
#define kLocationPickerFont [UIFont fontWithName:@"HelveticaNeue" size:16]

@interface LocationPickerViewController ()

@end

@implementation LocationPickerViewController

@synthesize requestDelegate;

- (void)drawDesign{
    if(self.mapTitle){
        self.title = self.mapTitle;
    }
    else{
        self.title = @"Select location";
    }
    
    if (self.mapDoneButtonTitle) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:self.mapDoneButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(doneButton_Clicked:)];
    }
    else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButton_Clicked:)];
    }
}

- (void)initTableDataWithReload:(BOOL)withReload{
    searchResults = [NSMutableArray array];
    //,@{@"address":@"Use Current Location"}
    [searchResults addObjectsFromArray:@[@{@"address":@"Use Pin Location"}]];
    if (withReload) {
        [self.resultTableView reloadData];
    }
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered_by_google_on_white"]];
    imgView.frame = CGRectMake(0, 0, kLocatioPickerScreenWidth, 60);
    imgView.contentMode = UIViewContentModeCenter;
    self.resultTableView.tableFooterView = imgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchResults = [NSMutableArray array];
    [searchResults addObject:[NSMutableDictionary dictionary]];
    geocoder = [[CLGeocoder alloc] init] ;
    [self drawDesign];
    if(self.defaultLocation){
        [self.LocationPickerMapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.defaultLocation.coordinate.latitude, self.defaultLocation.coordinate.longitude), 1609, 1609) animated:YES];
    }
    else{
        self.LocationPickerMapView.centerCoordinate = CLLocationCoordinate2DMake(40.97989807, -100.37109375);
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Keyboard Notification
- (void)showKeyboard:(NSNotification *)note{
    CGFloat height = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.resultTableViewBottomConstraint.constant = height;
    }];
}
- (void)hideKeyboard:(NSNotification *)note{
    [UIView animateWithDuration:0.25 animations:^{
        self.resultTableViewBottomConstraint.constant = 0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MKMapView

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"region did change");
    CLLocation *userlocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    
    
    if (geocoder) {
        [geocoder cancelGeocode];
    }
    self.locationSearchBar.text = @"Loading . . .";
    [geocoder reverseGeocodeLocation:userlocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSMutableArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
             NSString *strAddress = [lines componentsJoinedByString:@", "];
             self.selectedLocation = [NSMutableDictionary dictionary];
             [self.selectedLocation setValue:userlocation forKey:@"location"];
             [self.selectedLocation setValue:strAddress forKey:@"address"];
             [self.selectedLocation setValue:placemark.addressDictionary forKey:@"addressDic"];
             
             [self.LocationPickerMapView removeAnnotations:self.LocationPickerMapView.annotations];
             self.locationSearchBar.text = strAddress;
         }
         else{
             NSLog(@"Geocode failed with error %@", error);
         }
     }];
}

- (IBAction)doneButton_Clicked:(id)sender {
    
    if (self.selectedLocation) {
        if(self.requestDelegate != nil && ([self.requestDelegate conformsToProtocol:@protocol(LocationPickerDelegate)])){
            dispatch_async(dispatch_get_main_queue(), ^{
                if([self.requestDelegate respondsToSelector:@selector(placeSelected:WithLocation:additionalData:)]){
                    [self.navigationController popViewControllerAnimated:YES];
                    [self.requestDelegate placeSelected:self WithLocation:self.selectedLocation additionalData:self.additionalDictionary];
                }
                if([self.requestDelegate respondsToSelector:@selector(placeSelected:WithLocation:)]){
                    [self.navigationController popViewControllerAnimated:YES];
                    [self.requestDelegate placeSelected:self WithLocation:self.selectedLocation];
                }
            });
        }
    }
    else {
        [self showAlertViewControllerIn:self title:@"OOPS" message:@"Please select address first" block:^(int index) {
            
        }];
    }
}

#pragma mark - TABLE VIEW
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResults.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 40;
    
    height = ([self calculateHeightOfTextFromWidth:[[searchResults objectAtIndex:indexPath.row] objectForKey:@"address"] withFont:kLocationPickerFont width:kLocatioPickerScreenWidth-30]+20);
    if (height <= 40) {
        height = 40;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"pin.png"];
    }
    cell.textLabel.font = kLocationPickerFont;
    cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] valueForKey:@"address"];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        self.locationSearchBar.text=@"";
        self.selectedLocation = nil;
        [self.locationSearchBar resignFirstResponder];
        [self mapView:self.LocationPickerMapView regionDidChangeAnimated:YES];
    }
    else{
        [self.locationSearchBar resignFirstResponder];
        [self getPlaceDetail:[[searchResults objectAtIndex:indexPath.row] valueForKey:@"placeID"]];
    }
}

#pragma mark -searchbar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if(geocoder){
        [geocoder cancelGeocode];
    }
    reverseGeocode = YES;
    self.resultView.hidden = NO;
    self.locationSearchBar.text = @"";
    self.navigationController.navigationBarHidden = YES;
    self.searchBarTopConstraint.constant = 20;
    self.locationSearchBar.showsCancelButton = YES;
    [self initTableDataWithReload:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    self.resultView.hidden = YES;
    self.navigationController.navigationBarHidden = NO;
    self.searchBarTopConstraint.constant = 64;
    self.locationSearchBar.showsCancelButton = NO;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    if (self.selectedLocation) {
        self.locationSearchBar.text = [self.selectedLocation valueForKey:@"address"];
    }
    else{
        self.locationSearchBar.text = @"";
    }
    [self.locationSearchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (timer) {
        if ([timer isValid]){ [
            timer invalidate];
        }
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timeAction) userInfo:nil repeats:NO];
}

-(void)getPlaceDetail:(NSString *)strPlaceID{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@",strPlaceID,kGoogleAPIKey];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showAlertViewControllerIn:self title:@"OOPS" message:@"unable to find locaiton please try again." block:^(int index) {
                    
                }];
                return;
            }
            
            if (data) {
                NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableArray *results = [jSONresult valueForKey:@"result"];
                if (results.count>0) {
                    self.locationSearchBar.text = @"";
                    CLLocation *userlocation = [[CLLocation alloc] initWithLatitude:[[[[results valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lat"] doubleValue] longitude:[[[[results valueForKey:@"geometry"] valueForKey:@"location"] valueForKey:@"lng"] doubleValue]];
                    [self.selectedLocation setValue:userlocation forKey:@"location"];
                    
                    self.LocationPickerMapView.centerCoordinate = userlocation.coordinate;
                }
                
            }
            else{
                [self showAlertViewControllerIn:self title:@"OOPS" message:@"unable to find locaiton please try again." block:^(int index) {
                    
                }];
            }
        });
        
    }];
    
    [task resume];
}

-(void)timeAction{
    [timer invalidate];
    timer = nil;
    
    NSString *text = self.locationSearchBar.text;
    
    if([text isEqualToString:@""])
    {
        [self initTableDataWithReload:YES];
    }
    else{
        
        if (text.length > 0) {
            const char * _char = [text cStringUsingEncoding:NSUTF8StringEncoding];
            int isBackSpace = strcmp(_char, "\b");
            
            if (isBackSpace == -8) {
                
                if ([text length] > 0) {
                    text = [text substringToIndex:[text length] - 1];
                }
            }
            
            NSString *escapedString = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            
            NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&language=en&key=%@",escapedString,kGoogleAPIKey];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            
            if (locationSearchTask) {
                [locationSearchTask cancel];
            }
            
            locationSearchTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        if (![error.localizedDescription isEqualToString:@"cancelled"]) {
                            
                        }
                        return;
                    }
                    
                    [self initTableDataWithReload:NO];
                    if (data) {
                        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                        
                        NSMutableArray *results = [jSONresult valueForKey:@"predictions"];
                        if (results.count>0) {
                            for (NSDictionary *jsonDictionary in results) {
                                [searchResults addObject:@{@"address":[jsonDictionary valueForKey:@"description"],@"placeID":[jsonDictionary valueForKey:@"place_id"]}];
                            }
                        }
                        
                    }
                    [self.resultTableView reloadData];
                });
                
            }];
            
            [locationSearchTask resume];
            
            
        }
    }
}


-(void)showAlertViewControllerIn:(UIViewController*)controller title:(NSString*)title message:(NSString*)message block:(void(^)(int sum))block{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert ];
    
    
    UIAlertAction * actionOk=[ UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        block(1);
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    
    
    [alert addAction:actionOk];
    
    
    
    
    [controller presentViewController:alert animated:YES completion:nil];
    
    
}

-(float) calculateHeightOfTextFromWidth:(NSString*)text withFont:(UIFont*)withFont width:(float)width{
    CGSize suggestedSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading
                                           attributes:@{NSFontAttributeName:withFont}
                                              context:nil].size;
    
    return roundf(suggestedSize.height);
}

@end
