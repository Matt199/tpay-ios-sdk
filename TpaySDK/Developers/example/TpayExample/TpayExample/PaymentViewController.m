#import "PaymentViewController.h"
#import <TpaySDK/TpayPayment.h>
#import "TpaySDK/TpayApiClient.h"
#import "TpaySDK/TpayBlikTransaction.h"
#import "TpaySDK/TpayBlikTransactionViewController.h"

@interface PaymentViewController () <UITextFieldDelegate, TpayBlikTransactionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *blikCodeTextField;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

NSString * const kExtraPayment = @"EXTRA_PAYMENT";
int const kBlikCodeLength = 6;

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTestPayment];
    [self addLoadingView];
    
    _blikCodeTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)payButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"TpayPaymentInnerSegue" sender:nil];
}

- (void)createTestPayment {
    if (self.payment == nil) {
        self.payment = [TpayPayment new];
        
        self.payment.mId = @"1010";
        self.payment.mAmount = @"666.6";
        self.payment.mDescription = @"opis";
        self.payment.mClientEmail = @"demo@tpay.com";
        self.payment.mClientName = @"Demo";
        self.payment.mCrc = @"demo";
        self.payment.mSecurityCode = @"demo";
    }
}

#pragma mark - State Preservation

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.payment forKey:kExtraPayment];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    self.payment = [coder decodeObjectForKey:kExtraPayment];
    [super decodeRestorableStateWithCoder:coder];
}

#pragma mark - Transferuj.pl

- (void)tpayDidSucceedWithPayment:(TpayPayment *)payment {
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Płatność" message:@"Płatność udana!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)tpayDidFailedWithPayment:(TpayPayment *)payment {
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Płatność" message:@"Płatność nie udana!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"TpayPaymentInnerSegue"]) {
        TpayViewController *childViewController = (TpayViewController *)[segue destinationViewController];
        childViewController.payment = self.payment;
        childViewController.delegate = self;
    }
}

#pragma mark - BLIK response

- (void) tpayDidSucceedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id)responseObject {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadingView];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BLIK" message:@"Potwierdź płatność BLIK w aplikacji banku." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        _blikCodeTextField.text = @"";
    });
}

- (void) tpayDidFailedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id)responseObject {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoadingView];
        
        NSString *error = @"Nieznany błąd";
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            error = responseObject[@"err"];
        } else if ([responseObject isKindOfClass:[NSError class]]) {
            NSError *errorObject = (NSError *) responseObject;
            error = errorObject.localizedFailureReason;
        }
        
        NSString *errorMessage = [NSString stringWithFormat:@"Płatność BLIK zakończona błędem: %@", error];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"BLIK" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
}

#pragma mark - BLIK handling

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= kBlikCodeLength;
}

- (IBAction)payWithBlikAction:(id)sender {
    [_blikCodeTextField resignFirstResponder];
    
    if (_blikCodeTextField.text.length != kBlikCodeLength) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kod BLIK" message:@"Kod BLIK powinien składać się z 6 cyfr!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    NSString* blikCode = _blikCodeTextField.text;
    [self testBlikPaymentWithCode:blikCode];
    [self showLoadingView];
}

/*
 * Warning!
 * Fill with own api key to run demo
 */

- (void)testBlikPaymentWithCode: (NSString *)blikCode {
    TpayBlikTransaction *transaction = [self preapreTestTransaction];
    transaction.mBlikCode = blikCode;
    
    TpayApiClient *client = [TpayApiClient new];
    client.delegate = self;
    
    [client payWithBlikTransaction:transaction withKey:@"apiKey"];
}

/*
 * Warning!
 * Fill with own api password, id, and security code to run demo
 */
- (TpayBlikTransaction *)preapreTestTransaction {
    TpayBlikTransaction *transaction = [TpayBlikTransaction new];
    transaction.mApiPassword = @"apiPassword";
    transaction.mId = @"00000";
    transaction.mAmount = @"0.01";
    transaction.mCrc = @"demo";
    transaction.mSecurityCode = @"securityCode";
    transaction.mDescription = @"Opis demonstracyjnej transakcji.";
    transaction.mClientEmail = @"demo@tpay";
    transaction.mClientName = @"Demo";
    [transaction addBlikAlias:@"TpayDemoAlias12345" withLabel:nil andKey:nil];

    return transaction;
}

- (void)addLoadingView {
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.activityIndicatorView];
        [self.view bringSubviewToFront:self.activityIndicatorView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        self.activityIndicatorView.hidesWhenStopped = YES;
    }
}

- (void)showLoadingView {
    if (_activityIndicatorView != nil) {
        [self.activityIndicatorView startAnimating];
    }
}

- (void)hideLoadingView {
    if (_activityIndicatorView != nil) {
        [self.activityIndicatorView stopAnimating];
    }
}


/*
 * Warning!
 * Fill with own api key to run demo
 */
- (IBAction)openDefaultBlikViewForRegisteredUser:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TpayBlikStoryboard" bundle: [NSBundle bundleWithIdentifier:@"com.tpay.TpaySDK"]];
    TpayBlikTransactionViewController *blikDefaultVC = (TpayBlikTransactionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TpayBlikTransactionViewController"];
    blikDefaultVC.blikTransaction = [self preapreTestTransaction];
    blikDefaultVC.key = @"apiKey";
    blikDefaultVC.blikDelegate = self;
    blikDefaultVC.viewType = kRegisteredAlias;
    
    [self.navigationController pushViewController:blikDefaultVC animated:YES];
}


/*
 * Warning!
 * Fill with own api key to run demo
 */
- (IBAction)openDefaultBlikViewForUnregisteredUser:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TpayBlikStoryboard" bundle: [NSBundle bundleWithIdentifier:@"com.tpay.TpaySDK"]];
    TpayBlikTransactionViewController *blikDefaultVC = (TpayBlikTransactionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TpayBlikTransactionViewController"];
    blikDefaultVC.blikTransaction = [self preapreTestTransaction];
    blikDefaultVC.key = @"apiKey";
    blikDefaultVC.blikDelegate = self;
    blikDefaultVC.viewType = kUnregisteredAlias;
    
    [self.navigationController pushViewController:blikDefaultVC animated:YES];
}


/*
 * Warning!
 * Fill with own api key to run demo
 */
- (IBAction)openDefaultBlikViewWithoutOneClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TpayBlikStoryboard" bundle: [NSBundle bundleWithIdentifier:@"com.tpay.TpaySDK"]];
    TpayBlikTransactionViewController *blikDefaultVC = (TpayBlikTransactionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TpayBlikTransactionViewController"];
    blikDefaultVC.blikTransaction = [self preapreTestTransaction];
    blikDefaultVC.key = @"apiKey";
    blikDefaultVC.blikDelegate = self;
    blikDefaultVC.viewType = kOnlyBlik;
    
    [self.navigationController pushViewController:blikDefaultVC animated:YES];
}


@end
