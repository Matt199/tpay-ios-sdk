#import <UIKit/UIKit.h>

@class WKWebView;
@class TpayPayment;

@protocol TpayPaymentDelegate <NSObject>

/***********************************
 ******* Payment did succeed.
 ***********************************/
- (void) tpayDidSucceedWithPayment:(TpayPayment *)payment;

/***********************************
 ******* Payment failed.
 ***********************************/
- (void) tpayDidFailedWithPayment:(TpayPayment *)payment;

@end

@interface TpayViewController : UIViewController <UIWebViewDelegate>

/***********************************
 ******* Implement this delegate to get payment success/fail responses.
 ***********************************/
@property (weak, nonatomic) id<TpayPaymentDelegate> delegate;

/***********************************
 ******* Set this property before before view presentation.
 ******* For seciurity purposes make sure you use MD5 hash instead security code.
 ******* Use security code only if there is no possibility to calculate MD5 on the server-side.
 ***********************************/
@property (weak, nonatomic) TpayPayment *payment;

/***********************************
 ******* Creates default if not set.
 ***********************************/
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end
