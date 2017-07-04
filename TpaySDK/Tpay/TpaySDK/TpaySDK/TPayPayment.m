#import "TpayPayment.h"
#import "Consts.h"

@implementation TpayPayment

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _md5 = [coder decodeObjectForKey:kMd5];
        _mPaymentLink = [coder decodeObjectForKey:kPaymentLinkKey];
        _mId = [coder decodeObjectForKey:kIdKey];
        _mAmount = [coder decodeObjectForKey:kAmountKey];
        _mDescription = [coder decodeObjectForKey:kDescriptionKey];
        _mCrc = [coder decodeObjectForKey:kCrcKey];
        _mSecurityCode = [coder decodeObjectForKey:kSecurityCodeKey];
        _mOnline = [coder decodeObjectForKey:kOnlineKey];
        _mCanal = [coder decodeObjectForKey:kCanalKey];
        _mLock = [coder decodeObjectForKey:kLockKey];
        _mResultUrl = [coder decodeObjectForKey:kResultUrlKey];
        _mResultEmail = [coder decodeObjectForKey:kResultEmailKey];
        _mSellerDescription = [coder decodeObjectForKey:kSellerDescriptionKey];
        _mReturnUrl = [coder decodeObjectForKey:kReturnUrlKey];
        _mReturnErrorUrl = [coder decodeObjectForKey:kReturnErrorUrlKey];
        _mLanguage = [coder decodeObjectForKey:kLanguageKey];
        _mClientEmail = [coder decodeObjectForKey:kClientEmailKey];
        _mClientName = [coder decodeObjectForKey:kClientNameKey];
        _mClientAddress = [coder decodeObjectForKey:kClientAddressKey];
        _mClientCity = [coder decodeObjectForKey:kClientCityKey];
        _mClientCode = [coder decodeObjectForKey:kClientCodeKey];
        _mClientCountry = [coder decodeObjectForKey:kClientCountryKey];
        _mClientPhone = [coder decodeObjectForKey:kClientPhoneKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_md5 forKey:kMd5];
    [coder encodeObject:_mPaymentLink forKey:kPaymentLinkKey];
    [coder encodeObject:_mId forKey:kIdKey];
    [coder encodeObject:_mAmount forKey:kAmountKey];
    [coder encodeObject:_mDescription forKey:kDescriptionKey];
    [coder encodeObject:_mCrc forKey:kCrcKey];
    [coder encodeObject:_mSecurityCode forKey:kSecurityCodeKey];
    [coder encodeObject:_mOnline forKey:kOnlineKey];
    [coder encodeObject:_mCanal forKey:kCanalKey];
    [coder encodeObject:_mLock forKey:kLockKey];
    [coder encodeObject:_mResultUrl forKey:kResultUrlKey];
    [coder encodeObject:_mResultEmail forKey:kResultEmailKey];
    [coder encodeObject:_mSellerDescription forKey:kSellerDescriptionKey];
    [coder encodeObject:_mReturnUrl forKey:kReturnUrlKey];
    [coder encodeObject:_mReturnErrorUrl forKey:kReturnErrorUrlKey];
    [coder encodeObject:_mLanguage forKey:kLanguageKey];
    [coder encodeObject:_mClientEmail forKey:kClientEmailKey];
    [coder encodeObject:_mClientName forKey:kClientNameKey];
    [coder encodeObject:_mClientAddress forKey:kClientAddressKey];
    [coder encodeObject:_mClientCity forKey:kClientCityKey];
    [coder encodeObject:_mClientCode forKey:kClientCodeKey];
    [coder encodeObject:_mClientCountry forKey:kClientCountryKey];
    [coder encodeObject:_mClientPhone forKey:kClientPhoneKey];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"TpayPayment{md5='%@', mPaymentLink='%@', mId='%@', mAmount='%@', mDescription='%@', mCrc='%@', mSecurityCode='%@', mOnline='%@', mCanal='%@', mLock='%@', mResultUrl='%@', mResultEmail='%@', mSellerDescription='%@', mReturnUrl='%@', mReturnErrorUrl='%@', mLanguage='%@', mClientEmail='%@', mClientName='%@', mClientAddress='%@', mClientCity='%@', mClientCode='%@', mClientCountry='%@', mClientPhone='%@'}", _md5, _mPaymentLink, _mId, _mAmount, _mDescription, _mCrc, _mSecurityCode, _mOnline, _mCanal, _mLock, _mResultUrl, _mResultEmail, _mSellerDescription, _mReturnUrl, _mReturnErrorUrl, _mLanguage, _mClientEmail, _mClientName, _mClientAddress, _mClientCity, _mClientCode, _mClientCountry, _mClientPhone];
}

@end
