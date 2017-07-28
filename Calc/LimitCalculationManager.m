//
//  LimitCalculationManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/19/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "LimitCalculationManager.h"

@implementation LimitCalculationManager

+ (LimitCalculationManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static LimitCalculationManager *sharedMyManager = nil;
    dispatch_once(&pred, ^{
        sharedMyManager = [[LimitCalculationManager alloc] init];
    });
    return sharedMyManager;
}

- (void) calculateLimitWithEquation:(NSString *)equation andRingName:(NSString *)ringName withCompletion:(completionForHEKKINfetchOfLimit)completion {
        /** KEY
         w = weight (lbs)
         h = height (inches)
         a = age
         */
    
    if([[[[NSUserDefaults standardUserDefaults] objectForKey:@"ringAutoLimitDictionary"] objectForKey:ringName] isEqual: @YES]) {
        double weight = [[NSUserDefaults standardUserDefaults] integerForKey:@"userWeight"];
        double height = [[NSUserDefaults standardUserDefaults] integerForKey:@"userHeightInInches"];
        int gender = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userGender"];
        int age = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userAge"];
            
        if(gender == 1 || gender == 0) {
            equation = [equation componentsSeparatedByString:@"|"][0];
            if(age <= 12)
                equation = [equation componentsSeparatedByString:@")"][0];
            else if (age <= 18)
                equation = [equation componentsSeparatedByString:@")"][1];
            else
                equation = [equation componentsSeparatedByString:@")"][2];
        } else {
            equation = [equation componentsSeparatedByString:@"|"][1];
            if(age <= 12)
                equation = [equation componentsSeparatedByString:@")"][0];
            else if (age <= 18)
                equation = [equation componentsSeparatedByString:@")"][1];
            else
                equation = [equation componentsSeparatedByString:@")"][2];
        }
            
        equation = [equation stringByReplacingOccurrencesOfString:@"w" withString:[NSString stringWithFormat:@"%f", weight]];
        equation = [equation stringByReplacingOccurrencesOfString:@"h" withString:[NSString stringWithFormat:@"%f", height]];
        equation = [equation stringByReplacingOccurrencesOfString:@"a" withString:[NSString stringWithFormat:@"%d", age]];
            
        NSExpression *expression = [NSExpression expressionWithFormat:equation];
        NSNumber *result = [expression expressionValueWithObject:nil context:nil];
        double resultDouble = [result doubleValue];
        completion(YES, resultDouble, ringName);
    } else {
        double limit = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:ringName] doubleValue];
        completion(YES, limit, ringName);
    }
}

@end
