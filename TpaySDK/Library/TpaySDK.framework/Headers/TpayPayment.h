#import <Foundation/Foundation.h>

@interface TpayPayment : NSObject <NSCoding>

@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSString *mPaymentLink;
@property (nonatomic, strong) NSString *mId;
@property (nonatomic, strong) NSString *mAmount;
@property (nonatomic, strong) NSString *mDescription;
@property (nonatomic, strong) NSString *mCrc;
@property (nonatomic, strong) NSString *mSecurityCode;
@property (nonatomic, strong) NSString *mOnline;
@property (nonatomic, strong) NSString *mCanal;
@property (nonatomic, strong) NSString *mLock;
@property (nonatomic, strong) NSString *mResultUrl;
@property (nonatomic, strong) NSString *mResultEmail;
@property (nonatomic, strong) NSString *mSellerDescription;
@property (nonatomic, strong) NSString *mReturnUrl;
@property (nonatomic, strong) NSString *mReturnErrorUrl;
@property (nonatomic, strong) NSString *mLanguage;
@property (nonatomic, strong) NSString *mClientEmail;
@property (nonatomic, strong) NSString *mClientName;
@property (nonatomic, strong) NSString *mClientAddress;
@property (nonatomic, strong) NSString *mClientCity;
@property (nonatomic, strong) NSString *mClientCode;
@property (nonatomic, strong) NSString *mClientCountry;
@property (nonatomic, strong) NSString *mClientPhone;


- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (NSString *)description;

@end
