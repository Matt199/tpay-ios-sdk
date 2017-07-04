#import "TpayBlikTransaction.h"
#import <CommonCrypto/CommonDigest.h>
#import "Consts.h"

@implementation TpayBlikTransaction

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _md5 = [coder decodeObjectForKey:kMd5];
        _mId = [coder decodeObjectForKey:kIdKey];
        _mAmount = [coder decodeObjectForKey:kAmountKey];
        _mDescription = [coder decodeObjectForKey:kDescriptionKey];
        _mCrc = [coder decodeObjectForKey:kCrcKey];
        _mSecurityCode = [coder decodeObjectForKey:kSecurityCodeKey];
        _mResultUrl = [coder decodeObjectForKey:kResultUrlKey];
        _mResultEmail = [coder decodeObjectForKey:kResultEmailKey];
        _mSellerDescription = [coder decodeObjectForKey:kSellerDescriptionKey];
        _mAdditionalDescription = [coder decodeObjectForKey:kAdditionalDescriptionKey];
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
        
        _mApiPassword = [coder decodeObjectForKey:kApiPassword];
        _mBlikCode = [coder decodeObjectForKey:kBlikCode];
        _mBlikAlias = [coder decodeObjectForKey:kBlikAlias];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_md5 forKey:kMd5];
    [coder encodeObject:_mId forKey:kIdKey];
    [coder encodeObject:_mAmount forKey:kAmountKey];
    [coder encodeObject:_mDescription forKey:kDescriptionKey];
    [coder encodeObject:_mCrc forKey:kCrcKey];
    [coder encodeObject:_mSecurityCode forKey:kSecurityCodeKey];
    [coder encodeObject:_mResultUrl forKey:kResultUrlKey];
    [coder encodeObject:_mResultEmail forKey:kResultEmailKey];
    [coder encodeObject:_mSellerDescription forKey:kSellerDescriptionKey];
    [coder encodeObject:_mAdditionalDescription forKey:kAdditionalDescriptionKey];
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
    
    [coder encodeObject:_mApiPassword forKey:kApiPassword];
    [coder encodeObject:_mBlikCode forKey:kBlikCode];
    [coder encodeObject:_mBlikAlias forKey:kBlikAlias];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"TpayBlikTransaction{md5='%@', mId='%@', mAmount='%@', mDescription='%@', mCrc='%@', mSecurityCode='%@', mResultUrl='%@', mResultEmail='%@', mSellerDescription='%@', mAdditionalDescription='%@', mReturnUrl='%@', mReturnErrorUrl='%@', mLanguage='%@', mClientEmail='%@', mClientName='%@', mClientAddress='%@', mClientCity='%@', mClientCode='%@', mClientCountry='%@', mClientPhone='%@', mApiPassword='%@', mBlikCode='%@', mBlikAlias='%@'}", _md5, _mId, _mAmount, _mDescription, _mCrc, _mSecurityCode, _mResultUrl, _mResultEmail, _mSellerDescription, _mAdditionalDescription, _mReturnUrl, _mReturnErrorUrl, _mLanguage, _mClientEmail, _mClientName, _mClientAddress, _mClientCity, _mClientCode, _mClientCountry, _mClientPhone, _mApiPassword, _mBlikCode, _mBlikAlias];
}

- (void)addBlikAlias:(NSString *)alias withLabel: (NSString *)label andKey: (NSString *)key {
    
    if (_mBlikAlias == nil) {
        _mBlikAlias = [NSMutableArray new];
    }
    
    NSMutableDictionary<NSString*, NSString*> *aliasMap = [NSMutableDictionary new];
    aliasMap[@"type"] = @"UID";
    aliasMap[@"value"] = alias;
    
    if (label != nil) {
        aliasMap[@"label"] = label;
    }
    
    if (key != nil) {
        aliasMap[@"key"] = label;
    }
    
    [_mBlikAlias addObject:aliasMap];
}

- (NSString *)urlEncodedStringForCreateMethod {
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    parameters[@"api_password"] = _mApiPassword;
    parameters[@"id"] = _mId;
    parameters[@"kwota"] = _mAmount;
    parameters[@"opis"] = _mDescription;
    parameters[@"crc"] = _mCrc;
    parameters[@"wyn_url"] = _mResultUrl;
    parameters[@"wyn_email"] = _mResultEmail;
    parameters[@"opis_sprzed"] = _mSellerDescription;
    parameters[@"opis_dodatkowy"] = _mAdditionalDescription;
    parameters[@"pow_url"] = _mReturnUrl;
    parameters[@"pow_url_blad"] = _mReturnErrorUrl;
    parameters[@"jezyk"] = _mLanguage;
    parameters[@"email"] = _mClientEmail;
    parameters[@"nazwisko"] = _mClientName;
    parameters[@"adres"] = _mClientAddress;
    parameters[@"miasto"] = _mClientCity;
    parameters[@"kod"] = _mClientCode;
    parameters[@"kraj"] = _mClientCountry;
    parameters[@"telefon"] = _mClientPhone;
    parameters[@"kraj"] = _mClientCountry;

    if (_md5 == nil) {
        _md5 = [TpayBlikTransaction md5: [NSString stringWithFormat:@"%@%@%@%@", _mId, _mAmount, _mCrc, _mSecurityCode]];
    }
    parameters[@"md5sum"] = _md5;
    
    parameters[@"kanal"] = @"64";
    parameters[@"json"] = @"1";
    
    return [TpayBlikTransaction urlEncodedStringForParameters:parameters];
}

- (NSString *)urlEncodedStringForBlikMethodWithTitle:(NSString *)title {
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    parameters[@"api_password"] = _mApiPassword;
    parameters[@"title"] = title;
    parameters[@"json"] = @"1";
    
    if ([_mBlikCode length] > 0) {
        parameters[@"code"] = _mBlikCode;
    }
    
    if (_mBlikAlias != nil) {
        int counter = 0;
        for (NSDictionary<NSString*, NSString*> *aliasMap in _mBlikAlias) {
            NSString *value = aliasMap[@"value"];
            NSString *key = aliasMap[@"key"];
            NSString *label = aliasMap[@"label"];
            NSString *type = aliasMap[@"type"];

            parameters[[NSString stringWithFormat:@"alias[%d][value]",counter]] = value;
            parameters[[NSString stringWithFormat:@"alias[%d][key]",counter]] = key;
            parameters[[NSString stringWithFormat:@"alias[%d][label]",counter]] = label;
            parameters[[NSString stringWithFormat:@"alias[%d][type]",counter]] = type;

            counter++;
        }
    }
    
    return [TpayBlikTransaction urlEncodedStringForParameters:parameters];
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *)urlEncodedStringForParameters:(NSDictionary *)parameters {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in parameters) {
        id value = [parameters objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [TpayBlikTransaction urlEncode: key], [TpayBlikTransaction urlEncode: value]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

+ (NSString *)urlEncode:(id)object {
    NSString *string = [TpayBlikTransaction toString:object];
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters: set];
}

+ (NSString *)toString:(id)object {
    return [NSString stringWithFormat: @"%@", object];
}

@end
