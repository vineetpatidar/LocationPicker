//
//  ViewController.m
//  LocationPicker
//
//  Created by vineet patidar on 18/02/17.
//  Copyright © 2017 vineet patidar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)openMapButton_Clicked:(id)sender {
    LocationPickerViewController *locationPicker = [[LocationPickerViewController alloc] initWithNibName:@"LocationPickerViewController" bundle:nil];
    locationPicker.defaultLocation = nil;
    locationPicker.mapTitle = @"Select Your Location";
    locationPicker.mapDoneButtonTitle = @"Done";
    locationPicker.additionalDictionary = nil;
    locationPicker.requestDelegate = self;
    
    [self.navigationController pushViewController:locationPicker animated:YES];
}

#pragma mark - LocationPicker Delegate

- (void)placeSelected:(LocationPickerViewController *)controller WithLocation:(NSMutableDictionary *)data additionalData:(NSMutableDictionary *)additionalData{
    NSLog(@"%@",data);
    self.infoLabel.text = [NSString stringWithFormat:@"%@, (%@)",[data valueForKey:@"address"],[data valueForKey:@"location"]];
    [controller.navigationController popViewControllerAnimated:YES];
}


@end
