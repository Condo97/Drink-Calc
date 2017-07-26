//
//  CDHandler.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/13/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "CDManager.h"
#import "AppDelegate.h"
#import "JSONManager.h"
#import "ArchiverManager.h"
#import "HTTPManager.h"

@implementation CDManager

+ (id)sharedManager {
    static CDManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) setupRingStore {
    //NSArray *rings = [self getDataArrayForEntityNamed:@"Ring"];
    //NSMutableArray *name, *amount, *limit, *angle; //CDHandler Objects
    
    //Setup JSON and read it
    NSDictionary *json = [[HTTPManager sharedManager] getJSONFromURL:@"138.197.109.254:8118/func1:8118/func1" withArguments:nil];
    if(json != nil) {
        NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:json];
    
        [[ArchiverManager sharedManager] saveDataToDisk:jsonData withFileName:@"allJson"];
    }
    
    //[self getParsedRingData:rings outputRingName:&name outputAmount:&amount outputLimit:&limit outputRingToAngle:&angle];
    
//    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
//    NSMutableDictionary *ringDictionary = [[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson]; //This is the proper order
//
//    if(ringDictionary.count != name.count) {
//        double difference = ringDictionary.count - name.count;
//        if(difference > 0) {
//            for(int i = 0; i < difference; i++) {
//                NSArray *initArray = [NSArray arrayWithObjects:@"0", @"1", [[ringDictionary allKeys] objectAtIndex:i], nil];
//                [self saveDataArray:initArray forEntityNamed:@"Ring" forAttributesNamed:@"amount", @"limit", @"name"];
//            }
//
//            for(int i = 0; i < [ringDictionary allKeys].count; i++) {
//                for(int j = 0; j < name.count; j++) {
//                    if([[[ringDictionary allKeys] objectAtIndex:i] isEqual:[name objectAtIndex:j]]) {
//                        [self saveRingDataWithName:[name objectAtIndex:j] andAmount:[amount objectAtIndex:j] andLimit:[limit objectAtIndex:j] andRingIndex:i];
//                    } else {
//                        [self saveRingDataWithName:[[ringsJson allKeys] objectAtIndex:i] andAmount:@"0" andLimit:@"1" andRingIndex:i];
//                    }
//                }
//            }
//        }
//    }
    
//    for(int i = 0; i < [ringDictionary allKeys].count; i++) {
//        if(name.count < i) {
//            if(name[i] != [[ringDictionary allKeys] objectAtIndex:i]) {
//                //Ring name from JSON does not correspond to the ring name that is stored!
//            } else {
//                //Everything is good!
//            }
//        } else {
//            //Ring that is in JSON does not exist in store!
//            NSArray *initArray = [NSArray arrayWithObjects:@"", @"", [[ringDictionary allKeys] objectAtIndex:i], nil];
//            [self saveDataArray:initArray forEntityNamed:@"Ring" forAttributesNamed:@"amount", @"limit", @"name"];
//        }
//    }
}

- (NSArray *) getDataArrayForEntityNamed:(NSString *)entity {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
    NSError *error;
    NSArray *resultArray = [context executeFetchRequest:request error:&error];
    
    if(error == nil) {
        return resultArray;
    }
    return [[NSArray alloc] init];
}

- (void) saveDataArray:(NSArray *)data forEntityNamed:(NSString *)entity forAttributesNamed:(NSString *)attribute,... {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
    
    NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
    NSString *arg;
    va_list args;
    if(attribute) {
        [attributeArray addObject:attribute];
        va_start(args, attribute);
        while((arg = va_arg(args, NSString *)) != nil) {
            [attributeArray addObject:arg];
        }
        va_end(args);
    }
    
    for(NSInteger i = 0; i < data.count; i++) {
        [managedObject setValue:data[i] forKey:attributeArray[i%(attributeArray.count)]];
    }
    
    NSError *error;
    [context save:&error];
}

- (void) updateDataArray:(NSArray *)data forEntityNamed:(NSString *)entity withIndex:(double)index forAttributesNamed:(NSString *)attribute,... {
    NSManagedObjectContext *context = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    NSManagedObject *managedObject;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    managedObject =  [results objectAtIndex:index];
    
    NSMutableArray *attributeArray = [[NSMutableArray alloc] init];
    NSString *arg;
    va_list args;
    if(attribute) {
        [attributeArray addObject:attribute];
        va_start(args, attribute);
        while((arg = va_arg(args, NSString *)) != nil) {
            [attributeArray addObject:arg];
        }
        va_end(args);
    }
//    va_start(args, attribute);
//    for(NSString *arg = attribute; arg != nil; arg = va_arg(args, NSString *)) {
//        [attributeArray addObject:arg];
//    }
    
    for(NSInteger i = 0; i < data.count; i++) {
        [managedObject setValue:data[i] forKey:attributeArray[i%(attributeArray.count)]];
    }
    
    NSError *error2;
    [context save:&error2];
}

- (void) getParsedRingDataForTodayForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp {
    NSMutableArray *outputRingID = [[NSMutableArray alloc] init];
    NSMutableArray *outputAmountInitial = [[NSMutableArray alloc] init];
    int outputLimitInitial = 0;
    NSMutableArray *toAngleInitial = [[NSMutableArray alloc] init];
    NSMutableArray *dateStampInitial = [[NSMutableArray alloc] init];
    
    NSDate *nowDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *nowDay = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:nowDate];
    
    for(NSManagedObject *object in ringDataArray) {
        NSString *ringID = [object valueForKey:@"ringID"];
        NSString *amount = [object valueForKey:@"amount"];
        NSDate *date = [object valueForKey:@"dateStamp"];
        
        if([filterRingID isEqual:ringID] && [nowDay isEqual:[calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date]]) {
            [outputRingID addObject:ringID];
            [outputAmountInitial addObject:amount];
            [dateStampInitial addObject:date];
            double amountValue = [amount intValue];
            double percent = amountValue/outputLimitInitial;
            double finalAngle = percent*360.0;
            
            [toAngleInitial addObject:[NSString stringWithFormat:@"%f", finalAngle]];
        }
    }
    
    *ringID = outputRingID;
    *amount = outputAmountInitial;
    *dateStamp = dateStampInitial;
}

- (void) getParsedRingDataForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp {
    NSMutableArray *outputRingID = [[NSMutableArray alloc] init];
    NSMutableArray *outputAmountInitial = [[NSMutableArray alloc] init];
    int outputLimitInitial = 0;
    NSMutableArray *toAngleInitial = [[NSMutableArray alloc] init];
    NSMutableArray *dateStampInitial = [[NSMutableArray alloc] init];
    
    for(NSManagedObject *object in ringDataArray) {
        NSString *ringID = [object valueForKey:@"ringID"];
        NSString *amount = [object valueForKey:@"amount"];
        NSString *date = [object valueForKey:@"dateStamp"];
        
        if([filterRingID isEqual:ringID]) {
            [outputRingID addObject:ringID];
            [outputAmountInitial addObject:amount];
            [dateStampInitial addObject:date];
            double amountValue = [amount intValue];
            double percent = amountValue/outputLimitInitial;
            double finalAngle = percent*360.0;
            
            [toAngleInitial addObject:[NSString stringWithFormat:@"%f", finalAngle]];
        }
    }
    
    *ringID = outputRingID;
    *amount = outputAmountInitial;
    *dateStamp = dateStampInitial;
}

- (NSDictionary *) getAllRingDataWithRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID {
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    for(NSManagedObject *object in ringDataArray) {
        NSString *ringID = [object valueForKey:@"ringID"];
        NSString *amount = [object valueForKey:@"amount"];
        NSDate *date = [object valueForKey:@"dateStamp"];
        
        if([filterRingID isEqual:ringID]) {
            [resultDictionary setObject:[NSNumber numberWithInt:[amount intValue]] forKey:date];
        }
    }
    
    return resultDictionary;
}

- (void) saveRingDataWithRingID:(NSString *)ringID andAmount:(NSString *)amount andLimit:(NSString *)limit {
    NSDate *nowDate = [NSDate date];
    
    NSArray *ringDataArray = [NSArray arrayWithObjects:ringID, amount, nowDate, nil];
    NSArray *limitDataArray = [NSArray arrayWithObjects:ringID, limit, nil];
    
    [self saveDataArray:ringDataArray forEntityNamed:@"Ring" forAttributesNamed:@"ringID", @"amount", @"dateStamp", nil];
    [self saveDataArray:limitDataArray forEntityNamed:@"UserLimit" forAttributesNamed:@"ringID", @"limit", nil];
}

- (UIColor *) colorWithHexString:(NSString *)hexString {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return [UIColor grayColor];
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6)
        return  [UIColor grayColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (double) getRingAngleForAmount:(int)amount andLimit:(int)limit {
    double amountValue = amount;
    double limitValue = limit;
    double percent = 0;
    if(limitValue != 0)
        percent = amountValue/limitValue;
    if(percent >= 1.0)
        percent = 1.0;
    return percent*360.0;
}

@end
