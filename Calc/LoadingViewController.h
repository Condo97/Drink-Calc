//
//  LoadingViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/11/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONManager.h"

@interface LoadingViewController : UIViewController <JSONManagerDelegate>

@property (nonatomic) CGSize imageSize;
@property (strong, nonatomic) NSDictionary *jsonDictionary;

@end
