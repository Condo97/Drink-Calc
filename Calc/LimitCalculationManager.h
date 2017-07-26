//
//  LimitCalculationManager.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/19/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HealthKitManager.h"

@interface LimitCalculationManager : NSObject

+ (LimitCalculationManager *)sharedManager;
- (void) calculateLimitWithEquation:(NSString *)theEquation andRingName:(NSString *)ringName withCompletion:(completionForHEKKINfetchOfLimit)completion;

@end
