//
//  HealthKitManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/11/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "HealthKitManager.h"
#import <HealthKit/HealthKit.h>
#import "JSONManager.h"
#import "ArchiverManager.h"

@interface HealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end

@implementation HealthKitManager

+ (HealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static HealthKitManager *sharedMyManager = nil;
    dispatch_once(&pred, ^{
        sharedMyManager = [[HealthKitManager alloc] init];
        sharedMyManager.healthStore = [[HKHealthStore alloc] init];
    });
    return sharedMyManager;
}

- (void) requestAuthorizationWithCompletion:(completion)completion {
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        completion(NO);
    }
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableDictionary *writeTypesUnparsed = [[JSONManager sharedManager] getRingHKWriteTypesAsDictionaryWithJSONDictionary:json];
    NSArray *readTypes = [NSArray arrayWithObjects:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight], [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex], [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth], nil];
    NSMutableArray *writeTypes = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [writeTypesUnparsed allKeys].count; i++) {
        for(NSArray *writeTypeArray in [writeTypesUnparsed objectForKey:[[writeTypesUnparsed allKeys] objectAtIndex:i]]) {
            NSString *writeType = [writeTypeArray objectAtIndex:0];
            if([writeType containsString:@"Quantity"]) {
                HKObjectType *type = [HKObjectType quantityTypeForIdentifier:writeType];
                if(![writeTypes containsObject:type])
                    [writeTypes addObject:type];
            } else if ([writeType containsString:@"Category"]) {
                HKCategoryType *type = [HKCategoryType categoryTypeForIdentifier:writeType];
                if(![writeTypes containsObject:type])
                    [writeTypes addObject:type];
            } else if ([writeType containsString:@"Characteristic"]) {
                HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:writeType];
                if(![writeTypes containsObject:type])
                    [writeTypes addObject:type];
            }
        }
    }
    
    if(writeTypes.count != 0) {
        [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes] readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL successful, NSError *error){
            if(!successful) {
                completion(NO);
            } else
                completion(YES);
        }];
        
    } else {
        NSLog(@"UH OH NOTHING WORKED IN HEALTHKIT");
        completion(NO);
    }
}

- (void) writeToHealthKitWithQuantityTypeIdentifier:(NSString *)quantityTypeIdentifier andValue:(double)value andUnit:(NSString *)unitString {
    HKUnit *unit = [HKUnit unitFromString:unitString];
    HKQuantity *quantity = [HKQuantity quantityWithUnit:unit doubleValue:value];
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:quantityTypeIdentifier];
    NSDate *now = [NSDate date];
    HKQuantitySample *quantitySample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:now endDate:now];
    
    [self.healthStore saveObject:quantitySample withCompletion:^(BOOL success, NSError *error){
        if(!success)
            NSLog(@"OH NO COULD NOT SAVE TO HEALTHKIT (%@)", error);
    }];
}

- (int) getAge {
    NSError *error;
    NSDateComponents *dateOfBirthComponents = [self.healthStore dateOfBirthComponentsWithError:&error];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateOfBirth = [calendar dateFromComponents:dateOfBirthComponents];
    
    if(dateOfBirth == nil) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"userAge"] intValue];
    }
    
    if(!dateOfBirth) {
        NSLog(@"%@", error);
        return 0;
    } else {
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:[NSDate date] options:0];
        return (int)ageComponents.year;
    }
}

- (NSDate *) getBirthdate {
    NSError *error;
    NSDateComponents *dateOfBirthComponents = [self.healthStore dateOfBirthComponentsWithError:&error];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateOfBirth = [calendar dateFromComponents:dateOfBirthComponents];
    
    if(dateOfBirth == nil) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"userBirthdate"];
    }
    
    return dateOfBirth;
}

- (int) getGender {
    NSError *error;
    HKBiologicalSexObject *gender = [self.healthStore biologicalSexWithError:&error];
    
    if([gender biologicalSex] == 0) {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"userGender"] intValue];
    }
    
    return [gender biologicalSex];
}

- (void) getWeightWithCompletion:(completionForHEKKINfetch)completion {
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:[NSArray arrayWithObject:sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if(results.count != 0)
            completion(YES, [[[results objectAtIndex:0] quantity] doubleValueForUnit:[HKUnit poundUnit]]);
        else
            completion(YES, [[[NSUserDefaults standardUserDefaults] objectForKey:@"userWeight"] intValue]);
    }];
    
    [self.healthStore executeQuery:query];
}

- (void) getHeightWithCompletion:(completionForHEKKINfetch)completion {
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:[NSArray arrayWithObject:sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if(results.count != 0)
            completion(YES, [[[results objectAtIndex:0] quantity] doubleValueForUnit:[HKUnit inchUnit]]);
        else
            completion(YES, [[NSUserDefaults standardUserDefaults] integerForKey:@"userHeightInInches"]);
    }];
    
    [self.healthStore executeQuery:query];
}

@end
