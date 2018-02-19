//
//  HTTPManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "HTTPManager.h"

@implementation HTTPManager

+ (id)sharedManager {
    static HTTPManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (NSDictionary *) getJSONFromURL:(NSString *)url withArguments:(NSString *)arguments,... {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    url = [NSString stringWithFormat:@"http://%@?", url];
    
    va_list args;
    va_start(args, arguments);
    for(NSString *arg = arguments; arg != nil; arg = va_arg(args, NSString *)) {
        url = [NSString stringWithFormat:@"%@%@&", url, arg];
    }
    va_end(args);
    
    //[request setHTTPMethod:@"GET"];
    //[request setURL:[NSURL URLWithString:url]];
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];

    NSString *encodedUrlAsString = [url stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    //NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [NSURL URLWithString:encodedUrlAsString];
    
    dispatch_semaphore_t fd_sema = dispatch_semaphore_create(0);
    
    __block NSData *jsonData = [[NSData alloc] init];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:[NSURL URLWithString:encodedUrlAsString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if([responseCode statusCode] != 200) {
//            NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
//            return nil;
//        }
        
        jsonData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] dataUsingEncoding:NSUTF8StringEncoding]; //DISABLE NSAllowsArbitraryLoads
                                              
                                              dispatch_semaphore_signal(fd_sema);
    }];
    
    
    [downloadTask resume];
    
    dispatch_semaphore_wait(fd_sema, dispatch_time(DISPATCH_TIME_NOW, 7 * NSEC_PER_SEC)); //Add timeout
    
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
}

- (void) saveCustomDrinkWithRingName:(NSString *)ringName andGeneralDrinkName:(NSString *)generalDrinkName andSpecificDrinkName:(NSString *)specificDrinkName andAmount:(NSString *)amount andIsShot:(int)isShot {
    NSString *isShotString = @"";
    if(isShot == 1)
        isShotString = @"Yes";
    
    NSString *urlString = [NSString stringWithFormat:@"http://138.197.109.254:8118/saveCustomDrink?ringName=%@&generalDrinkName=%@&specificDrinkName=%@&amount=%@&isShot=%@", ringName, generalDrinkName, specificDrinkName, amount, isShotString];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodedUrlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:set];
    
    NSURLSessionTask *saveTask = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:encodedUrlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){}];
    [saveTask resume];
}

@end
