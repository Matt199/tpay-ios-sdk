#import "TpayViewController.h"
#import "TpayPayment.h"
#import <CommonCrypto/CommonDigest.h>
#import <WebKit/WebKit.h>

@interface TpayViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

NSString * const kServiceUrl = @"https://secure.transferuj.pl/?";

@implementation TpayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.payment == nil && [self.delegate respondsToSelector:@selector(tpayDidFailedWithPayment:)]) {
        [self.delegate tpayDidFailedWithPayment:self.payment];
        return;
    }
    
    NSString *urlString = nil;
    if (self.payment.mPaymentLink != nil) {
        urlString = self.payment.mPaymentLink;
    } else {
        urlString = [TpayViewController buildTransferLink:self.payment];
        if (urlString == nil && [self.delegate respondsToSelector:@selector(tpayDidFailedWithPayment:)]) {
            [self.delegate tpayDidFailedWithPayment:self.payment];
            return;
        }
    }
    
    NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:set]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.navigationController.navigationBar.translucent = YES;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeTop relatedBy:0 toItem:self.webView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:0 toItem:self.webView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:0 toItem:self.webView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:0 toItem:self.webView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    
    [self.webView loadRequest:urlRequest];
    
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.activityIndicatorView];
        [self.view bringSubviewToFront:self.activityIndicatorView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.hidesWhenStopped = YES;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if ([navigationAction.request.URL.absoluteString isEqualToString:self.payment.mReturnUrl] && [self.delegate respondsToSelector:@selector(tpayDidSucceedWithPayment:)]) {
        [self.delegate tpayDidSucceedWithPayment:self.payment];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if ([navigationAction.request.URL.absoluteString isEqualToString:self.payment.mReturnErrorUrl] && [self.delegate respondsToSelector:@selector(tpayDidFailedWithPayment:)]) {
        [self.delegate tpayDidFailedWithPayment:self.payment];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    self.activityIndicatorView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.activityIndicatorView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"Failed to load with error :%@", [error debugDescription]);
    [self.activityIndicatorView stopAnimating];
    [webView stopLoading];
    if ([self.delegate respondsToSelector:@selector(tpayDidFailedWithPayment:)]) {
        [self.delegate tpayDidFailedWithPayment:self.payment];
    }
}

+ (NSString *)buildTransferLink:(TpayPayment *)payment {
    if (payment.mReturnUrl == nil) {
        payment.mReturnUrl = @"https://apple.com/success";
    }
    
    if (payment.mReturnErrorUrl == nil) {
        payment.mReturnErrorUrl = @"https://apple.com/error";
    }
    
    NSString *urlString = kServiceUrl;
    
    urlString = [urlString stringByAppendingString:@"id="];
    if (payment.mId == nil) {
        return nil;
    }
    urlString = [urlString stringByAppendingString:payment.mId];
    
    urlString = [urlString stringByAppendingString:@"&kwota="];
    if (payment.mAmount == nil) {
        return nil;
    }
    urlString = [urlString stringByAppendingString:payment.mAmount];
    
    urlString = [urlString stringByAppendingString:@"&opis="];
    if (payment.mDescription == nil) {
        return nil;
    }
    urlString = [urlString stringByAppendingString:payment.mDescription];
    
    if (payment.mCrc == nil) {
        urlString = [urlString stringByAppendingString:@"&md5sum="];
        if (payment.mSecurityCode == nil) {
            return nil;
        }
        urlString = [urlString stringByAppendingString:[TpayViewController md5:[NSString stringWithFormat:@"%@%@%@", payment.mId, payment.mAmount, payment.mSecurityCode]]];
    } else {
        urlString = [urlString stringByAppendingString:@"&crc="];
        if (payment.mCrc == nil) {
            return nil;
        }
        urlString = [urlString stringByAppendingString:payment.mCrc];
        
        urlString = [urlString stringByAppendingString:@"&md5sum="];
        
        if (payment.md5 != nil) {
            urlString = [urlString stringByAppendingString:payment.md5];
        } else {
            if (payment.mSecurityCode == nil) {
                return nil;
            }
            urlString = [urlString stringByAppendingString:[TpayViewController md5:[NSString stringWithFormat:@"%@%@%@%@", payment.mId, payment.mAmount, payment.mCrc, payment.mSecurityCode]]];
        }
    }
    
    if (payment.mOnline != nil) {
        urlString = [urlString stringByAppendingString:@"&online="];
        urlString = [urlString stringByAppendingString:payment.mOnline];
    }
    
    if (payment.mCanal != nil) {
        urlString = [urlString stringByAppendingString:@"&kanal="];
        urlString = [urlString stringByAppendingString:payment.mCanal];
    }
    
    if (payment.mLock != nil) {
        urlString = [urlString stringByAppendingString:@"&zablokuj="];
        urlString = [urlString stringByAppendingString:payment.mLock];
    }
    
    if (payment.mResultUrl != nil) {
        urlString = [urlString stringByAppendingString:@"&wyn_url="];
        urlString = [urlString stringByAppendingString:payment.mResultUrl];
    }
    
    if (payment.mResultEmail != nil) {
        urlString = [urlString stringByAppendingString:@"&wyn_email="];
        urlString = [urlString stringByAppendingString:payment.mResultEmail];
    }
    
    if (payment.mSellerDescription != nil) {
        urlString = [urlString stringByAppendingString:@"&opis_sprzed="];
        urlString = [urlString stringByAppendingString:payment.mSellerDescription];
    }
    
    if (payment.mReturnUrl != nil) {
        urlString = [urlString stringByAppendingString:@"&pow_url="];
        urlString = [urlString stringByAppendingString:payment.mReturnUrl];
    }
    
    if (payment.mReturnErrorUrl != nil) {
        urlString = [urlString stringByAppendingString:@"&pow_url_blad="];
        urlString = [urlString stringByAppendingString:payment.mReturnErrorUrl];
    }
    
    if (payment.mLanguage != nil) {
        urlString = [urlString stringByAppendingString:@"&jezyk="];
        urlString = [urlString stringByAppendingString:payment.mLanguage];
    }
    
    if (payment.mClientEmail != nil) {
        urlString = [urlString stringByAppendingString:@"&email="];
        urlString = [urlString stringByAppendingString:payment.mClientEmail];
    }
    
    if (payment.mClientName != nil) {
        urlString = [urlString stringByAppendingString:@"&nazwisko="];
        urlString = [urlString stringByAppendingString:payment.mClientName];
    }
    
    if (payment.mClientAddress != nil) {
        urlString = [urlString stringByAppendingString:@"&adres="];
        urlString = [urlString stringByAppendingString:payment.mClientAddress];
    }
    
    if (payment.mClientCity != nil) {
        urlString = [urlString stringByAppendingString:@"&miasto="];
        urlString = [urlString stringByAppendingString:payment.mClientCity];
    }
    
    if (payment.mClientCode != nil) {
        urlString = [urlString stringByAppendingString:@"&kod="];
        urlString = [urlString stringByAppendingString:payment.mClientCode];
    }
    
    if (payment.mClientCountry != nil) {
        urlString = [urlString stringByAppendingString:@"&kraj="];
        urlString = [urlString stringByAppendingString:payment.mClientCountry];
    }
    
    if (payment.mClientPhone != nil) {
        urlString = [urlString stringByAppendingString:@"&telefon="];
        urlString = [urlString stringByAppendingString:payment.mClientPhone];
    }
    
    return urlString;
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

@end
