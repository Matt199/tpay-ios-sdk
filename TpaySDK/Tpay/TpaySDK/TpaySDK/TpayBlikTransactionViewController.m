#import "TpayBlikTransactionViewController.h"
#import "TpayApiClient.h"

@interface TpayBlikTransactionViewController () <TpayBlikTransactionDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *amountToPayLabel;
@property (weak, nonatomic) IBOutlet UITextField *blikCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIView *loader;
@property (weak, nonatomic) IBOutlet UILabel *transactionTitle;
@property (weak, nonatomic) IBOutlet UIStackView *availableAppsView;
@property (weak, nonatomic) IBOutlet UIStackView *blikCodeView;
@property (weak, nonatomic) IBOutlet UIStackView *registerAliasCheckboxView;
@property (weak, nonatomic) IBOutlet UIStackView *payWithBlikCheckboxView;
@property (weak, nonatomic) IBOutlet UIPickerView *availableAppsPicker;
@property (weak, nonatomic) IBOutlet UISwitch *registerAliasCheckbox;
@property (weak, nonatomic) IBOutlet UISwitch *payWithBlikCheckbox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *appList;
@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) UIButton *compButton;

@end

@implementation TpayBlikTransactionViewController

int const kBlikCodeLength = 6;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showAppropriateViews];
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterForKeyboardNotifications];
}

- (void)setupViews {
    
    _availableAppsPicker.dataSource = self;
    _availableAppsPicker.delegate = self;
    
    _blikCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _blikCodeTextField.inputAccessoryView = [self inputAccessoryView];
    _blikCodeTextField.delegate = self;
    _blikCodeTextField.layer.cornerRadius = 3;
    
    _loader.layer.cornerRadius = 5;
    _payButton.layer.cornerRadius = 3;
    _amountToPayLabel.text = [NSString stringWithFormat:@"%@ PLN", _blikTransaction.mAmount];
    _transactionTitle.text = _blikTransaction.mDescription;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [_registerAliasCheckbox addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [_payWithBlikCheckbox addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (_blikCodeView.isHidden) {
        [self payButtonEnabled:YES];
    } else {
        [self handlePayButtonState];
    }    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (!_blikCodeView.isHidden) {
        if (_blikCodeTextField.text.length  + (string.length - range.length) < 6) {
            [self payButtonEnabled:NO];
        } else {
            [self payButtonEnabled:YES];
        }
    } else {
        [self payButtonEnabled:YES];
    }
    
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= kBlikCodeLength;
}

- (void)payButtonEnabled:(BOOL)enabled {
    if (enabled) {
        _compButton.enabled = YES;
        _compButton.alpha = 1;
        
        _payButton.enabled = YES;
        _payButton.alpha = 1;
    } else {
        _compButton.enabled = NO;
        _compButton.alpha = 0.5;
        
        _payButton.enabled = NO;
        _payButton.alpha = 0.5;
    }
}

- (void)switchChanged:(UISwitch *)sender {
    BOOL hidden = !sender.on;
    if (sender == _payWithBlikCheckbox) {
        _blikCodeView.hidden = hidden;
        if (!hidden) {
            [self handlePayButtonState];
        } else {
            [self payButtonEnabled:YES];
        }
    }
}

- (void)showAppropriateViews {
    
    [_appList removeAllObjects];
    [_availableAppsPicker reloadAllComponents];
    
    switch (_viewType) {
        case kOnlyBlik:
            _availableAppsView.hidden = YES;
            _blikCodeView.hidden = NO;
            _registerAliasCheckboxView.hidden = YES;
            _payWithBlikCheckboxView.hidden = YES;
            _registerAliasCheckbox.hidden = YES;
            _payWithBlikCheckbox.hidden = YES;
            break;
            
        case kNonUniqueAlias:
            _availableAppsView.hidden = NO;
            _blikCodeView.hidden = YES;
            _registerAliasCheckboxView.hidden = YES;
            _payWithBlikCheckboxView.hidden = YES;
            _registerAliasCheckbox.hidden = YES;
            _payWithBlikCheckbox.hidden = YES;
            break;
            
        case kUnregisteredAlias:
            _availableAppsView.hidden = YES;
            _blikCodeView.hidden = NO;
            _registerAliasCheckboxView.hidden = NO;
            _payWithBlikCheckboxView.hidden = YES;
            _registerAliasCheckbox.hidden = NO;
            _payWithBlikCheckbox.hidden = YES;
            break;
            
        case kRegisteredAlias:
            _availableAppsView.hidden = YES;
            _blikCodeView.hidden = YES;
            _registerAliasCheckboxView.hidden = YES;
            _payWithBlikCheckboxView.hidden = NO;
            _registerAliasCheckbox.hidden = YES;
            _payWithBlikCheckbox.hidden = NO;
            break;
    }
}

-(void)dismissKeyboard {
    [_blikCodeTextField resignFirstResponder];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    _payButton.hidden = YES;
    
    NSDictionary* info = [aNotification userInfo];
    
    NSInteger viewHeight = self.view.frame.size.height;
    NSInteger kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    NSInteger kbOriginYTop =  viewHeight - kbHeight;
    
    NSInteger tfOriginYInView = [_blikCodeView convertRect:_blikCodeView.bounds toView:self.view.superview].origin.y;
    
    NSInteger tfHeight = _blikCodeView.frame.size.height;
    NSInteger tfOriginYBottom = tfOriginYInView + tfHeight;
    
    if (tfOriginYBottom > kbOriginYTop) {
        
        NSInteger offset = tfHeight + tfOriginYBottom - kbOriginYTop;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, -offset);
        }];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    _payButton.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
        self.payButton.transform = CGAffineTransformMakeTranslation(0, 0);
    }];}

#pragma mark - handle button click

- (IBAction)payButtonAction:(id)sender {
    
    if ([_loader isHidden]) {
        [_blikCodeTextField resignFirstResponder];
        [self setLoaderVisible:YES];
         NSString* blikCode = _blikCodeTextField.text;
        
        if (!_blikCodeView.isHidden && blikCode.length >= 6) {
            _blikTransaction.mBlikCode = blikCode;
            
            if (_registerAliasCheckbox.isHidden || !_registerAliasCheckbox.isOn) {
                _blikTransaction.mBlikAlias = nil;
            }
            
            TpayApiClient *client = [TpayApiClient new];
            client.delegate = self;
            [client payWithBlikTransaction:_blikTransaction withKey:_key];
        } else {
            NSInteger selectedAliasId = [_availableAppsPicker selectedRowInComponent:0];
            NSString *keyForSelectedAlias = _appList[selectedAliasId][@"applicationCode"];
            
            _blikTransaction.mBlikAlias[0][@"key"] = keyForSelectedAlias;
            
            TpayApiClient *client = [TpayApiClient new];
            client.delegate = self;
            [client payWithBlikTransaction:_blikTransaction withKey:_key];
        }
    }
}

- (void) setLoaderVisible:(BOOL)visible {
    if (visible) {
        _loader.hidden = NO;
        self.navigationController.view.userInteractionEnabled = NO;
    } else {
        _loader.hidden = YES;
        self.navigationController.view.userInteractionEnabled = YES;
    }
}

#pragma mark - BLIK response

- (void) tpayDidSucceedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id)responseObject {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setLoaderVisible:NO];
        _blikCodeTextField.text = @"";
        [self.blikDelegate tpayDidSucceedWithBlikTransaction:transaction andResponse:responseObject];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void) tpayDidFailedWithBlikTransaction:(TpayBlikTransaction *)transaction andResponse: (id)responseObject {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setLoaderVisible:NO];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]
            && [@"ERR82" isEqualToString:responseObject[@"err"]]
            && responseObject[@"availableUserApps"] != nil) {
           
            [self supportMultipleAvailableAppsFromResponse:responseObject];
            
        } else {
            [self.blikDelegate tpayDidFailedWithBlikTransaction:transaction andResponse:responseObject];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    });
}

- (void)supportMultipleAvailableAppsFromResponse:(NSDictionary *)responseObject {
    
    _viewType = kNonUniqueAlias;
    [self showAppropriateViews];
    
    _appList = responseObject[@"availableUserApps"];
    
    NSDictionary *showBlikCodeViewOption = [NSDictionary dictionaryWithObjectsAndKeys:@"Chcę wprowadzić kod BLIK", @"applicationName", nil];
    [_appList addObject:showBlikCodeViewOption];
    
    [_availableAppsPicker reloadAllComponents];
    
    NSInteger row = 0;
    
    if ([_appList count] > 2) {
        row = [_appList count] / 2;
    }
    
    [_availableAppsPicker selectRow:row inComponent:0 animated:NO];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_appList count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([_appList[row][@"applicationName"] isEqualToString:@"Chcę wprowadzić kod BLIK"]) {
        _blikCodeView.hidden = NO;
        [self handlePayButtonState];
    } else {
        _blikCodeView.hidden = YES;
        [self payButtonEnabled:YES];
    }
}

- (void)handlePayButtonState {
    if (_blikCodeTextField.text.length < 6) {
        [self payButtonEnabled:NO];
    } else {
        [self payButtonEnabled:YES];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* label = (UILabel*)view;
    if (!label){
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:17];
        [label setTextAlignment:NSTextAlignmentCenter];
    }
    
    label.text = _appList[row][@"applicationName"];
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 24;
}

- (UIView *)inputAccessoryView {
    if (!_inputAccessoryView) {
        CGRect accessFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 45);
        _inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        _inputAccessoryView.backgroundColor = [UIColor whiteColor];
        _inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _compButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _compButton.frame = accessFrame;
        _compButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _compButton.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:68.0/255.0 blue:159.0/255.0 alpha:1];
        [_compButton setTitle: @"ZAPŁAĆ" forState:UIControlStateNormal];
        [_compButton.titleLabel setFont: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]];
        [_compButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_compButton addTarget:self action:@selector(payButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:_compButton];
    }
    return _inputAccessoryView;
}

@end
