#import <UIKit/UIKit.h>
#import <TpaySDK/TpayViewController.h>

@interface PaymentViewController : UIViewController <TpayPaymentDelegate>

@property (strong, nonatomic) TpayPayment *payment;

- (void)tpayDidSucceedWithPayment:(TpayPayment *)payment;
- (void)tpayDidFailedWithPayment:(TpayPayment *)payment;

@end
