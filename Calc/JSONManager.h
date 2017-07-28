//
//  JSONManager.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JSONManager : NSObject

+ (id)sharedManager;
- (NSMutableArray *) getRingNamesInOrderWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingNamesAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingIDsAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingIAPIDsAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingLimitEquationsAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingTextsAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingHKReadTypesAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingHKWriteTypesAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableDictionary *) getRingThingsToMeasureAsDictionaryWithJSONDictionary:(NSDictionary *)json;
- (NSMutableArray *) getGeneralDrinksAsArrayWithJSONDictionary:(NSDictionary *)json andRingIndex:(NSInteger)ringIndex;
- (NSMutableDictionary *) getSpecificDrinksAsDictionaryWithJSONDictionary:(NSDictionary *)json andRingIndex:(NSInteger)ringIndex andGeneralDrinkIndex:(NSInteger)generalDrinkIndex;

- (void) setupScrollviewBackgroundImagesWithJSONDictionary:(NSDictionary *)json withImageSize:(CGSize)imageSize;
- (void) setupGeneralDrinkImagesWithJSONDictionary:(NSDictionary *)json withImageSize:(CGSize)imageSize andRingIndex:(int)ringIndex;
- (NSMutableDictionary *) getImageDictionaryWithDataDictionary:(NSDictionary *)dataDictionary;
- (NSMutableDictionary *) getImageDictionaryForGeneralDrinkImagesWithDataDictionary:(NSDictionary *)dataDictionary;

@end
