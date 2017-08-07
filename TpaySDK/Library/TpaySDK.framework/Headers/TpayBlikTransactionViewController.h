#import <UIKit/UIKit.h>
#import "TpayBlikTransaction.h"
#import "TpayApiClient.h"

@interface TpayBlikTransactionViewController : UIViewController

enum TpayBlikViewType : NSUInteger {
    kRegisteredAlias,
    kUnregisteredAlias,
    kNonUniqueAlias,
    kOnlyBlik};

@property (weak, nonatomic) id<TpayBlikTransactionDelegate> blikDelegate;
@property (nonatomic, strong) TpayBlikTransaction *blikTransaction;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) enum TpayBlikViewType viewType;

@end
