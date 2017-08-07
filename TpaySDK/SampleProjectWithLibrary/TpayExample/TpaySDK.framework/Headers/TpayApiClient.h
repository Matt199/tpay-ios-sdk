//
//  TpayApiClient.h
//  TpayExample
//
//  Created by Darek Sęk on 19.06.2017.
//  Copyright © 2017 tpay.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TpayBlikTransaction.h"

@protocol TpayBlikTransactionDelegate <NSObject>

/***********************************
 ******* Payment did succeed.
 ***********************************/
- (void) tpayDidSucceedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id) responseObject;

/***********************************
 ******* Payment failed.
 ***********************************/
- (void) tpayDidFailedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id) responseObject;

@end

@interface TpayApiClient : NSObject

/***********************************
 ******* Implement this delegate to get payment success/fail responses.
 ***********************************/
@property (weak, nonatomic) id<TpayBlikTransactionDelegate> delegate;

/***********************************
 ******* Key - a unique access string generated in the Payee Panel on the tab Settings-> API
 ***********************************/
- (void) payWithBlikTransaction:(TpayBlikTransaction *)transaction withKey: (NSString *)key;

@end
