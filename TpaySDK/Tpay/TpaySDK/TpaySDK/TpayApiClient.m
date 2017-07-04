#import "TpayApiClient.h"

@implementation TpayApiClient

- (void) payWithBlikTransaction:(TpayBlikTransaction *)transaction withKey: (NSString *)key {
    
    [self postCreateRequest:transaction withKey:key];
}

- (void) postCreateRequest:(TpayBlikTransaction *)transaction withKey: (NSString *)key {
    
    NSString* urlString = [NSString stringWithFormat:@"https://secure.tpay.com/api/gw/%@/transaction/create", key];
    NSURL *url = [NSURL URLWithString:urlString];

    NSString *post = transaction.urlEncodedStringForCreateMethod;
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval: 105];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                if (error == nil) {
                    NSDictionary *responseObject = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                    if ([responseObject[@"result"] longValue]  == 1) {
                        [self postBlikRequest:transaction withKey:key andTransactionTitle:responseObject[@"title"]];
                    } else {
                        [self.delegate tpayDidFailedWithBlikTransaction:transaction andResponse:responseObject];
                    }
                } else {
                    [self.delegate tpayDidFailedWithBlikTransaction:transaction andResponse:error];
                }

            }] resume];
   }

- (void) postBlikRequest:(TpayBlikTransaction *)transaction withKey: (NSString *)key andTransactionTitle: (NSString *) title {
    
    NSString* urlString = [NSString stringWithFormat:@"https://secure.tpay.com/api/gw/%@/transaction/blik", key];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSString *post = [transaction urlEncodedStringForBlikMethodWithTitle:title];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval: 105];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    if (error == nil) {
                        NSDictionary *responseObject = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        if ([responseObject[@"result"] longValue]  == 1) {
                            [self.delegate tpayDidSucceedWithBlikTransaction:transaction andResponse:responseObject];
                        } else {
                            [self.delegate tpayDidFailedWithBlikTransaction:transaction andResponse:responseObject];
                        }
                    } else {
                        [self.delegate tpayDidFailedWithBlikTransaction:transaction andResponse:error];
                    }
                    
                }] resume];
    }

@end
