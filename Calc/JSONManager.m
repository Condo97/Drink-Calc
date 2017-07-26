//
//  JSONManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "JSONManager.h"
#import "ArchiverManager.h"
#import "UIImage+BlurExtension.h"

@implementation JSONManager

+ (id)sharedManager {
    static JSONManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (NSMutableArray *) getRingNamesInOrderWithJSONDictionary:(NSDictionary *)json {
    NSMutableArray *ringNames = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [ringNames addObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"ringName"]];
    }
    
    return ringNames;
}

- (NSMutableDictionary *) getRingNamesAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRings = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRings setObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"ringColorHex"] forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRings;
}

- (NSMutableDictionary *) getRingIDsAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRings = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRings setObject: [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"ringID"] forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRings;
}

- (NSMutableDictionary *) getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingMeasurements = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        NSString *measurementTypeString = [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"measurementType"];
        measurementTypeString = [[measurementTypeString componentsSeparatedByString:@"/"] objectAtIndex:0];
        [allRingMeasurements setObject:measurementTypeString  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingMeasurements;
}

- (NSMutableDictionary *) getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingMeasurements = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        NSString *measurementTypeString = [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"measurementType"];
        measurementTypeString = [[measurementTypeString componentsSeparatedByString:@"/"] objectAtIndex:1];
        [allRingMeasurements setObject:measurementTypeString  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingMeasurements;
}

//- (NSMutableDictionary *) getRingReadUnitTypesAsDictionaryWithJSONDictionary:(NSDictionary *)json {
//    NSMutableDictionary *allRingMeasurements = [[NSMutableDictionary alloc] init];
//    
//    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
//        NSString *measurementTypeString = [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"measurementType"];
//        measurementTypeString = [[measurementTypeString componentsSeparatedByString:@"/"] objectAtIndex:0];
//        [allRingMeasurements setObject:measurementTypeString  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
//    }
//    
//    return allRingMeasurements;
//}

- (NSMutableDictionary *) getRingIAPIDsAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingIAPIDs = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRingIAPIDs setObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"iapID"]  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingIAPIDs;
}

- (NSMutableDictionary *) getRingLimitEquationsAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingLimitEquations = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRingLimitEquations setObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"limitCalculation"]  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingLimitEquations;
}

- (NSMutableDictionary *) getRingHKReadTypesAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingHKReadTypes = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRingHKReadTypes setObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"hkIdentifiersToRead"]  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingHKReadTypes;
}

- (NSMutableDictionary *) getRingHKWriteTypesAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingHKWriteTypes = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRingHKWriteTypes setObject:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"hkIdentifiersToWrite"]  forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingHKWriteTypes;
}

- (NSMutableDictionary *) getRingThingsToMeasureAsDictionaryWithJSONDictionary:(NSDictionary *)json {
    NSMutableDictionary *allRingThingsToMeasure = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [allRingThingsToMeasure setObject: [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"thingToMeasure"] forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    return allRingThingsToMeasure;
}

- (NSMutableArray *) getGeneralDrinksAsArrayWithJSONDictionary:(NSDictionary *)json andRingIndex:(NSInteger)ringIndex {
    NSMutableArray *allGeneralDrinks = [[NSMutableArray alloc] init];
    
    for(NSInteger i = 0; i < [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:ringIndex] mutableArrayValueForKey:@"generalDrinks"].count; i++) {
        [allGeneralDrinks addObject:[[[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:ringIndex] mutableArrayValueForKey:@"generalDrinks"] objectAtIndex:i] valueForKey:@"generalDrinkName"]];
    }
    
    return allGeneralDrinks;
}

- (NSMutableDictionary *) getSpecificDrinksAsDictionaryWithJSONDictionary:(NSDictionary *)json andRingIndex:(NSInteger)ringIndex andGeneralDrinkIndex:(NSInteger)generalDrinkIndex {
    NSMutableDictionary *allSpecificDrinks = [[NSMutableDictionary alloc] init];
    
    for(NSInteger i = 0; i < [[[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:ringIndex] mutableArrayValueForKey:@"generalDrinks"] objectAtIndex:generalDrinkIndex] mutableArrayValueForKey:@"specificDrinks"].count; i++) {
        [allSpecificDrinks setObject:[[[[[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:ringIndex] mutableArrayValueForKey:@"generalDrinks"] objectAtIndex:generalDrinkIndex] mutableArrayValueForKey:@"specificDrinks"] objectAtIndex:i] valueForKey:@"amount"] forKey:[[[[[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:ringIndex] mutableArrayValueForKey:@"generalDrinks"] objectAtIndex:generalDrinkIndex] mutableArrayValueForKey:@"specificDrinks"] objectAtIndex:i] valueForKey:@"name"]];
    }
    
    return allSpecificDrinks;
}

- (NSString *) getRingNameForRingID:(NSString *)ringID withJSONDictionary:(NSDictionary *)json {
    NSDictionary *allRingIDs = [self getRingIDsAsDictionaryWithJSONDictionary:json];
    for(int i = 0; i < [allRingIDs allKeys].count; i++) {
        if([[allRingIDs valueForKey:[[allRingIDs allKeys] objectAtIndex:i]] isEqualToString:ringID])
            return [allRingIDs valueForKey:[[allRingIDs allKeys] objectAtIndex:i]];
    }
    return nil;
}

#pragma mark - Image stuff

- (void) setupScrollviewBackgroundImagesWithJSONDictionary:(NSDictionary *)json withImageSize:(CGSize)imageSize {
    NSMutableDictionary *imageURLDictionary = [[NSMutableDictionary alloc] init];
    
    for(int i = 0; i < [json mutableArrayValueForKey:@"rings"].count; i++) {
        [imageURLDictionary setObject: [[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] valueForKey:@"collageImages"] forKey:[[[json mutableArrayValueForKey:@"rings"] objectAtIndex:i] objectForKey:@"ringName"]];
    }
    
    NSDictionary *scrollViewBGImageURLsFromStore = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"scrollViewBGImageURLs"]];
    
    if(![scrollViewBGImageURLsFromStore isEqual:imageURLDictionary]) {
        NSMutableDictionary *finalImageDataDictionary = [[NSMutableDictionary alloc] init];
        for(int i = 0; i < [imageURLDictionary allKeys].count; i++) {
            NSArray *imageURLArray = [imageURLDictionary objectForKey:[[imageURLDictionary allKeys] objectAtIndex:i]];
            NSMutableArray *finalImageDataArray = [[NSMutableArray alloc] init];
            
            for(NSString *imageURL in imageURLArray) {
                NSData *imageData = [[NSData alloc] init];
                if(![imageURL isEqual:[NSNull null]]) {
                    imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
                    UIImage *finalImage = [self slideShowImageWithImage:[UIImage imageWithData:imageData] andSize:imageSize];
                    imageData = UIImagePNGRepresentation(finalImage);
                }
                [finalImageDataArray addObject:imageData];
            }
            
            [finalImageDataDictionary setObject:finalImageDataArray forKey:[[imageURLDictionary allKeys] objectAtIndex:i]];
        }
        
        [[ArchiverManager sharedManager] saveDataToDisk:[NSKeyedArchiver archivedDataWithRootObject:imageURLDictionary] withFileName:@"scrollViewBGImageURLs"];
        [[ArchiverManager sharedManager] saveDataToDisk:[NSKeyedArchiver archivedDataWithRootObject:finalImageDataDictionary] withFileName:@"scrollViewBGImageData"];
    }
}

- (NSMutableDictionary *) getImageDictionaryWithDataDictionary:(NSDictionary *)dataDictionary {
    NSMutableDictionary *finalImageDictionary = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < [dataDictionary allKeys].count; i++) {
        NSArray *imageDataArray = [dataDictionary objectForKey:[[dataDictionary allKeys] objectAtIndex:i]];
        NSMutableArray *imageArray = [[NSMutableArray alloc] init];
        for(NSData *imageData in imageDataArray) {
            if([imageData isEqualToData:[[NSData alloc] init]])
                [imageArray addObject:[[UIImage alloc] init]];
            else
                [imageArray addObject:[UIImage imageWithData:imageData]];
        }
        
        [finalImageDictionary setObject:imageArray forKey:[[dataDictionary allKeys] objectAtIndex:i]];
    }
    
    return finalImageDictionary;
}

- (UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *) slideShowImageWithImage:(UIImage *)image andSize:(CGSize)imageSize {
    return [[self imageWithImage:image scaledToSize:imageSize] blurredImageWithRadius:14.0];
}

@end
