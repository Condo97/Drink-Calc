//
//  HealthKitManager.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/11/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^completion)(BOOL);
typedef void(^completionForHEKKINfetch)(BOOL, double);
typedef void(^completionForHEKKINfetchOfLimit)(BOOL, double, NSString *);

@interface HealthKitManager : NSObject

+ (HealthKitManager *)sharedManager;
- (void) requestAuthorizationWithCompletion:(completion)completion;
- (void) writeToHealthKitWithQuantityTypeIdentifier:(NSString *)quantityTypeIdentifier andValue:(double)value andUnit:(NSString *)unitString;
- (int) getAge;
- (NSDate *) getBirthdate;
- (int) getGender;
- (void) getWeightWithCompletion:(completionForHEKKINfetch)completion;
- (void) getHeightWithCompletion:(completionForHEKKINfetch)completion;

@end
