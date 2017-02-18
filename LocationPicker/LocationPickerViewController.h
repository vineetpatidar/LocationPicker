//
//  BABLocationPickerViewController.h
//  BeABoss
//
//  Created by vineet patidar on 07/02/17.
//  Copyright © 2017 Apptology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@protocol LocationPickerDelegate;

@interface LocationPickerViewController : UIViewController{
    NSTimer *timer;
    NSMutableArray *searchResults;
    NSURLSessionDataTask *locationSearchTask;
    CLGeocoder *geocoder;
    BOOL reverseGeocode;
    id<LocationPickerDelegate> requestDelegate;
}

@property (weak, nonatomic) IBOutlet MKMapView *LocationPickerMapView;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (strong, nonatomic) NSMutableDictionary *selectedLocation;
@property(strong, nonatomic) NSString *mapTitle;
@property(strong, nonatomic) NSString *mapDoneButtonTitle;
@property(strong, nonatomic) CLLocation *defaultLocation;
@property (nonatomic, retain) id requestDelegate;
@property(strong, nonatomic) NSMutableDictionary *additionalDictionary;
@property (weak, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resultTableViewBottomConstraint;


@end

@protocol LocationPickerDelegate

@optional
- (void)placeSelected:(LocationPickerViewController *)controller WithLocation:(NSMutableDictionary *)data;
- (void)placeSelected:(LocationPickerViewController *)controller WithLocation:(NSMutableDictionary *)data additionalData:(NSMutableDictionary *)additionalData;
- (void)placePickerCancelled;
@end
