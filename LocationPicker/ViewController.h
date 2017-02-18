//
//  ViewController.h
//  LocationPicker
//
//  Created by vineet patidar on 18/02/17.
//  Copyright © 2017 vineet patidar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationPickerViewController.h"

@interface ViewController : UIViewController<LocationPickerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

- (IBAction)openMapButton_Clicked:(id)sender;

@end

