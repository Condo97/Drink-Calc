//
//  StoreKitManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/8/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "StoreKitManager.h"
#import "JSONManager.h"
#import "ArchiverManager.h"
#import "KFKeychain.h"

@interface StoreKitManager ()

@property (strong, nonatomic) SKProductsRequest *productsRequest;
@property (strong, nonatomic) NSArray *validProducts;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) NSMutableDictionary *productIDs;

@end

@implementation StoreKitManager

+ (id) sharedManager {
    static StoreKitManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) fetchAvailableProductsWithRingID:(int)ringID {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:ringID];
    NSDictionary *productIDs = [[JSONManager sharedManager] getRingIAPIDsAsDictionaryWithJSONDictionary:ringsJson];
    
    NSSet *productIDSet = [NSSet setWithObject:[productIDs objectForKey:currentRingName]];
    
    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDSet];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (BOOL) purchaseRingWithRingID:(int)ringID {
    [self fetchAvailableProductsWithRingID:ringID];
    
//    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
//    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:ringID];
//    NSDictionary *productIDs = [[JSONManager sharedManager] getRingIAPIDsAsDictionaryWithJSONDictionary:ringsJson];
//    NSString *currentProductID = [productIDs objectForKey:currentRingName];
    
    return YES;
}

#pragma mark - StoreKit stuffs

- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    int count = (int)[response.products count];
    if (count > 0) {
        self.validProducts = response.products;
        
        BOOL canMakePurchases = [SKPaymentQueue canMakePayments];
        
        
        if(canMakePurchases) {
            SKProduct *product = [self.validProducts objectAtIndex:0]; //MAKE DYNAMIC
            SKPayment *payment = [SKPayment paymentWithProduct:product];
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        } else {
            UIAlertController *tmp = [UIAlertController alertControllerWithTitle:@"Cannot Purchase" message:@"Your device is not configured for purchases." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *doneButton = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
            
            [tmp addAction:doneButton];
        }
    } else {
        UIAlertController *tmp = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"No products to purchase." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *doneButton = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
        
        [tmp addAction:doneButton];
    }
    [self.activityIndicatorView stopAnimating];
}

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                NSLog(@"Purchasing");
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"Purchase successful!");
                UIAlertController *tmp = [UIAlertController alertControllerWithTitle:@"Thank you!" message:@"This ring is now available for use." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *doneButton = [UIAlertAction actionWithTitle:@"Cool!" style:UIAlertActionStyleDefault handler:nil];
                
                [tmp addAction:doneButton];
                
                BOOL purchased = [KFKeychain saveObject:@"YES" forKey:[NSString stringWithFormat:@"%@Purchased", [[[transactions objectAtIndex:0] payment] productIdentifier]]];
                [KFKeychain saveObject:@"YES" forKey:@"adsRemoved"];
                NSLog(@"%d", purchased);
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                
                id<StoreKitManagerDelegate> storeKitDeleage = self.delegate;
                [storeKitDeleage purchaseSuccessful];
                
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"Restored ");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                NSLog(@"Purchase failed ");
                
                id<StoreKitManagerDelegate> storeKitDeleage = self.delegate;
                [storeKitDeleage purchaseUnsuccessful];
                
                break;
            }
            default:
                break;
        }
    }
}

- (void) restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        BOOL purchased = [KFKeychain saveObject:@"YES" forKey:[NSString stringWithFormat:@"%@Purchased", productID]];
        [KFKeychain saveObject:@"YES" forKey:@"adsRemoved"];
        NSLog(@"%d", purchased);
    }
}

- (void) resetKeychainForTesting {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSDictionary *productIDs = [[JSONManager sharedManager] getRingIAPIDsAsDictionaryWithJSONDictionary:ringsJson];
    
    for(int i = 0; i < [productIDs allKeys].count; i++) {
        [KFKeychain saveObject:@"NO" forKey:[NSString stringWithFormat:@"%@Purchased", [productIDs objectForKey:[[productIDs allKeys] objectAtIndex:i]]]];
    }
}

- (void) buyAllRingsForTesting {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSDictionary *productIDs = [[JSONManager sharedManager] getRingIAPIDsAsDictionaryWithJSONDictionary:ringsJson];
    
    for(int i = 0; i < [productIDs allKeys].count; i++) {
        [KFKeychain saveObject:@"YES" forKey:[NSString stringWithFormat:@"%@Purchased", [productIDs objectForKey:[[productIDs allKeys] objectAtIndex:i]]]];
    }
}

@end
