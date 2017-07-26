//
//  ViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 5/15/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KASlideShow.h"
#import "StoreKitManager.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, KASlideShowDataSource, StoreKitManagerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *ringScrollView;

@property (weak, nonatomic) IBOutlet UITextField *ringEntryTestField;
@property (weak, nonatomic) IBOutlet UITextField *ringEntryTestField2;

@property (weak, nonatomic) IBOutlet UITableView *drinksTableView;
@property (weak, nonatomic) IBOutlet KASlideShow *scrollViewBackgroundView;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@property (weak, nonatomic) IBOutlet UIImageView *leftArrow;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrow;

@end

