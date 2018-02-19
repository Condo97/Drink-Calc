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
- (void) saveDataArray:(NSArray *)data forEntityNamed:(NSString *)entity forAttributesNamed:(NSString *)attribute,...NS_REQUIRES_NIL_TERMINATION;
- (void) updateDataArray:(NSArray *)data forEntityNamed:(NSString *)entity withIndex:(double)index forAttributesNamed:(NSString *)attribute,...;
- (void) getParsedRingDataForTodayForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp outputName:(NSMutableArray **)name ;
- (void) getParsedRingDataForRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID outputRingID:(NSMutableArray **)ringID outputAmount:(NSMutableArray **)amount outputRingDateStamp:(NSMutableArray **)dateStamp outputName:(NSMutableArray **)name;
- (void) getParsedCustomDrinksForDataArray:(NSArray *)dataArray andFilterRingID:(NSString *)filterRingID andFilterGeneralDrinkName:(NSString *)filterGeneralDrinkName outputRingID:(NSMutableArray **)ringID outputDrinkName:(NSMutableArray **)drinkName outputDrinkAmount:(NSMutableArray **)drinkAmount outputIsShot:(NSMutableArray **)isShot;
- (NSDictionary *) getAllRingDataWithRingDataArray:(NSArray *)ringDataArray andFilterRingID:(NSString *)filterRingID;
- (NSString *) getDrinkNameWithRingDataArray:(NSArray *)ringDataArray andRingID:(NSString *)ringID andDateStamp:(NSDate *)dateStamp;
- (void) saveRingDataWithRingID:(NSString *)ringID andAmount:(NSString *)amount andLimit:(NSString *)limit andName:(NSString *)name;
- (BOOL) deleteRingDataWithRingID:(NSString *)ringID andTimeStamp:(NSDate *)timeStamp;
- (BOOL) deleteCustomDrinkWithRingID:(NSString *)ringID andDrinkName:(NSString *)drinkName;
- (UIColor *) colorWithHexString:(NSString *)hexString;
- (double) getRingAngleForAmount:(double)amount andLimit:(double)limit;

@end
