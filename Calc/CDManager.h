//
//  CDHandler.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/13/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface CDManager : NSObject

+ (id)sharedManager;
- (void) setupRingStore;
- (NSArray *) getDataArrayForEntityNamed:(NSString *)entity;
- (void) saveDataArray:(NSArray *)data forEntityNamed:(NSString *)entity forAttributesNamed:(NSString *)attribute,...;
- (void) updateDataArray:(NSArray *)data forEntityNamed:(NSString *)entity withIndex:(double)index forAttributesNamed:(NSString *)attribute,...;
- (void) getParsedRingDataForTodayForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp;
- (void) getParsedRingDataForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp;
- (NSDictionary *) getAllRingDataWithRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID;
- (void) saveRingDataWithRingID:(NSString *)ringID andAmount:(NSString *)amount andLimit:(NSString *)limit;
- (UIColor *) colorWithHexString:(NSString *)hexString;
- (double) getRingAngleForAmount:(int)amount andLimit:(int)limit;

@end
